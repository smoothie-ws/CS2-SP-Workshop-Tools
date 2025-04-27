import os
import json
import substance_painter as sp
import substance_painter_plugins as sp_plugins


class Settings:
    path = None
    plugin_path = None
    documents_path = None

    plugin_version: str = None
    plugin_settings: dict = None

    @staticmethod
    def _init():
        # init paths
        for path in sp_plugins.path:
            for plugin in os.listdir(os.path.join(path, "plugins")):
                if plugin == "CS2 Workshop Tools":
                    Settings.plugin_path = os.path.join(path, "plugins", plugin).replace("\\", "/")
        Settings.documents_path = sp.js.evaluate("alg.documents_directory")
        Settings.path = os.path.join(Settings.plugin_path, "plugin.json")

        # load data
        data = {}
        if os.path.exists(Settings.path):
            try:
                with open(Settings.path, "r", encoding="utf-8") as f:
                    data = json.loads(f.read())
            except:
                pass
        Settings.plugin_version = data.get("version", "0.0.1a")
        Settings.plugin_settings = data.get("settings")
        if Settings.plugin_settings is None:
            Settings.reset()

    @staticmethod
    def dump():
        with open(Settings.path, "w", encoding="utf-8") as f:
            json.dump({
                "version": Settings.plugin_version,
                "settings": Settings.plugin_settings
            }, f, indent=4, ensure_ascii=False)

    @staticmethod
    def reset():
        defaults_path = os.path.join(Settings.plugin_path, "default_settings.json")
        if os.path.exists(defaults_path):
            try:
                with open(defaults_path, "r", encoding="utf-8") as f:
                    Settings.plugin_settings = json.loads(f.read())
            except:
                pass

    @staticmethod
    def get_asset_path(*path:list) -> str:
        return os.path.join(Settings.plugin_path, "assets", *path)

    @staticmethod
    def keys() -> dict:
        return Settings.plugin_settings
    
    @staticmethod
    def clear():
        Settings.plugin_settings = {}
    
    @staticmethod
    def contains(key:str):
        return Settings.plugin_settings.get(key) is not None
    
    @staticmethod
    def remove(key:str):
        Settings.plugin_settings.pop(key)
    
    @staticmethod
    def get(key:str, default=None):
        return Settings.plugin_settings.get(key, default)
    
    @staticmethod
    def set(key:str, value):
        Settings.plugin_settings[key] = value
    