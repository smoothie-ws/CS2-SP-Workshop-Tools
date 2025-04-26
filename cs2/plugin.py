import os
import sys
import shutil
import substance_painter as sp
import substance_painter_plugins as sp_plugins

from .ui import UI
from .log import Log
from .settings import Settings
from .internal import Internal, InternalState


class Plugin:
    def __init__(self):
        self.internal = None
        self.ui = UI()
        self.ui.load(Settings.get_asset_path("ui/view.qml"), self.start, self.fatal)

    def start(self, internal:Internal):
        Log.warning("Plugin started")
        self.internal = internal
        self.internal.state = InternalState.Started
        self.internal.push_weapon_list(self.checkout())
        if sp.project.is_open():
            self.internal.init_project()

        connections = {
            sp.event.ProjectOpened: self.on_project_opened,
            sp.event.ProjectCreated: self.on_project_created,
            sp.event.ProjectAboutToSave: self.on_project_about_to_save,
            sp.event.ProjectAboutToClose: self.on_project_about_to_close
        }
        for event, callback in connections.items():
            sp.event.DISPATCHER.connect(event, callback)

    def on_project_opened(self, _):
        self.internal.init_project()

    def on_project_created(self, _):
        self.internal.init_project()
        
    def on_project_about_to_save(self, _):
        project = self.internal.project
        if project.is_weapon_finish:
            project.sync_econ()

    def on_project_about_to_close(self, _):
        self.internal.projectKindChanged.emit(0)
        
    def close(self):
        self.ui.close()
        if self.internal is not None:
            self.internal.state = InternalState.Closed
        Log.warning("Plugin closed")

    def checkout(self):
        # weapon list
        if not Settings.contains("weapon_list"):
            Settings.set("weapon_list", Settings.default_weapon_list)

        sp_shaders_path = os.path.join(Settings.documents_path, "assets", "shaders")
        sp_shaders_ui_path = os.path.join(sp_shaders_path, "custom-ui")

        # shader file
        if not os.path.exists(os.path.join(sp_shaders_path, "cs2.glsl")):
            shelf = sp.resource.Shelf("your_assets")
            shader_path = Settings.get_asset_path("shader", "cs2.glsl")
            shader_resource = shelf.import_resource(shader_path, sp.resource.Usage.SHADER)
            shader_resource.set_custom_preview(Settings.get_asset_path("ui", "icons", "logo_shader.png"))

        # shader ui
        shader_ui_path = Settings.get_asset_path("shader", "ui")
        sp_shader_ui_path = os.path.join(sp_shaders_ui_path, "cs2")
        if not os.path.exists(sp_shader_ui_path):
            shutil.copytree(shader_ui_path, sp_shader_ui_path)
        # spwidgets
        spwidgets_path = os.path.join(sp_shader_ui_path, "SPWidgets")
        if not os.path.exists(spwidgets_path):
            shutil.copytree(Settings.get_asset_path("ui", "SPWidgets"), spwidgets_path)

        # textures
        tex_path = os.path.join(sp_shader_ui_path, "assets", "textures")
        if not os.path.exists(tex_path):
            shutil.copytree(os.path.join(shader_ui_path, "assets", "textures"), tex_path)
            
        # weapon textures
        weapon_list:dict = Settings.get("weapon_list")
        models_path = os.path.join(sp_shader_ui_path, "assets", "textures", "models")
        if os.path.exists(models_path):
            weapons = os.listdir(models_path)
            for weapon in weapons:
                weapon_path = os.path.join(models_path, weapon)
                if (os.path.exists(os.path.join(weapon_path, f'{weapon}_color.png')) and
                    os.path.exists(os.path.join(weapon_path, f'{weapon}_cavity.png')) and
                    os.path.exists(os.path.join(weapon_path, f'{weapon}_masks.png')) and
                    os.path.exists(os.path.join(weapon_path, f'{weapon}_rough.png')) and
                    os.path.exists(os.path.join(weapon_path, f'{weapon}_surface.png'))):
                    if weapon_list.get(weapon) is not None:
                        weapon_list.pop(weapon)

        return weapon_list

    def fatal(self, msg:str):
        Log.error("An error occured: " + msg)
        sp_plugins.close_plugin(sys.modules.get(self.__class__.__module__))
        self.close()
