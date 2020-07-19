public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application app) {
        Object (application: app);
    }

    Gtk.ScrolledWindow sw;
    Gtk4Demo.CanvasItem canvas_item;
    Gtk.Fixed fixed_canvas;
    Gtk.Box box; Gtk.Box box2; Gtk.Box box3;
    Gtk.CssProvider provider;

    Gtk.Fixed pressed_fixed;
    Gtk4Demo.CanvasItem pressed_item;

    Gtk.Image image_button;

    const string[] colors = {
        "red", "green", "blue", "magenta", "orange", "gray", "black", "yellow",
        "white", "gray", "brown", "pink", "cyan", "bisque", "gold", "maroon",
        "navy", "orchid", "olive", "peru", "salmon", "silver", "wheat"
    };

    construct {
        this.title = "Vala Drag-and-Drop";
        this.set_default_size (640, 480);

        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/github/aeldemery/gtk4_dragndrop/dnd.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, 800);

        box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        this.set_child (box);

        box2 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.append (box2);

        fixed_canvas = new Gtk.Fixed ();
        fixed_canvas.hexpand = true;
        fixed_canvas.vexpand = true;
        fixed_canvas.add_css_class ("frame");

        var source = new Gtk.DragSource ();
        source.set_actions (Gdk.DragAction.MOVE);
        source.prepare.connect (prepare);
        source.drag_begin.connect (drag_begin);
        source.drag_end.connect (drag_end);
        source.drag_cancel.connect (drag_cancel);

        fixed_canvas.add_controller (source);

        var dest = new Gtk.DropTarget (typeof (Gtk.Widget), Gdk.DragAction.MOVE);
        dest.on_drop.connect (drag_drop);

        fixed_canvas.add_controller (dest);

        var gesture = new Gtk.GestureClick ();
        gesture.set_button (0);
        gesture.pressed.connect (pressed_cb);
        gesture.released.connect (released_cb);

        fixed_canvas.add_controller (gesture);

        box2.append (fixed_canvas);

        int x, y;
        x = y = 40;

        for (int i = 0; i < 4; i++) {
            canvas_item = new Gtk4Demo.CanvasItem ();
            fixed_canvas.put (canvas_item, x, y);
            canvas_item.apply_transform ();

            x += 150;
            y += 100;
        }

        sw = new Gtk.ScrolledWindow ();
        sw.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.NEVER);

        box.append (sw);

        box3 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box3.add_css_class ("linked");

        sw.set_child (box3);

        foreach (var color in colors) {
            box3.append (new Gtk4Demo.ColorSwatch (color));
        }
        
        css_button_new ("rainbow1");
        box3.append (image_button);
        css_button_new ("rainbow2");
        box3.append (image_button);
        css_button_new ("rainbow3");
        box3.append (image_button);
    }

    void css_button_new (string css_class) {
        image_button = new Gtk.Image ();
        var source = new Gtk.DragSource ();

        image_button.set_size_request (48, 32);
        image_button.add_css_class (css_class);
        image_button.set_data<string>("css-class", css_class);
        source.prepare.connect (css_button_drag_prepare);
        image_button.add_controller (source);
    }

    Gdk.ContentProvider css_button_drag_prepare (Gtk.DragSource source, double x, double y) {
        var css_class = image_button.get_data<string>("css-class");
        var paintable = new Gtk.WidgetPaintable (image_button);
        source.set_icon (paintable, 0, 0);
        return new Gdk.ContentProvider.for_value (css_class);
    }

    Gdk.ContentProvider ? prepare (Gtk.DragSource source, double x, double y) {
        var canvas_widget = source.get_widget ();
        var item = canvas_widget.pick (x, y, Gtk.PickFlags.DEFAULT);
        item = item.get_ancestor (typeof (Gtk4Demo.CanvasItem));
        if (item == null) return null;

        canvas_widget.set_data<Gtk.Widget>("dragged-item", item);
        return new Gdk.ContentProvider.for_value (item);
    }

    void drag_begin (Gtk.DragSource source, Gdk.Drag drag) {
        var canvas_widget = source.get_widget ();
        var item = canvas_widget.get_data<Gtk4Demo.CanvasItem>("dragged-item");

        var paintable = item.get_drag_icon ();
        source.set_icon (paintable, (int) item.r, (int) item.r);
        item.set_opacity (0.3);
    }

    void drag_end (Gtk.DragSource source, Gdk.Drag drag, bool delete_data) {
        var canvas_widget = source.get_widget ();
        var item = canvas_widget.get_data<Gtk4Demo.CanvasItem>("dragged-item");

        canvas_widget.set_data<Gtk.Widget>("dragged-item", null);
        item.set_opacity (1.0);
    }

    bool drag_cancel (Gtk.DragSource source, Gdk.Drag drag, Gdk.DragCancelReason reason) {
        return false;
    }

    bool drag_drop (Gtk.DropTarget target, Value value, double x, double y) {
        var item = value.get_object () as Gtk4Demo.CanvasItem;
        var canvas_widget = item.get_parent ();
        var last_child = canvas_widget.get_last_child ();

        if (item != last_child) {
            item.insert_after (canvas_widget, last_child);
        }

        ((Gtk.Fixed)canvas_widget).move (item, x - item.r, y - item.r);

        return true;
    }

    void pressed_cb (Gtk.Gesture gesture, int n_press, double x, double y) {
        pressed_fixed = gesture.get_widget () as Gtk.Fixed;
        var widget = pressed_fixed.pick (x, y, Gtk.PickFlags.DEFAULT);
        pressed_item = (Gtk4Demo.CanvasItem)widget.get_ancestor (typeof (Gtk4Demo.CanvasItem));

        if ((gesture as Gtk.GestureClick).get_current_button () == Gdk.BUTTON_SECONDARY) {
            var menu = new Gtk.Popover ();
            menu.set_parent (pressed_fixed);
            menu.has_arrow = false;
            menu.pointing_to = { (int) x, (int) y, 1, 1 };

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            menu.set_child (box);

            var button = new Gtk.Button.with_label ("New");
            button.has_frame = false;
            button.clicked.connect (new_item_cb);

            box.append (button);
            box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            button = new Gtk.Button.with_label ("Edit");
            button.has_frame = false;
            button.sensitive = (pressed_item != null) && (pressed_item != (Gtk.Widget)pressed_fixed);
            button.clicked.connect (edit_item_cb);

            box.append (button);
            box.append (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));

            button = new Gtk.Button.with_label ("Delete");
            button.has_frame = false;
            button.sensitive = (pressed_item != null) && (pressed_item != (Gtk.Widget)pressed_fixed);
            button.clicked.connect (delete_item_cb);

            box.append (button);

            menu.popdown ();
        }
    }

    void released_cb (Gtk.Gesture gesture, int n_press, double x, double y) {
        pressed_fixed = gesture.get_widget () as Gtk.Fixed;
        var widget = pressed_fixed.pick (x, y, Gtk.PickFlags.DEFAULT);
        pressed_item = (Gtk4Demo.CanvasItem)widget.get_ancestor (typeof (Gtk4Demo.CanvasItem));

        if (pressed_item == null) return;

        if ((gesture as Gtk.GestureClick).get_current_button () == Gdk.BUTTON_PRIMARY) {
            if (pressed_item.is_editing ()) {
                pressed_item.stop_editing ();
            } else {
                pressed_item.start_editing ();
            }
        }
    }

    void new_item_cb (Gtk.Button button) {
        Gdk.Rectangle rect;
        var popover = button.get_ancestor (typeof (Gtk.Popover)) as Gtk.Popover;
        popover.get_pointing_to (out rect);

        var item = new Gtk4Demo.CanvasItem ();
        pressed_fixed.put (item, rect.x, rect.y);
        item.apply_transform ();

        popover.popdown ();
    }

    void edit_item_cb (Gtk.Button button) {
        if (button != null) {
            var popover = button.get_ancestor (typeof (Gtk.Popover)) as Gtk.Popover;
            popover.popdown ();
        }

        if (!pressed_item.is_editing ()) {
            pressed_item.start_editing ();
        }
    }

    void delete_item_cb (Gtk.Button button) {
        var child = pressed_item.get_parent ();
        pressed_fixed.remove (child);

        var popover = button.get_ancestor (typeof (Gtk.Popover)) as Gtk.Popover;
        popover.popdown ();
    }
}