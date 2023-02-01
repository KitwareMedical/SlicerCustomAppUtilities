def applyStyle(widgets, styleSheetFilePath):
    """Set the styleSheet property of each widgets.

    See https://doc.qt.io/qt-5/qwidget.html#styleSheet-prop
    and https://doc.qt.io/qt-5/stylesheet.html
    """
    with open(styleSheetFilePath, "r") as fh:
        styleSheet = fh.read()
        for widget in widgets:
            widget.styleSheet = styleSheet
