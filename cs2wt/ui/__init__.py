
import webbrowser
import substance_painter as sp

from ..utils import Path
from ..settings import Settings

from .qml import QmlDialogueInternal, QmlWindow, QtWidgets, QtCore, QtGui
from .dock_view import DockView


class UI:
    menu: QtWidgets.QMenu = None
    dock_view: DockView = None
    settings_window: QmlWindow = None
    clear_docs_window: QmlWindow = None

    @staticmethod
    def init():
        icon = QtGui.QIcon(Path.get_asset_path("ui", "icons", "logo.png"))

        # plugin menu
        UI.menu = QtWidgets.QMenu("CS2 Workshop Tools")
        UI.menu.help_action = UI.menu.addAction("Help")
        UI.menu.settings_action = UI.menu.addAction("Settings")
        UI.menu.addSeparator()
        UI.menu.clear_docs_action = UI.menu.addAction("Clear documents")

        UI.menu.help_action.triggered.connect(UI.on_help)
        UI.menu.settings_action.triggered.connect(UI.on_settings)
        UI.menu.clear_docs_action.triggered.connect(UI.on_clear_docs)

        sp.ui.add_menu(UI.menu)

        # dock widget
        UI.dock_view = DockView(Path.get_asset_path("ui", "DockView.qml"), icon)

        # settings window
        UI.settings_window = QmlWindow("CS2 Workshop Tools Settings", icon, UI.menu)
        UI.settings_window.window.setMinimumSize(735, 425)
        UI.settings_window.internals.append(SettingsWindowInternal(UI.settings_window))
        UI.settings_window.load(Path.get_asset_path("ui", "SettingsView.qml"))

        # clear docs window
        UI.clear_docs_window = QmlWindow("Clear CS2 Workshop Tools Documents", icon, UI.menu)
        UI.clear_docs_window.window.setMinimumSize(400, 250)
        UI.clear_docs_window.internals.append(ClearDocsWindowInternal(UI.clear_docs_window))
        UI.clear_docs_window.load(Path.get_asset_path("ui", "ClearDocsView.qml"))
        
    @staticmethod
    def close():
        sp.ui.delete_ui_element(UI.menu)
        sp.ui.delete_ui_element(UI.dock_view.widget)
    
    @staticmethod
    def on_help():
        webbrowser.open("https://github.com/smoothie-ws/CS2-SP-Workshop-Tools?tab=readme-ov-file#table-of-contents")

    @staticmethod
    def on_settings():
        UI.settings_window.internal.opened.emit()
        UI.settings_window.show()

    @staticmethod
    def on_clear_docs():
        UI.clear_docs_window.internal.opened.emit()
        UI.clear_docs_window.show()


class SettingsWindowInternal(QmlDialogueInternal):
    def __init__(self, view):
        super().__init__("Settings", view)
    
    def on_confirmed(self):
        pass
    
    def on_rejected(self):
        pass


class ClearDocsWindowInternal(QmlDialogueInternal):
    def __init__(self, view):
        super().__init__("ClearDocs", view)
    
    # Signals
    opened = QtCore.Signal()

    def on_confirmed(self):
        for path in Settings.get("files", []):
            Path.remove(path)
    
    def on_rejected(self):
        pass
    