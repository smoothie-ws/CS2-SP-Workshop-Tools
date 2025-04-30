import sys
import shutil
import substance_painter as sp
import substance_painter_plugins as sp_plugins

from .ui import UI
from .log import Log
from .path import Path
from .settings import Settings
from .internal import InternalState
from .weapon_finish import WeaponFinish
from .shader import preprocess as shader_preprocess
from .resource import search as resource_search


Settings.plugin_version = "0.0.1a"


class Plugin:
    def __init__(self):
        self.ui = UI()
        self.internal = self.ui.internal
        self.internal.state = InternalState.Preparing
        self.internal.missing_weapon_list = self.checkout_weapon_textures()
        
        self.ui.load(Settings.get_asset_path("ui", "view.qml"), self.start, self.fatal)

    def start(self):
        Log.warning(f'Plugin started (version {Settings.plugin_version})')
        self.internal.emit_textures_are_missing()
        if sp.project.is_open():
            self.internal.on_project_opened()
        connections = {
            sp.event.ProjectOpened: lambda _: self.internal.on_project_opened(),
            sp.event.ProjectAboutToClose: lambda _: self.internal.on_project_about_to_close()
        }
        for event, callback in connections.items():
            sp.event.DISPATCHER.connect_strong(event, callback)

    def close(self):
        if self.internal is not None:
            self.internal.state = InternalState.Closed
        self.ui.close()
        Log.warning("Plugin closed")

    def checkout_weapon_textures(self):
        sp_shaders_path = Path.join(Settings.documents_path, "assets", "shaders")
        sp_shaders_ui_path = Path.join(sp_shaders_path, "custom-ui")

        shader_path = Settings.get_asset_path("shader")

        # shader files
        with open(Settings.get_asset_path("shader", "cs2.glsl"), "r", encoding="utf-8") as f:
            shader_source = f.read()

        for i, fs in enumerate(WeaponFinish.FINISH_STYLES):
            shader_file = f'cs2_{fs}.glsl'
            shader_file_path = Path.join(sp_shaders_path, shader_file)
            if not Path.exists(shader_file_path):
                with open(shader_file_path, "w", encoding="utf-8") as f:
                    f.write(shader_preprocess(shader_source, {"FINISH_STYLE": i}))

        def set_previews(shader_resources):
            for shader_resource in shader_resources:
                name = shader_resource.identifier().name
                shader_resource.set_custom_preview(Settings.get_asset_path("ui", "icons", f'{name}.png'))

        resource_search(set_previews, "your_assets", "shader", "cs2")

        # shader ui
        if not Path.exists(Path.join(sp_shaders_ui_path, "cs2-ui.qml")):
            shutil.copyfile(
                Path.join(shader_path, "cs2-ui.qml"), 
                Path.join(sp_shaders_ui_path, "cs2-ui.qml")
            )

        # weapon textures
        weapon_list = Settings.get("weapon_list", {}).copy()
        models_path = Settings.get_asset_path("textures", "models")
        if Path.exists(models_path):
            for weapon in Path.listdir(models_path):
                weapon_path = Path.join(models_path, weapon)
                if (Path.exists(Path.join(weapon_path, f'{weapon}_color.png')) and
                    Path.exists(Path.join(weapon_path, f'{weapon}_cavity.png')) and
                    Path.exists(Path.join(weapon_path, f'{weapon}_masks.png')) and
                    Path.exists(Path.join(weapon_path, f'{weapon}_rough.png')) and
                    Path.exists(Path.join(weapon_path, f'{weapon}_surface.png'))):
                    if weapon_list.get(weapon) is not None:
                        weapon_list.pop(weapon)

        return weapon_list

    def fatal(self, msg:str):
        Log.error("An error occured: " + msg)
        sp_plugins.close_plugin(sys.modules.get(self.__class__.__module__))
        self.close()
