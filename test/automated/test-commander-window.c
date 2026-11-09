/* SPDX-License-Identifier: GPL-3.0-or-later */
#include "nautilus-application.h"
#include "nautilus-window.h"
#include "nautilus-window-slot.h"
#include "nautilus-resources.h"
#include "nautilus-file-operations.h"

static void settle (void)
{
    gint64 end = g_get_monotonic_time () + 800 * 1000;
    while (g_get_monotonic_time () < end)
    {
        while (g_main_context_iteration (NULL, FALSE));
        g_usleep (1000);
    }
}

int main (int argc, char **argv)
{
    g_autoptr (GError) error = NULL;
    g_autoptr (NautilusApplication) app = NULL;
    NautilusWindow *window;
    NautilusWindowSlot *left, *right;
    g_autoptr (GFile) first = g_file_new_for_path (g_getenv ("COMMANDER_TEST_FIRST"));
    g_autoptr (GFile) second = g_file_new_for_path (g_getenv ("COMMANDER_TEST_SECOND"));

    nautilus_register_resource ();
    app = nautilus_application_new ();
    g_assert_true (g_application_register (G_APPLICATION (app), NULL, &error));
    g_assert_no_error (error);
    window = nautilus_application_create_window (app);
    nautilus_window_open_location_full (window, first, 0, NULL, NULL, NULL);
    settle ();
    left = nautilus_window_get_active_slot (window);
    g_assert_cmpuint (g_list_length (nautilus_window_get_slots (window)), ==, 1);
    g_action_group_activate_action (G_ACTION_GROUP (window), "toggle-dual-pane", NULL);
    settle ();
    g_assert_cmpuint (g_list_length (nautilus_window_get_slots (window)), ==, 2);
    right = g_list_last (nautilus_window_get_slots (window))->data;
    g_assert_true (right != left);
    g_assert_true (nautilus_window_get_active_slot (window) == left);
    nautilus_window_set_active_slot (window, right);
    nautilus_window_open_location_full (window, second, 0, NULL, right, NULL);
    settle ();
    g_assert_true (g_file_equal (nautilus_window_slot_get_location (left), first));
    g_assert_true (g_file_equal (nautilus_window_slot_get_location (right), second));
    /* Exercise Nautilus' original transfer engine with the actual pane locations. */
    for (int move = 0; move < 2; move++)
    {
        const char *name = move ? "move-proof.txt" : "copy-proof.txt";
        g_autoptr (GFile) source = g_file_get_child (first, name);
        g_autoptr (GFile) target = g_file_get_child (second, name);
        g_assert_true (g_file_replace_contents (source, "commander transfer proof", 24,
                                               NULL, FALSE, G_FILE_CREATE_NONE, NULL, NULL, &error));
        g_assert_no_error (error);
        GList *files = g_list_prepend (NULL, source);
        if (move)
            nautilus_file_operations_move_sync (files, second);
        else
            nautilus_file_operations_copy_sync (files, second);
        g_list_free (files);
        g_assert_true (g_file_query_exists (target, NULL));
        g_assert_cmpint (g_file_query_exists (source, NULL), ==, !move);
        g_autofree char *contents = NULL;
        gsize length = 0;
        g_assert_true (g_file_load_contents (target, NULL, &contents, &length, NULL, &error));
        g_assert_no_error (error);
        g_assert_cmpstr (contents, ==, "commander transfer proof");
        g_file_delete (source, NULL, NULL);
        g_file_delete (target, NULL, NULL);
    }
    g_action_group_activate_action (G_ACTION_GROUP (window), "toggle-dual-pane", NULL);
    settle ();
    g_assert_true (nautilus_window_get_active_slot (window) == right);
    g_assert_cmpuint (g_list_length (nautilus_window_get_slots (window)), ==, 2);
    g_action_group_activate_action (G_ACTION_GROUP (window), "toggle-dual-pane", NULL);
    settle ();
    g_assert_true (nautilus_window_get_active_slot (window) == right);
    g_assert_true (g_file_equal (nautilus_window_slot_get_location (left), first));
    g_assert_true (g_file_equal (nautilus_window_slot_get_location (right), second));
    g_action_group_activate_action (G_ACTION_GROUP (window), "new-tab", NULL);
    settle ();
    g_assert_cmpuint (g_list_length (nautilus_window_get_slots (window)), ==, 3);
    g_action_group_activate_action (G_ACTION_GROUP (window), "close-current-view", NULL);
    settle ();
    g_assert_cmpuint (g_list_length (nautilus_window_get_slots (window)), ==, 2);
    g_action_group_activate_action (G_ACTION_GROUP (window), "close-current-view", NULL);
    settle ();
    g_assert_cmpuint (g_list_length (nautilus_window_get_slots (window)), ==, 1);
    g_assert_true (nautilus_window_get_active_slot (window) == left);
    nautilus_window_close (window);
    settle ();
    g_print ("PASS: independent locations, F3 state, new tab, close tab and close pane\n");
    return 0;
}
