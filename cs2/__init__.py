import os
import json
from substance_painter import event as spevent
from .ui import ShaderUI
from .assets import AssetBundle
from .shader import ShaderBridge
from .log import Log


class CS2Plugin:
    def __init__(self, plugin_dir) -> None:
        self.plugin_dir = plugin_dir
        self.assets = None
        self.shader_bridge = None
        self.shader_ui = None

        # Subscribe to project related events.
        connections = {
            spevent.ProjectOpened: self.on_project_opened,
            spevent.ProjectCreated: self.on_project_created,
            spevent.ProjectAboutToSave: self.on_project_about_to_save
        }
        for event, callback in connections.items():
            spevent.DISPATCHER.connect(event, callback)

    def enable(self):
        self.assets = AssetBundle(self.plugin_dir)("assets")
        self._checkout()

    def run(self):
        self.shader_bridge = ShaderBridge()
        self.shader_ui = ShaderUI(self.assets, self.shader_bridge)

    def _checkout(self):
        with open(self.assets.fetch("cfg.json"), "r") as file:
            plugin_cfg = json.loads(file.read())
            plugin_settings = plugin_cfg["SETTINGS"]

        sp_assets = AssetBundle(os.path.join(os.path.expanduser("~"), 
                                            "Documents", 
                                            "Adobe",
                                            "Adobe Substance 3D Painter", 
                                            "assets"))

        try:
            for src, dst in plugin_settings["ASSETS"].items():
                if not self.assets(src) <= sp_assets(dst):
                    self.assets(src).copy_assets(sp_assets(dst).fullpath)
        except Exception as e:
            Log.error(f"An error occured setting up the plugin: {e}")
            return
        Log.warning("The plugin was enabled successfully")

    def disable(self):
        del self.shader_ui
        Log.warning("The plugin was disabled successfully")

    def on_project_opened(self, e):
        self.run()

    def on_project_created(self, e):
        self.run()

    def on_project_about_to_save(self, e):
        pass