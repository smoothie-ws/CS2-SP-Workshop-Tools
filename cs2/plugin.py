import sys
import shutil
import substance_painter as sp
import substance_painter_plugins as sp_plugins

from .ui import UI
from .log import Log
from .path import Path
from .settings import Settings
from .internal import InternalState


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
            self.internal.init_project()
        connections = {
            sp.event.ProjectOpened: self.on_project_opened,
            sp.event.ProjectAboutToClose: self.on_project_about_to_close
        }
        for event, callback in connections.items():
            sp.event.DISPATCHER.connect(event, callback)

    def on_project_opened(self, _):
        self.internal.on_project_opened()
        
    def on_project_about_to_close(self, _):
        self.internal.on_project_about_to_close()
        
    def close(self):
        self.ui.close()
        if self.internal is not None:
            self.internal.state = InternalState.Closed
        Log.warning("Plugin closed")

    def checkout_weapon_textures(self):
        sp_shaders_path = Path.join(Settings.documents_path, "assets", "shaders")
        sp_shaders_ui_path = Path.join(sp_shaders_path, "custom-ui")

        shader_path = Settings.get_asset_path("shader")

        # shader file
        if not Path.exists(Path.join(sp_shaders_path, "cs2.glsl")):
            shelf = sp.resource.Shelf("your_assets")
            shader_resource = shelf.import_resource(Path.join(shader_path, "cs2.glsl"), sp.resource.Usage.SHADER)
            shader_resource.set_custom_preview(Settings.get_asset_path("ui", "icons", "logo_shader.png"))

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
