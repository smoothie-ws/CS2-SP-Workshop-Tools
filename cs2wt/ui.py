import substance_painter as sp

# Qt5 vs Qt6 check
if sp.application.version_info() < (10, 1, 0):
    from PySide2 import QtWidgets, QtQuick, QtCore, QtQml, QtGui
else:
    from PySide6 import QtWidgets, QtQuick, QtCore, QtQml, QtGui

from .utils import Path
from .internal import Internal


class UI:
    widgets = None
    internal = None

    settings_window = None

    @staticmethod
    def init(internal: Internal):
        UI.widgets = []
        UI.internal = internal

        icon = QtGui.QIcon(Path.get_asset_path("ui", "icons", "logo.png"))

        # plugin menu
        menu = QtWidgets.QMenu("CS2 Workshop Tools")
        menu.settings_action = menu.addAction("Settings")
        menu.help_action = menu.addAction("Help")
        menu.addSeparator()
        menu.clear_docs_action = menu.addAction("Clear documents")

        # dock widget
        view_path = Path.get_asset_path("ui", "view.qml")
        view = QtQuick.QQuickView()
        view.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)

        def cb(status):
            if status == QtQuick.QQuickView.Ready:
                UI.internal.connect_context(view.engine().rootContext())
                container = QtWidgets.QWidget.createWindowContainer(view)
                container.setWindowTitle("CS2 Workshop Tools")
                container.setWindowIcon(icon)
                UI.widgets.append(sp.ui.add_dock_widget(container))
            else:
                raise Exception(str([e.toString() for e in view.errors()]))

        if QtCore.QFile.exists(view_path):
            view.statusChanged.connect(cb)
            view.setSource(QtCore.QUrl.fromLocalFile(view_path))

        # connections
        menu.settings_action.triggered.connect(UI.internal.on_settings)
        menu.help_action.triggered.connect(UI.internal.on_help)
        menu.clear_docs_action.triggered.connect(UI.internal.on_clear_docs)

        sp.ui.add_menu(menu)
        UI.widgets.append(menu)

    @staticmethod
    def close():
        if UI.internal is not None:
            UI.internal.on_close()
        for widget in UI.widgets:
            sp.ui.delete_ui_element(widget)
