class ShaderParam:
    class Type:
        Sampler2D = "sampler2D"
        Bool = "bool"
        Int = "int"
        Float = "float"
        Vec2 = "vec2"
        Vec3 = "vec3"
        Vec4 = "vec4"
        IVec2 = "ivec2"
        IVec3 = "ivec3"
        IVec4 = "ivec4"

    def __init__(
            self,
            type:Type, 
            default:any, 
            condition:bool = True, 
            is_uniform:bool = True,
            expr:str = ""
        ):
        self.type = type
        self.default = default
        self.condition = condition
        self.is_uniform = is_uniform
        self.expr = expr


class ShaderControl(ShaderParam):
    def __init__(
            self,
            type:str, 
            name:str, 
            default:any, 
            description:str = "", 
            condition:bool = True, 
            visible:str = "true",
            widget:str = "",
            is_uniform:bool = True,
            expr:str = ""
        ):
        super().__init__(type, default, condition, is_uniform, expr)
        self.name = name
        self.description = description
        self.visible = visible
        self.widget = widget


class ShaderParamsGroup:
    def __init__(self, params:dict = {}, condition:bool = True):
        self.params = params
        self.condition = condition

    def build(self):
        return {
            id: param.__dict__
            for id, param in self.params.items() if param.condition
        }


class ShaderParams:
    @staticmethod
    def build(groups:dict[str, ShaderParamsGroup]):
        return {
            name: group.build()
            for name, group in groups.items() if group.condition
        }


class Slider(ShaderControl):
    def __init__(self, name:str, default:any = 0.0, description:str = "", condition:bool = True, visible:str = "true", is_uniform:bool = True, expr:str = "", min:float = 0.0, max:float = 1.0):
        super().__init__(ShaderParam.Type.Float, name, default, description, condition, visible, "Slider", is_uniform, expr)
        self.min = min
        self.max = max


class MultiSlider(ShaderControl):
    def __init__(self, name:str, default:any = None, description:str = "", condition:bool = True, visible:str = "true", is_uniform:bool = True, expr:str = "", min:float = 0.0, max:float = 1.0, model:list = ["X", "Y", "Z", "W"]):
        super().__init__(f'vec{len(model)}', name, default if default else [0.0 for _ in model], description, condition, visible, "MultiSlider", is_uniform, expr)
        self.min = min
        self.max = max
        self.model = model


class RangeSlider(ShaderControl):
    def __init__(self, name:str, default:any = [0.0, 1.0], description:str = "", condition:bool = True, visible:str = "true", is_uniform:bool = True, expr:str = "", min:float = 0.0, max:float = 1.0):
        super().__init__(ShaderParam.Type.Float, name, default, description, condition, visible, "RangeSlider", is_uniform, expr)
        self.min = min
        self.max = max


class Color(ShaderControl):
    def __init__(self, name:str, default:any = [1.0, 1.0, 1.0], description:str = "", condition:bool = True, visible:str = "true", is_uniform:bool = True):
        super().__init__(ShaderParam.Type.Vec3, name, default, description, condition, visible, "ColorButton", is_uniform, "[Math.pow(x[0], 2.4), Math.pow(x[1], 2.4), Math.pow(x[2], 2.4)]")


class Checkbox(ShaderControl):
    def __init__(self, name:str, default:any = "false", description:str = "", condition:bool = True, visible:str = "true", is_uniform:bool = True, expr:str = ""):
        super().__init__(ShaderParam.Type.Bool, name, default, description, condition, visible, "Button", is_uniform, expr)


class Combobox(ShaderControl):
    def __init__(self, name:str, default:any = 0, description:str = "", condition:bool = True, visible:str = "true", is_uniform:bool = True, expr:str = "", model:list = []):
        super().__init__(ShaderParam.Type.Vec3, name, default, description, condition, visible, "ComboBox", is_uniform, expr)
        self.model = model


class Texture(ShaderControl):
    def __init__(self, name:str, default:any = "", description:str = "", condition:bool = True, visible:str = "true", is_uniform:bool = True, expr:str = ""):
        super().__init__(ShaderParam.Type.Sampler2D, name, default, description, condition, visible, "TextureFetcher", is_uniform, expr)
