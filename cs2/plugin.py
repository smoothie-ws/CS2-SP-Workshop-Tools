import substance_painter as sp

from .internal import Internal
from .ui.qml import QtWidgets
from .ui.widgets import PluginMenu, PluginDockView, PluginSettingsView
from .utils.path import Path


class Plugin:
    widgets = None
    internal = None

    def init():
        Plugin.widgets = []
        Plugin.internal = Internal()

        # plugin menu
        menu = PluginMenu("CS2 Workshop Tools")
        menu.settings_action.triggered.connect(Plugin.settings_window.show)
        menu.help_action.triggered.connect(Plugin.internal.on_help)
        menu.clear_docs_action.triggered.connect(Plugin.internal.on_clear_docs)
        sp.ui.add_menu(menu)

        # dock widget
        dock_view = PluginDockView(menu, Plugin.internal, Path.get_asset_path("ui", "icons", "logo.png"))
        dock_widget = sp.ui.add_dock_widget(QtWidgets.QWidget.createWindowContainer(dock_view))

        # settings window
        Plugin.settings_window = QtWidgets.QMainWindow(menu)
        settings_view = PluginSettingsView(Plugin.settings_window, Plugin.internal, Path.get_asset_path("ui", "icons", "logo.png"))

        Plugin.widgets.append(menu)
        Plugin.widgets.append(dock_widget)

    def close():
        if Plugin.internal is not None:
            Plugin.internal.on_close()
        for widget in Plugin.widgets:
            sp.ui.delete_ui_element(widget)
