import webbrowser

from .utils import Shader
from .weapon_finish import WeaponFinish
from .painter import UI, Plugin, Path, QmlView, Resource
from .painter.qml import QtWidgets, QtGui
from .controller import DockView, SettingsWindow, ClearDocsWindow


class CS2WT(Plugin):
    dock_view: DockView = None
    settings_window: SettingsWindow = None
    clear_docs_window: ClearDocsWindow = None

    @classmethod
    def start(cls, path):
        super().start(path, "CS2 Workshop Tools")
        
    @classmethod
    def on_start(cls):
        icon = QtGui.QIcon(Path.asset("ui", "icons", "logo.png"))
        
        # plugin menu
        menu = UI.add_menu(QtWidgets.QMenu("CS2 Workshop Tools"))
        
        menu.addAction("Help").triggered.connect(CS2WT.on_help)
        menu.addAction("Settings").triggered.connect(CS2WT.on_settings)
        menu.addSeparator()
        menu.addAction("Clear documents").triggered.connect(CS2WT.on_clear_docs)
        # dock widget
        CS2WT.dock_view = DockView(QmlView.plugin_file("DockView.qml"), icon)
        # settings window
        CS2WT.settings_window = SettingsWindow(QmlView.plugin_file("SettingsView.qml"), icon)
        # clear docs window
        CS2WT.clear_docs_window = ClearDocsWindow(QmlView.plugin_file("ClearDocsView.qml"), icon)
        
        CS2WT.checkout_weapon_textures()
        
    @classmethod
    def on_close(cls):
        if WeaponFinish.is_open():
            CS2WT.dock_view.pluginAboutToClose.emit()
    
    @classmethod
    def on_project_opened(cls):
        if WeaponFinish.is_open():
            CS2WT.dock_view.projectKindChanged.emit(2)
        else:
            CS2WT.dock_view.projectKindChanged.emit(1)

    @classmethod
    def on_project_about_to_close(cls):
        CS2WT.dock_view.projectKindChanged.emit(0)

    @staticmethod
    def on_help():
        webbrowser.open("https://github.com/smoothie-ws/CS2-SP-Workshop-Tools?tab=readme-ov-file#table-of-contents")

    @staticmethod
    def on_settings():
        CS2WT.settings_window.open()

    @staticmethod
    def on_clear_docs():
        CS2WT.clear_docs_window.open()

    @staticmethod
    def checkout_weapon_textures():
        sp_shaders_path = Path.join(Path.documents, "assets", "shaders")
        sp_shaders_ui_path = Path.join(sp_shaders_path, "custom-ui")

        # shader files
        with open(Path.asset("shader", "cs2.glsl"), "r", encoding="utf-8") as f:
            shader_source = f.read()

        shader_path = Path.asset("shader")
        for i, fs in enumerate(WeaponFinish.FINISH_STYLES):
            sp_shader_file_path = Path.join(sp_shaders_path, f'cs2_{fs}.glsl')
            if not Path.exists(sp_shader_file_path):
                with open(sp_shader_file_path, "w", encoding="utf-8") as f:
                    f.write(Shader.process(shader_source, {"FINISH_STYLE": i}))
                    Plugin.push_file(sp_shader_file_path)

        def set_previews(shader_resources):
            for shader_resource in shader_resources:
                name = shader_resource.identifier().name
                path = Path.asset("ui", "icons", f'{name}.png')
                if Path.exists(path):
                    shader_resource.set_custom_preview(path)
        Resource.search(set_previews, "your_assets", "shader", "cs2")

        # shader ui
        sp_shader_ui_path = Path.join(sp_shaders_ui_path, "cs2-ui.qml")
        if not Path.exists(Path.join(sp_shaders_ui_path, "ui.qml")):
            Path.copy(Path.join(shader_path, "ui.qml"), sp_shader_ui_path)
            Plugin.push_file(sp_shader_ui_path)

        # weapon textures
        weapon_list = Plugin.settings.get("weapon_list", {}).copy()
        models_path = Path.asset("textures", "models")
        if Path.exists(models_path):
            for weapon in Path.listdir(models_path):
                flag = True
                weapon_path = Path.join(models_path, weapon)
                for tex in ["color", "cavity", "masks", "rough", "surface"]:
                    if not Path.exists(Path.join(weapon_path, f'{weapon}_{tex}.png')):
                        flag = False
                        break
                    
                if flag and weapon_list.get(weapon) is not None:
                    weapon_list.pop(weapon)
                    
        if len(weapon_list) > 0 and not Plugin.settings.get("ignore_textures_are_missing"):
            CS2WT.dock_view.texturesAreMissing.emit()

    @staticmethod
    def emit_cs2_path_is_missing():
        CS2WT.dock_view.cs2PathIsMissing.emit()
