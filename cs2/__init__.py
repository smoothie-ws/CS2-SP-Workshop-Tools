import os

import substance_painter.project as spproject
from PySide2.QtCore import QUrl
from PySide2.QtGui import QIcon
from PySide2.QtQuickWidgets import QQuickWidget
from substance_painter import event as spevent
from substance_painter import ui as spui

from .log import Log
from .shader import ShaderBridge


class CS2Plugin:
    plugin_dir = None

    @classmethod
    def set_plugin_dir(cls, plugin_dir):
        cls.plugin_dir = plugin_dir

    @staticmethod
    def get_asset_path(*args):
        return os.path.join(CS2Plugin.plugin_dir, "assets", *args)

    def __init__(self):
        self.shader_bridge = ShaderBridge()
        self.ui = QQuickWidget()
        self.ui.rootContext().setContextProperty("shader_bridge", self.shader_bridge)
        icon = QIcon(self.get_asset_path("icons", "logo.png"))
        qml = QUrl.fromLocalFile(self.get_asset_path("ui", "main.qml"))
        self.ui.setWindowTitle("CS2 Workshop Tools")
        self.ui.setWindowIcon(icon)
        self.ui.setSource(qml)
        self.ui.setResizeMode(QQuickWidget.SizeRootObjectToView)
        self.dock_widget = spui.add_dock_widget(self.ui)

        self.connections = {
            spevent.ProjectOpened: self.on_project_opened,
            spevent.ProjectCreated: self.on_project_created,
            spevent.ProjectAboutToSave: self.on_project_about_to_save,
            spevent.ProjectAboutToClose: self.on_project_about_to_close,
        }
        for event, callback in self.connections.items():
            spevent.DISPATCHER.connect(event, callback)

        self.run()

    def run(self):
        self.shader_bridge.set_shader_instance()
        self.ui.rootObject().set_enabled(self.shader_bridge.is_enabled)

    def stop(self):
        spui.delete_ui_element(self.dock_widget)

    def on_project_opened(self, e):
        self.run()

    def on_project_created(self, e):
        self.run()

    def on_project_about_to_close(self, e):
        self.run()

    def on_project_about_to_save(self, e):
        pass
