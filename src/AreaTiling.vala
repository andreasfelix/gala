/*
* Copyright 2020 Felix Andreas
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

public class Gala.AreaTiling : Object {
    int animation_duration = 250;
    public WindowManager wm { get; construct; }
    private Meta.Window window;
    private Clutter.Actor window_icon;
    public bool is_shrinked = false;

    public AreaTiling (WindowManager wm) {
        Object (wm : wm);
    }

    public void tile(int x, int y) {
        debug("Tile!");
        Meta.Rectangle tile_rect = calculate_tile_rect (x, y);
        window.move_resize_frame (true, tile_rect.x, tile_rect.y, tile_rect.width, tile_rect.height);
        wm.hide_tile_preview ();
    }

    public void preview(int x, int y) {
        if (!is_shrinked){
            shrink_window (window, (float) x, (float) y);
        } else {
            window_icon.set_position((float) x - 48.0f, (float) y - 48.0f);
        }

        Meta.Rectangle tile_rect = calculate_tile_rect (x, y);
        wm.show_tile_preview (window, tile_rect, window.get_screen ().get_current_monitor ());
    }

    private Meta.Rectangle calculate_tile_rect(int x, int y) {
        Meta.Rectangle wa = window.get_work_area_for_monitor (window.get_screen ().get_current_monitor ());

        int monitor_width = wa.width, monitor_height = wa.height;
        int monitor_x = x - wa.x, monitor_y = y - wa.y;
        int new_width, new_height;
        int new_x = wa.x, new_y = wa.y;

        if (monitor_x < (float) monitor_width * 2 / 5) {
            new_width = monitor_width / 2;
        } else if (monitor_x < (float) monitor_width * 3 / 5) {
            new_width = monitor_width;
        } else {
            new_width = monitor_width / 2;
            new_x += monitor_width / 2;
        }

        if (monitor_y < (float) monitor_height * 2 / 5) {
            new_height = monitor_height / 2;
        } else if (monitor_y < (float) monitor_height * 3 / 5) {
            new_height = monitor_height;
        } else {
            new_height = monitor_height / 2;
            new_y += monitor_height / 2;
        }

        return {new_x, new_y, new_width, new_height};
    }

    public void shrink_window (Meta.Window? window, float x, float y) {
        debug("shrink window!");
        is_shrinked = true;
        float abs_x, abs_y;
        var actor = (Meta.WindowActor)window.get_compositor_private ();
        actor.get_transformed_position (out abs_x, out abs_y);

        int width, height;
        window.get_screen ().get_size (out width, out height);
        actor.set_pivot_point ((x - abs_x) / actor.width, (y - abs_y) / actor.height);
        actor.save_easing_state ();
        actor.set_easing_mode (Clutter.AnimationMode.EASE_IN_EXPO);
        actor.set_easing_duration (animation_duration);
        actor.set_scale (0.0f, 0.0f);
        actor.opacity = 0U;
        actor.restore_easing_state ();

        var scale_factor = InternalUtils.get_ui_scaling_factor ();
        window_icon = new WindowIcon (window, 64, scale_factor);
        window_icon.opacity = 255;
        window_icon.set_pivot_point (0.5f, 0.5f);
        var stage = actor.get_stage ();
        stage.add_child (window_icon);
    }

    public void unshrink_window (Meta.Window? window) {
        debug("unshrink window!");
        is_shrinked = false;
        var actor = (Meta.WindowActor)window.get_compositor_private ();

        int width, height;
        window.get_screen ().get_size (out width, out height);
        actor.set_pivot_point (0.5f, 1.0f);
        actor.set_scale (0.01f, 0.1f);
        actor.opacity = 0U;

        actor.save_easing_state ();
        actor.set_easing_mode (Clutter.AnimationMode.EASE_OUT_EXPO);
        actor.set_easing_duration (animation_duration);
        actor.set_scale (1.0f, 1.0f);
        actor.opacity = 255U;
        actor.restore_easing_state ();
        window_icon.opacity = 0;
    }
}
