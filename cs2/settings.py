import os
import json
import substance_painter as sp
import substance_painter_plugins as sp_plugins


class Settings:
    path = None
    plugin_path = None
    documents_path = None
    default_weapon_list = {
        "ak47": "AK-47", 
        "aug": "AUG", 
        "awp": "AWP", 
        "bizon": "PP-Bizon", 
        "cz75a": "CZ75-Auto", 
        "deagle": "Desert Eagle", 
        "elite": "Dual Berettas", 
        "famas": "FAMAS", 
        "fiveseven": "Five-SeveN", 
        "glock18": "Glock-18", 
        "g3sg1": "G3SG1", 
        "galilar": "Galil AR", 
        "mac10": "MAC-10", 
        "m249": "M249", 
        "m4a1_silencer": "M4A1-S", 
        "m4a4": "M4A4", 
        "mag7": "MAG-7", 
        "mp5sd": "MP5-SD", 
        "mp7": "MP7", 
        "mp9": "MP9", 
        "negev": "Negev", 
        "nova": "Nova", 
        "hkp2000": "P2000", 
        "p250": "P250", 
        "p90": "P90", 
        "revolver": "R8 Revolver", 
        "sawedoff": "Sawed-Off", 
        "scar20": "SCAR-20", 
        "sg556": "SG 553", 
        "ssg08": "SSG 08", 
        "tec9": "Tec-9", 
        "ump45": "UMP-45", 
        "usp_silencer": "USP-S", 
        "xm1014": "XM1014", 
        "taser": "Zeus x27"
    }

    @staticmethod
    def get_asset_path(*path:list) -> str:
        return os.path.join(Settings.plugin_path, "assets", *path)

    @staticmethod
    def write(settings:dict):
        with open(Settings.path, "w") as f:
            f.write(json.dumps(settings))
    
    @staticmethod
    def keys() -> dict:
        if os.path.exists(Settings.path):
            with open(Settings.path, "r") as f:
                content = f.read()
        else:
            content = "{}"
        return json.loads(content)
    
    @staticmethod
    def clear():
        Settings.write("{}")
    
    @staticmethod
    def contains(key:str):
        return Settings.get(key) is not None
    
    @staticmethod
    def remove(key:str):
        settings = Settings.keys()
        settings.pop(key)
        Settings.write(settings)
    
    @staticmethod
    def get(key:str):
        return Settings.keys().get(key)
    
    @staticmethod
    def set(key:str, value):
        settings = Settings.keys()
        settings[key] = value
        Settings.write(settings)


for path in sp_plugins.path:
    for plugin in os.listdir(os.path.join(path, "plugins")):
        if plugin == "CS2 Workshop Tools":
            Settings.plugin_path = os.path.join(path, "plugins", plugin)
Settings.documents_path = sp.js.evaluate("alg.documents_directory")
Settings.path = os.path.join(Settings.plugin_path, "settings.json")
