import webbrowser
import substance_painter as sp

from .weapon_finish import WeaponFinish
from .painter import UI, Log, Plugin, Macro, Path, QmlView, Resource, Updates
from .painter.qml import QtWidgets, QtGui
from .controller import MainView, UpdateWindow, SettingsWindow, WeaponFinishInitWindow


class CS2WT(Plugin):
    main_view: MainView = None
    update_window: UpdateWindow = None
    settings_window: SettingsWindow = None
    wf_init_window: WeaponFinishInitWindow = None
    
    @classmethod
    def start(cls, path):
        super().start(path, "CS2 Workshop Tools")
        try:
            latest, commits_raw = Updates.check_for_updates("smoothie-ws/CS2-SP-Workshop-Tools", f'v{Plugin.version}')
            if latest and commits_raw:
                commits_added = []
                commits_fixed = []
                commits_misc = []
                for commit in commits_raw:
                    msg: str = commit["message"]
                    if msg.startswith("feat:"):
                        commit["message"] = msg[5:]
                        commits_added.append(commit)
                    elif msg.startswith("fix:"):
                        commit["message"] = msg[4:]
                        commits_fixed.append(commit)
                    else:
                        commits_misc.append(commit)
                        
                CS2WT.update_window.open(latest, [
                    { "name": "Added", "color": "#206332", "commits": commits_added },
                    { "name": "Fixed", "color": "#204E63", "commits": commits_fixed },
                    { "name": "Misc", "color": "#612063", "commits": commits_misc }
                ])
        except Exception as e:
            Log.info(f'Failed to check for updates: {e}')

    @classmethod
    def on_start(cls):
        CS2WT.checkout()
        CS2WT.init_ui()
    
    @classmethod
    def on_close(cls):
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
        CS2WT.update_window = UpdateWindow(QmlView.view_path("UpdateWindow.qml"), icon)
        CS2WT.settings_window = SettingsWindow(QmlView.view_path("SettingsView.qml"), icon)
        CS2WT.wf_init_window = WeaponFinishInitWindow(QmlView.view_path("WeaponFinishInitWindow.qml"), icon)
        
    @staticmethod
    def checkout():
        # shader files
        sp_shaders_path = Path.join(Path.documents, "assets", "shaders")
        sp_shaders_ui_path = Path.join(sp_shaders_path, "custom-ui")

        with open(Path.asset("shader", "cs2.glsl"), "r", encoding="utf-8") as f:
            shader_source = f.read()

        shader_path = Path.asset("shader")
        for i, fs in enumerate(WeaponFinish.FINISH_STYLES):
            sp_shader_file_path = Path.join(sp_shaders_path, f'cs2_{fs}.glsl')
            if not Path.exists(sp_shader_file_path):
                with open(sp_shader_file_path, "w", encoding="utf-8") as f:
                    f.write(Macro.process(shader_source, {"FINISH_STYLE": i}))

        def set_previews(shader_resources):
            for shader_resource in shader_resources:
                name = shader_resource.identifier().name
                path = Path.asset("ui", "icons", f'{name}.png')
                if Path.exists(path):
                    shader_resource.set_custom_preview(path)
        Resource.search_resource(set_previews, "your_assets", "shader", "cs2")

        # shader ui
        sp_shader_ui_path = Path.join(sp_shaders_ui_path, "cs2-ui.qml")
        if not Path.exists(Path.join(sp_shaders_ui_path, "ui.qml")):
            Path.copy(Path.join(shader_path, "ui.qml"), sp_shader_ui_path)
        
        # environment files
        sp_env_path = Path.join(Path.documents, "assets", "environments")
        env_path = Path.asset("maps")
        for m in Path.listdir(env_path):
            sp_env_file_path = Path.join(sp_env_path, m)
            if not Path.exists(sp_env_file_path):
                Path.copy(Path.join(env_path, m), sp_env_file_path)
                
    @staticmethod
    def on_settings():
        CS2WT.settings_window.open()
            
    @staticmethod
    def on_help():
        webbrowser.open(f'https://github.com/{REPO}?tab=readme-ov-file#table-of-contents')

    @staticmethod
    def on_report_a_bug():
        webbrowser.open(f'https://github.com/{REPO}/issues')
