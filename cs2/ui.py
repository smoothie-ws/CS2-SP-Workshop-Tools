import os
import substance_painter as sp

# Qt5 vs Qt6 check
if sp.application.version_info() < (10, 1, 0):
    from PySide2 import QtWidgets, QtQuick, QtCore, QtGui
else:
    from PySide6 import QtWidgets, QtQuick, QtCore, QtGui

from .internal import Internal
from .settings import Settings


class UI:
    def __init__(self):
        self.widgets = []
    
    def load(self, qml_path:str, callback, error_callback):
        view = QtQuick.QQuickView()
        view.statusChanged.connect(lambda status: self.start(status, view, callback, error_callback))
        view.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)
        if QtCore.QFile.exists(qml_path):
            view.setSource(QtCore.QUrl.fromLocalFile(qml_path))

    def start(self, status:int, view:QtQuick.QQuickView, callback, error_callback):
        if status  == QtQuick.QQuickView.Ready:
            # connect
            internal = Internal(view.engine().rootContext())
            # add dock widget
            container = QtWidgets.QWidget.createWindowContainer(view)
            container.setWindowTitle("CS2 Workshop Tools")
            container.setObjectName("CS2WT")
            container.setWindowIcon(QtGui.QIcon(Settings.get_asset_path(os.path.join("ui", "icons", "logo.png"))))
            self.widgets.append(sp.ui.add_dock_widget(container))
            callback(internal)
        else:
            error_callback(str([e.toString() for e in view.errors()]))

    def close(self):
        for widget in self.widgets:
            sp.ui.delete_ui_element(widget)
