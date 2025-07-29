import json

from .painter import UI, Path, Plugin
from .painter.qml import QtWidgets, QmlView, QtCore


class DockView(QmlView):
    "Example of the qml controller class"
    
    def __init__(self, path: str):
        super().__init__("Plugin")
        
        def cb(container: QtWidgets.QWidget):
            container.setWindowTitle("Python Plugin")
            UI.add_dock(container)

        self.load(path, cb)
        
    @QtCore.Slot(result=str)
    def getPluginPath(self):
        return Path.plugin
    
    @QtCore.Slot(result=str)
    def getPluginVersion(self):
        return Plugin.version
    
    @QtCore.Slot(result=str)
    def getPluginSettings(self):
        return json.dumps(Plugin.settings)
