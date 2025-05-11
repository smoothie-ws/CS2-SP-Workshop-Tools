import substance_painter as sp

# Qt5 vs Qt6 check
if sp.application.version_info() < (10, 1, 0):
    from PySide2 import QtWidgets, QtQuickWidgets, QtQuick, QtCore, QtGui, QtQml
else:
    from PySide6 import QtWidgets, QtQuickWidgets, QtQuick, QtCore, QtGui, QtQml


class QmlInternal(QtCore.QObject):
    "Bridge class between python and qml"

    def __init__(self, name: str):
        super().__init__()
        self.name = name
    
    def connect_context(self, context: QtQml.QQmlContext):
        context.setContextProperty(self.name, self)


class QmlView(QtWidgets.QWidget):
    def __init__(self, parent:QtWidgets.QWidget, path: str, internal: QmlInternal, title: str=None, icon_path: str=None):
        super().__init__(parent)

        self.internal = internal

        self.setWindowTitle(title)
        self.setWindowIcon(QtGui.QIcon(icon_path))
        self.setWindowModality(QtCore.Qt.ApplicationModal)

        self.view = QtQuickWidgets.QQuickWidget()
        self.view.setResizeMode(QtQuickWidgets.QQuickWidget.SizeRootObjectToView)

        if QtCore.QFile.exists(path):
            self.view.statusChanged.connect(self.start)
            self.view.setSource(QtCore.QUrl.fromLocalFile(path))
    
    def start(self, status: int):
        if status  == QtQuick.QQuickView.Ready:
            self.internal.connect_context(self.view.engine().rootContext())
        else:
            raise QmlError(str([e.toString() for e in self.view.errors()]))


class QmlError(Exception):
    pass
