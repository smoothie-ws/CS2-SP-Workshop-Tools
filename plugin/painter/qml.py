import json
import substance_painter as sp

from abc import abstractmethod
from time import localtime, strftime

from .log import Log
from .path import Path
from .plugin import Plugin
from .ui import UI, QtQuickWidgets, QtWidgets, QtCore, QtGui


class QmlView(QtCore.QObject):
    "Bridge class between Python and QML"

    @classmethod
    def view_path(cls, path: str):
        return Path.join(Path.plugin, "view", path)
    
    def __init__(self, name: str = "Plugin", path: str = None):
        super().__init__()
        self.name = name
        self.view = QtQuickWidgets.QQuickWidget()
        self.view.setResizeMode(QtQuickWidgets.QQuickWidget.ResizeMode.SizeRootObjectToView)
        self._on_ready = None
        self.view.statusChanged.connect(self._on_status_changed)
        self.view.engine().warnings.connect(self._on_warnings)
        self.view.rootContext().setContextProperty(self.name, self)
        
        if path is not None:
            self.load(path)
    
    def load(self, path: str, callback = None):
        if Path.exists(path):
            self._on_ready = callback
            self.view.setSource(QtCore.QUrl.fromLocalFile(path))
        else:
            Log.error(f'File {path} does not exist')

    def _on_status_changed(self, status):
        if status == QtQuickWidgets.QQuickWidget.Status.Ready:
            if self._on_ready is not None:
                self._on_ready(self.view)
        elif status == QtQuickWidgets.QQuickWidget.Status.Error:
            Log.error(f'{status}: {[e.toString() for e in self.view.errors()]}')

    @staticmethod
    def _on_warnings(warnings):
        for warning in warnings:
            Log.error(warning.toString())

    # common slots
    @QtCore.Slot(str, result=str)
    def js(self, code: str):
        try:
            res = sp.js.evaluate(code)
        except Exception:
            res = None
        return json.dumps(res)
    
    @QtCore.Slot(result=str)
    def time(self) -> str:
        return strftime("%H:%M:%S", localtime())
    
    @QtCore.Slot(str, result=str)
    def asset(self, path: str) -> str:
        return QtCore.QUrl.fromLocalFile(Path.asset(path)).toString()
    
    @QtCore.Slot(str, result=str)
    def fileName(self, path: str) -> str:
        return Path.filename(path)

    @QtCore.Slot(str, result=str)
    def fileUrl(self, path: str) -> str:
        return QtCore.QUrl.fromLocalFile(path).toString()

    @QtCore.Slot(str, str, result=str)
    def resourcePreview(self, url: str, path: str) -> str:
        view = getattr(self, "view", None)
        if view is not None and view.engine().imageProvider("resources") is not None:
            return "image://resources/" + url
        # Python-created QQuickWidget engines may not have Painter's provider.
        # Keep the valid resource selected even when Qt cannot show a thumbnail
        # (for example grayscale TGA, or an embedded image without a source file).
        if path and Path.exists(path) and QtGui.QImageReader(path).canRead():
            return QtCore.QUrl.fromLocalFile(path).toString()
        return ""

    @QtCore.Slot(str, result=str)
    def localPath(self, url: str) -> str:
        value = QtCore.QUrl(url)
        return value.toLocalFile() if value.isLocalFile() else ""

    @QtCore.Slot(str, bool, result=str)
    def folderUrl(self, path: str, select_folder: bool) -> str:
        if not path:
            path = Path.documents
        elif not select_folder:
            path = Path.to(path)
        return QtCore.QUrl.fromLocalFile(path).toString()

    @QtCore.Slot(str, result=bool)
    def pathExists(self, path: str) -> bool:
        return Path.exists(path)
        
    @QtCore.Slot(str)
    def info(self, msg: str):
        Log.info(msg)
    
    @QtCore.Slot(str)
    def warning(self, msg: str):
        Log.warning(msg)

    @QtCore.Slot(str)
    def error(self, msg: str):
        Log.error(msg)

    @QtCore.Slot(result=str)
    def getPluginPath(self) -> str:
        return Path.plugin
    
    @QtCore.Slot(result=str)
    def getPluginVersion(self) -> str:
        return Plugin.version
    
    @QtCore.Slot(result=str)
    def getPluginSettings(self) -> str:
        return json.dumps(Plugin.settings)
        
    
class QmlWindow(QmlView):
    def __init__(self, title: str, icon: QtGui.QIcon = None, name: str = "Plugin", path: str = None):
        self.window = UI.add_widget(QtWidgets.QMainWindow(
            parent=sp.ui.get_main_window(),
            flags=QtCore.Qt.WindowType.Window | 
                QtCore.Qt.WindowType.CustomizeWindowHint | 
                QtCore.Qt.WindowType.WindowTitleHint | 
                QtCore.Qt.WindowType.WindowCloseButtonHint
        ))
        super().__init__(name, path)
        
        def on_closed(event: QtGui.QCloseEvent):
            self.closed.emit()
            event.accept()
            
        self.window.closeEvent = on_closed
        if icon is not None:
            self.window.setWindowIcon(icon)
        self.window.setWindowTitle(title)
        self.window.setWindowModality(QtCore.Qt.WindowModality.ApplicationModal)
        
    opened = QtCore.Signal()
    closed = QtCore.Signal()
    
    def load(self, path: str, callback = None):
        def cb(container: QtWidgets.QWidget):
            self.window.setCentralWidget(container)
            if callback is not None:
                callback(container)
        super().load(path, cb)

    def show(self):
        screen_geometry = QtWidgets.QApplication.primaryScreen().availableGeometry()
        self.window.move(
            (screen_geometry.width() - self.window.width()) // 2, 
            (screen_geometry.height() - self.window.height()) // 2
        )
        self.window.show()
        
    def open(self):
        self.show()
        self.opened.emit()

    @QtCore.Slot()
    def close(self):
        self.window.close()


class QmlDialog(QmlWindow):
    def close(self):
        super().close()
        self.on_cancelled()

    @QtCore.Slot(str)
    def confirm(self, data: str):
        self.window.close()
        self.on_confirmed(data)

    # to override
    
    @abstractmethod
    def on_confirmed(self, data: str): ...

    @abstractmethod
    def on_cancelled(self): ...
