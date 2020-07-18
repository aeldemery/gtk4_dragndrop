public class Gtk4Demo.ColorSwatch : Gtk.Widget {
    public Gdk.RGBA color { get; set; }

    public ColorSwatch (string color) {
        this.color.parse(color);
    }

    construct {
        var source = new Gtk.DragSource ();
        source.prepare.connect (drag_prepare);
        this.add_controller (source);
        this.set_css_name("colorswatch");
    }

    Gdk.ContentProvider drag_prepare (Gtk.DragSource source, double x, double y) {
        return new Gdk.ContentProvider.for_value (color);
    }

    protected override void snapshot (Gtk.Snapshot snapshot) {
        var w = this.get_width ();
        var h = this.get_height ();

        snapshot.append_color (color, { { 0, 0 }, { w, h } });
    }

    protected override void measure (Gtk.Orientation orientation,
                                     int for_size,
                                     out int minimum_size,
                                     out int natural_size,
                                     out int minimum_baseline,
                                     out int natural_baseline) {
        if (orientation == Gtk.Orientation.HORIZONTAL) {
            minimum_size = natural_size = 48;
        } else {
            minimum_size = natural_size = 32;
        }
    }
}