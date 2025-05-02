import substance_painter as sp

# Qt5 vs Qt6 check
if sp.application.version_info() < (10, 1, 0):
    from PySide2 import QtWidgets, QtQuick, QtCore, QtGui
else:
    from PySide6 import QtWidgets, QtQuick, QtCore, QtGui

from .path import Path
from .internal import Internal
from .settings import Settings


class UI:
    def __init__(self):
        self.widgets = []

        self.view = QtQuick.QQuickView()
        self.view.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)
        # connect
        self.internal = Internal(self.view.engine().rootContext())
    
    def load(self, qml_path:str, callback, error_callback):
        if QtCore.QFile.exists(qml_path):
            self.view.statusChanged.connect(
                lambda status: self.start(status, callback, error_callback)
            )
            self.view.setSource(QtCore.QUrl.fromLocalFile(qml_path))

    def start(self, status:int, callback, error_callback):
        if status  == QtQuick.QQuickView.Ready:
            # add dock widget
            container = QtWidgets.QWidget.createWindowContainer(self.view)
            container.setWindowTitle("CS2 Workshop Tools")
            container.setObjectName("CS2WT")
            container.setWindowIcon(QtGui.QIcon(Settings.get_asset_path(Path.join("ui", "icons", "logo.png"))))
            self.widgets.append(sp.ui.add_dock_widget(container))

            # init plugin menu
            menu = QtWidgets.QMenu("CS2 Workshop Tools")
            settings_action = menu.addAction("Settings")
            settings_action.triggered.connect(self.internal.on_settings)
            about_action = menu.addAction("About")
            about_action.triggered.connect(self.internal.on_about)
            menu.addSeparator()
            uninstall_action = menu.addAction("Uninstall")
            uninstall_action.triggered.connect(self.internal.on_uninstall)
            sp.ui.add_menu(menu)
            self.widgets.append(menu)

            callback()
        else:
            error_callback(str([e.toString() for e in self.view.errors()]))

    def close(self):
        for widget in self.widgets:
            sp.ui.delete_ui_element(widget)
