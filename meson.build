project ('github.aeldemery.gtk4_dragndrop', 
    'vala', 'c',
    version: '0.1.0',
)

sources = files(
    'src/Main.vala',
    'src/CanvasItem.vala',
    'src/MainWindow.vala',
)

dependencies = [
    dependency ('glib-2.0'),
    dependency ('gobject-2.0'),
    dependency ('gtk4'),
    meson.get_compiler('c').find_library('m', required: false),
]

sources += import( 'gnome' ).compile_resources(
    'project-resources',
    'data/github.aeldemery.gtk4_dragndrop.gresource.xml',
    source_dir: 'data',
)

executable (
    meson.project_name(),
    sources: sources,
    dependencies: dependencies,
    install: true,
)