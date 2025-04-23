import substance_painter as sp

from PySide2 import QtWidgets, QtQuick, QtCore, QtQml


class UI:
    def __init__(self, qml_path:str, cs2_path:str, callback, error_callback):
        self.widget = None
        self.cs2_path = cs2_path

        view = QtQuick.QQuickView()
        view.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)
        view.statusChanged.connect(lambda status: self.start(status, view, callback, error_callback))
        view.setSource(QtCore.QUrl.fromLocalFile(qml_path))
    
    def start(self, status:int, view:QtQuick.QQuickView, callback, error_callback):
        if status  == QtQuick.QQuickView.Ready:
            # connect
            self.internal = Internal(self.cs2_path, view.engine().rootContext())
            # add dock widget
            container = QtWidgets.QWidget.createWindowContainer(view)
            container.setWindowTitle("CS2 Workshop Tools")
            self.widget = sp.ui.add_dock_widget(container)
            callback()
        else:
            error_callback(str([e.toString() for e in view.errors()]))

    def close(self):
        if self.widget is not None:
            sp.ui.delete_ui_element(self.widget)

    def request_weapon_textures(self):
        self.internal.emit("request_weapon_textures")


class Internal(QtCore.QObject):
    def __init__(self, cs2_path:str, root:QtQml.QQmlContext):
        super().__init__()
        self.cs2_path = cs2_path
        self.root = root
        self.root.setContextProperty("internal", self)

    def emit(self, signal:str, *args):
        self.root.emit(signal, *args)

    @QtCore.Slot(bool)
    def receive_weapon_textures(self, ans:bool):
        if ans:
            if self.cs2_path is None:
                self.emit("request_cs2_path")

    @QtCore.Slot(str)
    def receive_cs2_path(self, path:str):
        self.cs2_path = path
    