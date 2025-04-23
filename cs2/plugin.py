import os
import sys
import shutil
import substance_painter as sp
import substance_painter_plugins as sp_plugins

from .log import Log
from .ui import UI

class Plugin:
    cs2_path = None
    plugin_path = None
    documents_path = None

    @staticmethod
    def get_asset_path(*path:list) -> str:
        return os.path.join(Plugin.plugin_path, "assets", *path)

    def __init__(self):
        Plugin.documents_path = sp.js.evaluate("alg.documents_directory")
        for path in sp_plugins.path:
            for plugin in os.listdir(os.path.join(path, "plugins")):
                if plugin == "CS2 Workshop Tools":
                    Plugin.plugin_path = os.path.join(path, "plugins", plugin)

        self.ui = UI(Plugin.cs2_path, Plugin.get_asset_path("ui/view.qml"), self.start, self.fatal)

    def start(self):
        Log.warning("Plugin started")
        if not self.checkout():
            self.ui.request_weapon_textures()

    def close(self):
        Log.warning("Plugin closed")

    def checkout(self):
        sp_shaders_path = os.path.join(Plugin.documents_path, "assets", "shaders")
        sp_shaders_ui_path = os.path.join(sp_shaders_path, "custom-ui")
        
        # shader ui
        shader_ui_path = Plugin.get_asset_path("shader", "ui")
        if not os.path.exists(shader_ui_path):
            shutil.copytree(shader_ui_path, sp_shaders_ui_path)
            shutil.copytree(Plugin.get_asset_path("ui", "SPWidgets"), os.path.join(sp_shaders_ui_path, "cs2"))
        
        # weapon textures
        if not os.path.exists(os.path.join(shader_ui_path, "assets", "textures", "models")):
            return False

        # shader file
        shader_path = os.path.join(sp_shaders_path, "cs2.glsl")
        if not os.path.exists(shader_path):
            shutil.copyfile(Plugin.get_asset_path("shader", "cs2.glsl"), shader_path)

        return True


    def fatal(self, msg:str):
        Log.error("An error occured: " + msg)
        sp_plugins.close_plugin(sys.modules.get(self.__class__.__module__))
        self.ui.close()
