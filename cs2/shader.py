from PySide2 import QtCore
from substance_painter import js as spjs


class ShaderBridge(QtCore.QObject):
    """A bridge class that allows communication between PySide2
    and Substance Painter's JavaScript environment. """

    def __init__(self) -> None:
        super().__init__()
        self.shader_id = None

    @property
    def is_enabled(self):
        return self.shader_id is not None
    
    def set_shader_instance(self):
        self.shader_id = None
        try:
            for shader_instance in spjs.evaluate("alg.shaders.instances();"):
                if shader_instance["shader"] == "cs2":
                    self.shader_id = shader_instance["id"]
        except RuntimeError:
            pass

    @QtCore.Slot(str, str)
    def set_parameter_value(self, shader_parameter, value):
        if self.shader_id is not None:
            spjs.evaluate(f"alg.shaders.parameter({self.shader_id}, '{shader_parameter}').value = {value};")

    def _get_parameter_value(self, shader_parameter):
        if self.shader_id is not None:
            return spjs.evaluate(f"alg.shaders.parameter({self.shader_id}, '{shader_parameter}').value;")

    @QtCore.Slot(str, result=bool)
    def get_bool(self, shader_parameter):
        return self._get_parameter_value(shader_parameter)

    @QtCore.Slot(str, result=float)
    def get_number(self, shader_parameter):
        return self._get_parameter_value(shader_parameter)

    @QtCore.Slot(str, result=list)
    def get_list(self, shader_parameter):
        return self._get_parameter_value(shader_parameter)
