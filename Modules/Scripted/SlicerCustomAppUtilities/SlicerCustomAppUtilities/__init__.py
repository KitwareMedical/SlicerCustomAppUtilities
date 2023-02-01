import slicer


def applyStyle(widgets, styleSheetFilePath):
    """Set the styleSheet property of each widgets.

    See https://doc.qt.io/qt-5/qwidget.html#styleSheet-prop
    and https://doc.qt.io/qt-5/stylesheet.html
    """
    with open(styleSheetFilePath, "r") as fh:
        styleSheet = fh.read()
        for widget in widgets:
            widget.styleSheet = styleSheet


def polish(widget):
    """Re-polish widget and all its children.

    This function may be called after setting dynamic properties
    to ensure the application stylesheet is applied.
    """
    for child in slicer.util.findChildren(widget):
        try:
            widget.style().polish(child)
        except ValueError:
            pass


def setCssClass(widget, class_):
    """Sets one or more CSS classes to the widget cssClass dynamic Qt property."""
    # Remove duplicates if any
    classes = set([class_] if isinstance(class_, str) else class_)
    widget.setProperty("cssClass", list(classes))


def addCssClass(widget, class_):
    """Adds one or more CSS classes to the widget cssClass dynamic Qt property."""
    # Retrieve list of classes
    classes = set(widget.property("cssClass") if widget.property("cssClass") else [])
    # Append given class or list of classes depending on the type of the `class_` parameter
    classes |= set([class_] if isinstance(class_, str) else class_)
    widget.setProperty("cssClass", list(classes))


def removeCssClass(widget, class_):
    """Removes one or more CSS classes from the widget cssClass dynamic Qt property."""
    # Retrieve list of classes
    classes = set(widget.property("cssClass") if widget.property("cssClass") else [])
    # Remove class or list of classes
    classes -= set([class_] if isinstance(class_, str) else class_)
    widget.setProperty("cssClass", list(classes))
