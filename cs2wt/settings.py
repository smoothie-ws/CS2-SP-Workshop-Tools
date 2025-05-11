import os
import json
import substance_painter as sp
import substance_painter_plugins as sp_plugins


class Settings:
    path = None
    plugin_path = None
    documents_path = None

    plugin_files: list[str] = None
    plugin_version: str = None
    plugin_settings: dict = None

    @staticmethod
    def load():
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
                    data = json.load(f)
            except:
                pass
        Settings.plugin_files = data.get("files", [])
        Settings.plugin_version = data.get("version", "0.0.1a")
        Settings.plugin_settings = data.get("settings", {})

    @staticmethod
    def save():
        data = {
            "version": Settings.plugin_version,
            "settings": Settings.plugin_settings,
            "files": Settings.plugin_files
        }
        with open(Settings.path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4, ensure_ascii=False)

    @staticmethod
    def push_file(path: str):
        Settings.plugin_files.append(path)
        Settings.save()

    @staticmethod
    def keys() -> list:
        return Settings.plugin_settings.keys()
    
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
