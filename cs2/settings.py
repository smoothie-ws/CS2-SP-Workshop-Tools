import json
import substance_painter as sp
import substance_painter_plugins as sp_plugins

from .log import Log
from .path import Path


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
            for plugin in Path.listdir(Path.join(path, "plugins")):
                if plugin == "CS2 Workshop Tools":
                    Settings.plugin_path = Path.join(path, "plugins", plugin).replace("\\", "/")
        Settings.documents_path = sp.js.evaluate("alg.documents_directory")
        Settings.path = Path.join(Settings.plugin_path, "plugin.json")

        # load data
        data = {}
        if Path.exists(Settings.path):
            try:
                with open(Settings.path, "r", encoding="utf-8") as f:
                    data = json.load(f)
            except:
                pass
        Settings.plugin_files = data.get("files", [])
        Settings.plugin_version = data.get("version", "0.0.1a")
        Settings.plugin_settings = data.get("settings")
        if Settings.plugin_settings is None:
            Settings.reset()

    @staticmethod
    def save():
        with open(Settings.path, "w", encoding="utf-8") as f:
            json.dump({
                "version": Settings.plugin_version,
                "settings": Settings.plugin_settings,
                "files": Settings.plugin_files
            }, f, indent=4, ensure_ascii=False)

    @staticmethod
    def reset():
        try:
            for key, value in Settings.get_defaults():
                Settings.set(key, value)
        except SettingsError as e:
            Log.error(f'Failed to reset plugin settings: {str(e)}')

    @staticmethod
    def get_asset_path(*path:list) -> str:
        return Path.join(Settings.plugin_path, "assets", *path)

    @staticmethod
    def get_defaults():
        defaults_path = Settings.get_asset_path("default_plugin_settings.json")
        if Path.exists(defaults_path):
            try:
                with open(defaults_path, "r", encoding="utf-8") as f:
                    return json.loads(f.read())
            except Exception as e:
                raise SettingsError(f'Failed to get default plugin settings: {str(e)}')
        else:
            raise SettingsError(f'Failed to get default plugin settings: Path `{defaults_path}` does not exist')

    @staticmethod
    def push_file(path: str):
        Settings.plugin_files.append(path)
        Settings.save()

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
    

class SettingsError(Exception):
    pass
