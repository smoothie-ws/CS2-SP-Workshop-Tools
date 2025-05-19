import json
import substance_painter as sp

from ..settings import Settings
from ..utils import Log, Path
from ..utils.qml import QmlInternal, QmlView, QtWidgets, QtCore, QtGui


class PluginInternal(QmlInternal):
    def __init__(self):
        super().__init__("CS2WT")
    
    # Slots
    @QtCore.Slot(str, result=str)
    def js(self, code:str):
        try:
            return json.dumps(sp.js.evaluate(code))
        except Exception as e:
            Log.error(f'Failed to evaluate js code: {str(e)}')
            Log.info(code)
    
    @QtCore.Slot(str)
    def info(self, msg:str):
        Log.info(msg)
    
    @QtCore.Slot(str)
    def warning(self, msg:str):
        Log.warning(msg)

    @QtCore.Slot(str)
    def error(self, msg:str):
        Log.error(msg)

    @QtCore.Slot(result=str)
    def pluginPath(self):
        return Settings.plugin_path
    
    @QtCore.Slot(result=str)
    def pluginVersion(self):
        return Settings.plugin_version
    
    @QtCore.Slot(str)
    def showInExplorer(self, path:str):
        Path.show_in_explorer(path)

    @QtCore.Slot(result=str)
    def getPluginSettings(self):
        return json.dumps(Settings.plugin_settings)
    
    @QtCore.Slot(result=str)
    def getCs2Path(self):
        return Settings.get("cs2_path", "")

    @QtCore.Slot(result=str)
    def getWeaponList(self):
        return json.dumps(Settings.get("weapon_list"))
    

plugin_internal = PluginInternal()


class QmlWidget(QmlView):
    def __init__(self):
        super().__init__()
        self.internals = [plugin_internal]
    

class QmlWindow(QmlWidget):
    def __init__(self, title: str, icon:QtGui.QIcon = None, parent: QtWidgets.QWidget = None):
        super().__init__()
        self.window = QtWidgets.QMainWindow(parent)
        self.window.setWindowIcon(icon)
        self.window.setWindowTitle(title)
        self.window.setWindowFlags(QtCore.Qt.WindowType.Window | QtCore.Qt.WindowType.CustomizeWindowHint | QtCore.Qt.WindowType.WindowTitleHint | QtCore.Qt.WindowType.WindowCloseButtonHint)
        self.window.setWindowModality(QtCore.Qt.WindowModality.ApplicationModal)
    
    def load(self, path: str, callback = None):
        def cb(container: QtWidgets.QWidget):
            self.window.setCentralWidget(container)
            if callback is not None:
                callback(container)
        super().load(path, cb)

    def show(self):
        screen_geometry = QtWidgets.QApplication.primaryScreen().availableGeometry()
        x = (screen_geometry.width() - self.window.width()) // 2
        y = (screen_geometry.height() - self.window.height()) // 2
        self.window.move(x, y)
        self.window.show()

    def close(self):
        self.window.close()


class QmlDialogueInternal(QmlInternal):
    def __init__(self, name, view: QmlWindow):
        super().__init__(name)
        self.view = view

    # to override
    def on_confirmed(self):
        pass
    
    def on_rejected(self):
        pass
    
    # Signals
    opened = QtCore.Signal()
    closed = QtCore.Signal()

    # Slots
    @QtCore.Slot(bool)
    def proceed(self, value: bool):
        self.view.close()
        if value:
            self.on_confirmed()
        else:
            self.on_rejected()
