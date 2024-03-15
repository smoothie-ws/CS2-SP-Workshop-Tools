from PySide2 import QtCore
from substance_painter import js as spjs
from .log import Log

class ShaderBridge(QtCore.QObject):
    """A bridge class that allows communication between PySide2
    and Substance Painter's JavaScript environment. """

    def __init__(self) -> None:
        super().__init__()
        self.shader_id = None
        for shader_instance in spjs.evaluate("alg.shaders.instances();"):
            if shader_instance["shader"] == "cs2":
                self.shader_id = shader_instance["id"]
        if self.shader_id == None:
            Log.error("Current shader instance is not compatible with the plugin.")
            return
        
    @QtCore.Slot(str, str)
    def set_parameter_value(self, shader_parameter, value):
        """ Sets the value of a shader parameter using JavaScript evaluation. """

        spjs.evaluate(f"alg.shaders.parameter({self.shader_id}, '{shader_parameter}').value = {value};")

    def _get_parameter_value(self, shader_parameter):
        value = spjs.evaluate(f"alg.shaders.parameter({self.shader_id}, '{shader_parameter}').value;")
        return value

    @QtCore.Slot(str, result=bool)
    def get_bool(self, shader_parameter):
        """ Gets the boolean value of a shader parameter. """

        return self._get_parameter_value(shader_parameter)

    @QtCore.Slot(str, result=float)
    def get_number(self, shader_parameter):
        """ Gets the numeric value of a shader parameter. """

        return self._get_parameter_value(shader_parameter)

    @QtCore.Slot(str, result=list)
    def get_list(self, shader_parameter):
        """ Gets the list value of a shader parameter. """

        return self._get_parameter_value(shader_parameter)
