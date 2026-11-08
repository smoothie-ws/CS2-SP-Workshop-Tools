import webbrowser
import substance_painter as sp

from .econ import STYLE_CODES
from .weapon_finish import WeaponFinish
from .shader_ui import install_shader_ui
from .painter import UI, Plugin, Path, QmlView
from .painter.qml import QtWidgets, QtGui
from .controller import MainView, SettingsWindow, WeaponFinishInitWindow


class CS2WT(Plugin):
    main_view: MainView = None
    settings_window: SettingsWindow = None
    wf_init_window: WeaponFinishInitWindow = None

    @classmethod
    def start(cls, path):
        super().start(path, "CS2 Workshop Tools")

    @classmethod
    def on_start(cls):
        styles = Plugin.settings.get("finish_styles", {})
        Plugin.settings["finish_styles"] = {code: styles[code] for code in STYLE_CODES if code in styles}
        defaults = Plugin.settings.get("weapon_finish", {})
        if defaults.get("style") not in STYLE_CODES:
            defaults["style"] = "cu"
        install_shader_ui()
            
        CS2WT.init_ui()
    
    @classmethod
    def on_close(cls):
        WeaponFinish.cancel_pending_setups()
        if WeaponFinish.is_open():
            CS2WT.main_view.pluginAboutToClose.emit()
    
    @classmethod
    def on_project_opened(cls):
        def f():
            if WeaponFinish.is_open():
                WeaponFinish.import_econ()
                CS2WT.main_view.projectKindChanged.emit(2)
            else:
                CS2WT.main_view.projectKindChanged.emit(1)
        sp.project.execute_when_not_busy(f)

    @classmethod
    def on_project_created(cls):
        cls.on_project_opened()

    @classmethod
    def on_project_about_to_save(cls):
        if WeaponFinish.is_open():
            CS2WT.main_view.projectAboutToSave.emit()

    @classmethod
    def on_project_about_to_close(cls):
        CS2WT.main_view.projectKindChanged.emit(0)

    @staticmethod
    def init_ui():
        # plugin menu
        menu = UI.add_menu(QtWidgets.QMenu("CS2 Workshop Tools"))
        menu.addAction("Settings").triggered.connect(CS2WT.on_settings)
        menu.addSeparator()
        menu.addAction("Help...").triggered.connect(CS2WT.on_help)
        menu.addAction("Report a bug...").triggered.connect(CS2WT.on_report_a_bug)
        
        icon = QtGui.QIcon(Path.asset("icons", "logo.png"))
        CS2WT.main_view = MainView(QmlView.view_path("MainView.qml"), icon)
        CS2WT.settings_window = SettingsWindow(QmlView.view_path("SettingsView.qml"), icon)
        CS2WT.wf_init_window = WeaponFinishInitWindow(QmlView.view_path("WeaponFinishInitWindow.qml"), icon)
        
    @staticmethod
    def on_settings():
        CS2WT.settings_window.open()
            
    @staticmethod
    def on_help():
        webbrowser.open("https://github.com/smoothie-ws/CS2-SP-Workshop-Tools?tab=readme-ov-file#table-of-contents")

    @staticmethod
    def on_report_a_bug():
        webbrowser.open("https://github.com/smoothie-ws/CS2-SP-Workshop-Tools/issues")
