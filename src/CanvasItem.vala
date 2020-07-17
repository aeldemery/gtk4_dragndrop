public class Gtk4Demo.CanvasItem : Gtk.Widget {
    public double r { get; set; }
    public double angle { get; set; }
    public double delta { get; set; }

    Gtk.Label label;
    Gtk.Fixed fixed;
    Gtk.Box editor;
    Gtk.Scale scale;
    Gtk.Entry entry;

    static ulong signal_id;
    static int n_items = 0;

    construct {
        this.set_layout_manager_type (typeof (Gtk.BinLayout));
        this.set_css_name ("item");

        label = new Gtk.Label (@"Item $n_items");
        label.add_css_class ("canvasitem");

        fixed = new Gtk.Fixed ();
        fixed.set_parent (this);
        fixed.put (label, 0, 0);

        label.add_css_class ("frame");
        label.name = @"item$n_items";

        Gdk.RGBA rgba;
        rgba.parse ("yellow");

        set_color (rgba);

        angle = 0;

        var dest = new Gtk.DropTarget (GLib.Type.INVALID, Gdk.DragAction.COPY);
        dest.set_gtypes ({ typeof (Gdk.RGBA), typeof (string) });
        // dest.drop.connect (item_drag_drop); // Vala bug
        label.add_controller (dest);

        var gesture_rotate = new Gtk.GestureRotate ();
        gesture_rotate.angle_changed.connect (angle_changed);
        gesture_rotate.end.connect (rotate_done);
        this.add_controller (gesture_rotate);

        var gesture_click = new Gtk.GestureClick ();
        gesture_click.released.connect (click_done);
        this.add_controller (gesture_click);

        n_items++;
    }

    public CanvasItem () {
        print (n_items.to_string () + "\n");
    }

    ~CanvasItem() {
        fixed.unparent();
        //editor.unparent(); // TODO uncomment this later
    }

    void set_color (Gdk.RGBA color) {
    }

    void set_css (string css_class) {
    }

    public void apply_transform () {
    }

    bool item_drag_drop (Gtk.DropTarget dest, Value value, double x, double y) {
        return true;
    }

    void angle_changed (Gtk.GestureRotate gesture, double angle, double delta) {
    }

    void rotate_done (Gtk.Gesture gesture, Gdk.EventSequence sequence) {
    }

    void click_done (Gtk.Gesture gesture, int n_press, double x, double y) {
    }

    new void map () {
        base.map ();
        apply_transform ();
    }

    Gdk.Paintable get_drag_icon () {
        return new Gtk.WidgetPaintable (fixed);
    }

    bool is_editing () {
        return editor != null;
    }

    void scale_changed (Gtk.Range range) {
        angle = range.get_value ();
        apply_transform ();
    }

    void text_changed (GLib.Object editable, GLib.ParamSpec pspec) {
        label.set_text ((editable as Gtk.Editable).get_text ());
        apply_transform ();
    }

    void stop_editing () {
        if (editor == null) return;
        scale.disconnect (signal_id);
        fixed.remove (editor);
        editor = null;
    }

    void start_editing () {
        if (editor != null) return;
        editor = new Gtk.Box (Gtk.Orientation.VERTICAL, 12);

        entry = new Gtk.Entry ();
        entry.set_text (label.get_text ());
        entry.width_chars = 12;
        entry.notify["text"].connect (text_changed);
        entry.activate.connect_after (stop_editing);

        editor.append (entry);

        scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 360, 1);
        scale.draw_value = false;
        scale.set_value (Math.fmod (angle, 360));
        signal_id = scale.value_changed.connect (scale_changed);

        editor.append (scale);

        double x, y;
        this.translate_coordinates (fixed, 0, 0, out x, out y);
        fixed.put (editor, x, y + 2 * r);
        entry.grab_focus ();
    }
}