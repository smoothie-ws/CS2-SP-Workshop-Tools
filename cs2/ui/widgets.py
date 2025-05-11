import substance_painter as sp

# Qt5 vs Qt6 check
if sp.application.version_info() < (10, 1, 0):
    from PySide2 import QtWidgets, QtQuickWidgets, QtQuick, QtCore, QtGui
else:
    from PySide6 import QtWidgets, QtQuickWidgets, QtQuick, QtCore, QtGui

from ..utils.path import Path

from .qml import QmlView, QmlInternal


class PluginMenu(QtWidgets.QMenu):
    def __init__(self):
        super().__init__()
        
        self.settings_action = self.addAction("Settings")
        self.help_action = self.addAction("Help")
        self.addSeparator()
        self.clear_docs_action = self.addAction("Clear documents")


class PluginSettingsView(QmlView):
    def __init__(self, parent:QtWidgets.QWidget, internal: QmlInternal, icon_path: str):
        super().__init__(
            parent, Path.get_asset_path("ui", "PluginSettingsView.qml"),
            internal, "CS2 Workshop Tools Settings", icon_path
        )


class PluginDockView(QmlView):
    def __init__(self, parent:QtWidgets.QWidget, internal: QmlInternal, icon_path: str):
        super().__init__(
            parent, Path.get_asset_path("ui", "PluginDockView.qml"),
            internal, "CS2 Workshop Tools", icon_path
        )
