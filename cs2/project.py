import substance_painter as sp


class Project:
    def __init__(self):
        self.settings = ProjectSettings
        self.name = sp.project.name()
        self.is_weapon_finish = self.settings.get("finish_style") is not None


class ProjectSettings:
    @staticmethod
    def keys() -> list:
        return sp.js.evaluate("alg.project.settings.keys()")
    
    @staticmethod
    def clear():
        sp.js.evaluate("alg.project.settings.clear()")
    
    @staticmethod
    def contains(key:str):
        return sp.js.evaluate(f'alg.project.settings.contains("{key}")')
    
    @staticmethod
    def remove(key:str):
        sp.js.evaluate(f'alg.project.settings.remove("{key}")')
    
    @staticmethod
    def get(key:str):
        if ProjectSettings.contains(key):
            return sp.js.evaluate(f'alg.project.settings.value("{key}")')
        return None
    
    @staticmethod
    def set(key:str, value):
        if isinstance(value, str):
            sp.js.evaluate(f'alg.project.settings.setValue("{key}", "{value}")')
        else:
            sp.js.evaluate(f'alg.project.settings.setValue("{key}", {value})')
