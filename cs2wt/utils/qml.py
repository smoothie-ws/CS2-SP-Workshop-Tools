import substance_painter as sp

# qt5 vs qt6 check
if sp.application.version_info() < (10, 1, 0):
    from PySide2 import QtWidgets, QtQuick, QtCore, QtQml, QtGui
else:
    from PySide6 import QtWidgets, QtQuick, QtCore, QtQml, QtGui


class QmlView:
    def __init__(self):
        self.internals: list[QmlInternal] = []
        self.view = QtQuick.QQuickView()
        self.view.setResizeMode(QtQuick.QQuickView.SizeRootObjectToView)

    def load(self, path: str, callback = None):
        if QtCore.QFile.exists(path):
            self.view.statusChanged.connect(lambda status: self.start(status, callback))
            self.view.setSource(QtCore.QUrl.fromLocalFile(path))
        else:
            raise Exception(f'File {path} does not exist')

    def start(self, status: QtQuick.QQuickView.Status, callback = None):
        if status == QtQuick.QQuickView.Ready:
            context = self.view.engine().rootContext()
            for internal in self.internals:
                internal.connect_context(context)
            if callback is not None:
                callback(QtWidgets.QWidget.createWindowContainer(self.view))
        else:
            raise Exception(str([e.toString() for e in self.view.errors()]))
    

class QmlInternal(QtCore.QObject):
    "Bridge class between python and qml"

    def __init__(self, name: str = None):
        super().__init__()
        self.name = name
    
    def connect_context(self, context: QtQml.QQmlContext):
        if self.name is not None:
            context.setContextProperty(self.name, self)
