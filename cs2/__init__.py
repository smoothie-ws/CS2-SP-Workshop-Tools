import os

from .ui import UI
from .assets import AssetBundle
from .shader import ShaderBridge
from .log import Log


class CS2Plugin:
    def __init__(self, plugin_dir) -> None:
        self.assets = AssetBundle(plugin_dir)("assets")
        self.shader_bridge = ShaderBridge()
        self.ui = UI(self.assets, self.shader_bridge)
        self.checkout(plugin_dir)

    def checkout(self, plugin_dir):
        with open(self.assets.fetch("cfg.json"), "r") as file:
            cfg = file.read()
            
        sp_assets = AssetBundle(os.path.join(os.path.expanduser("~"), 
                                            "Documents", 
                                            "Adobe",
                                            "Adobe Substance 3D Painter", 
                                            "assets"))
        try:
            for src, dst in .items():
                if not self.assets(src) <= sp_assets(dst):
                    self.assets(src).copy_assets(sp_assets(dst).fullpath)
        except Exception as e:
            Log.error(f"An error occured setting up the plugin: {e}")
            return
        Log.warning("The plugin was enabled successfully")

    def __del__(self):
        del self.ui
        Log.warning("The plugin was disabled successfully")