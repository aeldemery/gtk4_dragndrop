public class Gtk4Demo.CssButton : Gtk.Widget {
    string css_class;

    public CssButton (string css_class) {
        this.css_class = css_class;
        this.add_css_class (css_class);
        set_size_request (48, 32);
        var source = new Gtk.DragSource ();
        source.prepare.connect (drag_prepare);
        this.add_controller (source);
    }

    Gdk.ContentProvider drag_prepare (Gtk.DragSource source, double x, double y) {
        //source.set_icon (paintable, 0, 0);
        return new Gdk.ContentProvider.for_value (css_class);
    }
}