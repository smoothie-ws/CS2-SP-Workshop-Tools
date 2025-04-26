import os
import substance_painter as sp

from .settings import Settings


class Project:
    @staticmethod
    def create_weapon_finish(file_path:str, name:str, weapon:str, finish_style:int, callback):
        # create project
        export_path = None
        cs2_path = Settings.get("cs2_path")
        if cs2_path is not None:
            export_path = os.path.join(cs2_path, "content", "csgo", "workshop", "paintkits", name)
        sp.project.create(
            mesh_file_path=file_path, 
            settings=sp.project.Settings(
                import_cameras=False,
                normal_map_format=sp.project.NormalMapFormat.OpenGL,
                tangent_space_mode=sp.project.TangentSpace.PerVertex,
                export_path=export_path
            )
        )
        project = Project()
        sp.project.execute_when_not_busy(lambda: project.set_up_as_weapon_finish(name, weapon, finish_style, callback))
        return project

    def __init__(self):
        self.settings = ProjectSettings
        self.name = sp.project.name()
        self.is_weapon_finish = self.settings.get("weapon_finish") is not None

    def set_up_as_weapon_finish(self, name:str, weapon:str, finish_style:int, callback):
        def set_up(callback):
            try:
                shaders = sp.resource.search("s: your_assets u: shader n: cs2")
                if len(shaders) > 0:
                    # update shader
                    sp.js.evaluate(f'alg.shaders.updateShaderInstance(0, "{shaders[0].identifier().url()}")')
                    
                    # update channel stack
                    stack = sp.textureset.get_active_stack()
                    new_stack = {
                        sp.textureset.ChannelType.BaseColor: (sp.textureset.ChannelFormat.sRGB8, "Base Color"),
                        sp.textureset.ChannelType.Roughness: (sp.textureset.ChannelFormat.L8, "Roughness"),
                        sp.textureset.ChannelType.User0: (sp.textureset.ChannelFormat.RGB8, "Masks"),
                        sp.textureset.ChannelType.User1: (sp.textureset.ChannelFormat.L8, "Alpha"),
                        sp.textureset.ChannelType.User2: (sp.textureset.ChannelFormat.L8, "Pearlescence")
                    }
                    for channel_type, channel in new_stack.items():
                        channel_format, channel_label = channel
                        if stack.has_channel(channel_type):
                            stack_channel = stack.get_channel(channel_type)
                            if stack_channel.format() != channel_format or stack_channel.label() != channel_label:
                                stack.edit_channel(channel_type, channel_format, channel_label)
                        else:
                            stack.add_channel(channel_type, channel_format, channel_label)
                    # remove unnecessary channels 
                    for channel_type, channel in stack.all_channels().items():
                        if channel_type not in [
                            sp.textureset.ChannelType.BaseColor,
                            sp.textureset.ChannelType.Roughness,
                            sp.textureset.ChannelType.User0,
                            sp.textureset.ChannelType.User1,
                            sp.textureset.ChannelType.User2,
                            sp.textureset.ChannelType.Height,
                            sp.textureset.ChannelType.Normal
                        ]:
                            stack.remove_channel(channel_type)

                    # update project settings
                    self.settings.set("weapon_finish", {
                        "name": name,
                        "weapon": weapon,
                        "finish_style": finish_style
                    })

                    self.is_weapon_finish = True
                    callback(True, "The project was set up as Weapon Finish")
                else:
                    callback(False, "Failed to find shader")
            except Exception as e:
                callback(False, str(e))

        if sp.resource.Shelf("your_assets").is_crawling():
            sp.event.DISPATCHER.connect(sp.event.ShelfCrawlingEnded, lambda _: set_up(callback))
        else:
            set_up(callback)

    def sync_econ(self):
        pass


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
