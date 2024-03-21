from PySide2 import QtCore
from substance_painter import js as spjs
import substance_painter.project as spproject


class ShaderBridge(QtCore.QObject):
    """A bridge class that allows communication between PySide2
    and Substance Painter's JavaScript environment. """

    def __init__(self) -> None:
        super().__init__()
        self.shader_id = None

    def set_shader_instance(self, is_project_open):
        self.shader_id = None
        if is_project_open:
            for shader_instance in spjs.evaluate("alg.shaders.instances();"):
                if shader_instance["shader"] == "cs2":
                    self.shader_id = shader_instance["id"]

    # noinspection PyCallingNonCallable
    @QtCore.Slot(str, str)
    def set_parameter_value(self, shader_parameter, value):
        try:
            spjs.evaluate(f"alg.shaders.parameter({self.shader_id}, '{shader_parameter}').value = {value};")
        except RuntimeError:
            pass

    def _get_parameter_value(self, shader_parameter):
        return spjs.evaluate(f"alg.shaders.parameter({self.shader_id}, '{shader_parameter}').value;")

    # noinspection PyCallingNonCallable
    @QtCore.Slot(str, result=bool)
    def get_bool(self, shader_parameter):
        return self._get_parameter_value(shader_parameter)

    # noinspection PyCallingNonCallable
    @QtCore.Slot(str, result=float)
    def get_number(self, shader_parameter):
        return self._get_parameter_value(shader_parameter)

    # noinspection PyCallingNonCallable
    @QtCore.Slot(str, result=list)
    def get_list(self, shader_parameter):
        return self._get_parameter_value(shader_parameter)
