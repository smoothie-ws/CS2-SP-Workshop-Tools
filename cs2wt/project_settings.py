import json
import substance_painter as sp


class ProjectSettings:
    @staticmethod
    def keys() -> list:
        return sp.js.evaluate("alg.project.settings.keys()")
    
    @staticmethod
    def clear() -> None:
        sp.js.evaluate("alg.project.settings.clear()")
    
    @staticmethod
    def contains(key:str) -> bool:
        return sp.js.evaluate(f'alg.project.settings.contains("{key}")')
    
    @staticmethod
    def remove(key:str) -> None:
        sp.js.evaluate(f'alg.project.settings.remove("{key}")')
    
    @staticmethod
    def get(key:str, default=None):
        if ProjectSettings.contains(key):
            return sp.js.evaluate(f'alg.project.settings.value("{key}")')
        return default
    
    @staticmethod
    def set(key:str, value=None) -> None:
        sp.js.evaluate(f'alg.project.settings.setValue("{key}", {json.dumps(value)})')
