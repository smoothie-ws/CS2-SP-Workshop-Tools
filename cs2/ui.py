from PySide2.QtCore import QUrl
from PySide2.QtGui import QIcon
from PySide2.QtQuickWidgets import QQuickWidget
from substance_painter import ui as spui

from .assets import AssetBundle
from .shader import ShaderBridge


class ShaderUI(QQuickWidget):
    def __init__(self, assets: AssetBundle, shader_bridge: ShaderBridge):
        super().__init__()
        self.rootContext().setContextProperty("shader_bridge", shader_bridge)
        self.setSource(QUrl.fromLocalFile(assets("shader").fetch("custom-ui.qml")))
        self.setWindowTitle("CS2 Workshop Tools")
        self.setWindowIcon(QIcon(assets("icons").fetch("logo.png")))
        self.setResizeMode(QQuickWidget.SizeRootObjectToView)
        self.dock_widget = spui.add_dock_widget(self)

    def __del__(self):
        spui.delete_ui_element(self.dock_widget)
