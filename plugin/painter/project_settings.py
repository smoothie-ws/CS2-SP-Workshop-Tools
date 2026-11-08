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
    def contains(key: str) -> bool:
        return sp.js.evaluate(f'alg.project.settings.contains({json.dumps(key)})')
    
    @staticmethod
    def remove(key: str) -> None:
        sp.js.evaluate(f'alg.project.settings.remove({json.dumps(key)})')
    
    @staticmethod
    def get(key: str, default=None):
        result = sp.js.evaluate(
            '(function(key) { return alg.project.settings.contains(key) '
            '? [true, alg.project.settings.value(key)] : [false, null]; })('
            + json.dumps(key) + ')')
        return result[1] if result[0] else default
    
    @staticmethod
    def set(key: str, value) -> None:
        sp.js.evaluate(f'alg.project.settings.setValue({json.dumps(key)}, {json.dumps(value)})')
