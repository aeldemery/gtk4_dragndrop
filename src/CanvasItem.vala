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
        n_items++;
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

        this.angle = 0;

        var dest = new Gtk.DropTarget (GLib.Type.INVALID, Gdk.DragAction.COPY);
        dest.set_gtypes ({ typeof (Gdk.RGBA), typeof (string) });
        dest.on_drop.connect (item_drag_drop);
        label.add_controller (dest);

        var gesture_rotate = new Gtk.GestureRotate ();
        gesture_rotate.angle_changed.connect (angle_changed);
        gesture_rotate.end.connect (rotate_done);
        this.add_controller (gesture_rotate);

        var gesture_click = new Gtk.GestureClick ();
        gesture_click.released.connect (click_done);
        this.add_controller (gesture_click);
    }

    public CanvasItem () {
        print (n_items.to_string () + "\n");
    }

    ~CanvasItem () {
        fixed.unparent ();
        editor.unparent();
    }

    void set_color (Gdk.RGBA color) {
        var color_str = color.to_string ();
        var css_str = @"* { background: $color_str; }";

        var context = label.get_style_context ();
        var provider = context.get_data<Gtk.CssProvider>("style-provider");
        if (provider != null) {
            context.remove_provider (provider);
        }

        var old_class = label.get_data<string>("css-class");
        if (old_class != "") {
            label.remove_css_class (old_class);
        }

        provider = new Gtk.CssProvider ();
        provider.load_from_buffer (css_str.data);

        label.get_style_context ().add_provider (provider, 800);

        context.set_data<Gtk.CssProvider>("style-provider", provider);
    }

    void set_css (string css_class) {
        var context = label.get_style_context ();
        var provider = context.get_data<Gtk.CssProvider>("style-provider");
        if (provider != null) {
            context.remove_provider (provider);
        }

        var old_class = label.get_data<string>("css-class");
        if (old_class != "") {
            label.remove_css_class (old_class);
        }

        label.set_data<string>("css-class", css_class);
        label.add_css_class (css_class);
    }

    public void apply_transform () {
        float x = label.get_allocated_width () / 2.0f;
        float y = label.get_allocated_height () / 2.0f;

        this.r = Math.sqrt (x * x + y * y);

        var transform = new Gsk.Transform ();
        transform.translate ({ (float) r, (float) r });
        transform.rotate ((float) angle + (float) delta);
        transform.translate ({ -x, -y });

        fixed.set_child_transform (label, transform);
    }

    bool item_drag_drop (Gtk.DropTarget dest, Value value, double x, double y) {
        if (value.type () == typeof (Gdk.RGBA)) {
            set_color ((Gdk.RGBA ? )value.get_boxed ());
        } else if (value.type () == typeof (string)) {
            set_css (value.get_string ());
        }

        return true;
    }

    void angle_changed (Gtk.GestureRotate gesture, double angle, double delta) {
        this.delta = angle / Math.PI * 180.0;
        apply_transform ();
    }

    void rotate_done (Gtk.Gesture gesture, Gdk.EventSequence sequence) {
        this.angle = this.angle + this.delta;
        this.delta = 0;
    }

    void click_done (Gtk.Gesture gesture, int n_press, double x, double y) {
        var item = gesture.get_widget ();
        var canvas = item.get_parent ();
        var last_child = canvas.get_last_child ();
        if (item != last_child) {
            item.insert_after (canvas, last_child);
        }
    }

    new void map () {
        base.map ();
        apply_transform ();
    }

    public Gdk.Paintable get_drag_icon () {
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
        var canvas = this.get_parent();
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
        this.translate_coordinates (canvas, 0, 0, out x, out y);
        (canvas as Gtk.Fixed).put (editor, x, y + 2 * r);
        entry.grab_focus ();
    }
}