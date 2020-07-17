public class Gtk4Demo.MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application app) {
        Object (application: app);
    }

    Gtk.Button button;
    Gtk.ScrolledWindow sw;
    Gtk4Demo.CanvasItem canvas;
    Gtk.Fixed fixed_canvas;
    Gtk.Box box; Gtk.Box box2; Gtk.Box box3;
    Gtk.CssProvider provider;

    Gtk.DragSource source;
    Gtk.DropTarget dest;
    Gtk.GestureClick gesture;

    const string[] colors = {
        "red", "green", "blue", "magenta", "orange", "gray", "black", "yellow",
        "white", "gray", "brown", "pink", "cyan", "bisque", "gold", "maroon",
        "navy", "orchid", "olive", "peru", "salmon", "silver", "wheat"
    };

    construct {
        this.title = "Vala Drag-and-Drop";
        this.set_default_size (640, 480);

        button = new Gtk.Button ();

        provider = new Gtk.CssProvider ();
        provider.load_from_resource ("/github/aeldemery/gtk4_dragndrop/dnd.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, 800);

        box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        this.set_child (box);

        box2 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.append (box2);

        fixed_canvas = new Gtk.Fixed ();
        with (fixed_canvas) {
            hexpand = true;
            vexpand = true;
            add_css_class ("frame");
        }

        source = new Gtk.DragSource ();
        source.set_actions (Gdk.DragAction.MOVE);
        source.prepare.connect (prepare);
        source.drag_begin.connect (drag_begin);
        source.drag_end.connect (drag_end);
        source.drag_cancel.connect (drag_cancel);

        fixed_canvas.add_controller (source);

        dest = new Gtk.DropTarget (typeof (Gtk.Widget), Gdk.DragAction.MOVE);
        // dest.drop.connect (drag_drop); // Vala bug

        fixed_canvas.add_controller (dest);

        gesture = new Gtk.GestureClick ();
        gesture.set_button (0);
        gesture.pressed.connect (pressed_cb);
        gesture.released.connect (released_cb);

        fixed_canvas.add_controller (gesture);
    }

    Gdk.ContentProvider ? prepare (Gtk.DragSource source, double x, double y) {
        var canvas_widget = source.get_widget ();
        var item = canvas_widget.pick (x, y, Gtk.PickFlags.DEFAULT);
        item = item.get_ancestor (typeof (Gtk4Demo.CanvasItem));
        if (item == null) return null;

        canvas_widget.set_data ("dragged-item", item);
        return new Gdk.ContentProvider.for_value (item);
    }

    void drag_begin (Gtk.DragSource source, Gdk.Drag drag) {
    }

    void drag_end (Gtk.DragSource source, Gdk.Drag drag, bool delete_data) {
    }

    bool drag_cancel (Gtk.DragSource source, Gdk.Drag drag, Gdk.DragCancelReason reason) {
        return false;
    }

    bool drag_drop (Gtk.DropTarget target, Value value, double x, double y) {
        return true;
    }

    void pressed_cb (Gtk.Gesture gesture, int n_press, double x, double y) {
    }

    void released_cb (Gtk.Gesture gesture, int n_press, double x, double y) {
    }
}