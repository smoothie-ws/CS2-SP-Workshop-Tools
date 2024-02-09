import os
import shutil

from .tools import CS2


class PluginManager:
    plugin_path = os.path.abspath(__file__)
    plugin_shader_path = os.path.join(os.path.dirname(plugin_path), 'assets/shader')
    sp_shaders_path = os.path.expanduser('~/Documents/Adobe/Adobe Substance 3D Painter/assets/shaders')
    is_plugin_set_up = True

    if not (os.path.exists(os.path.join(sp_shaders_path, 'cs2.glsl')) and
            os.path.exists(os.path.join(sp_shaders_path, 'custom-ui/cs2'))):
        is_plugin_set_up = False

    @classmethod
    def init_plugin(cls):
        if not cls.is_plugin_set_up:
            cls.update_plugin()

            if cls.is_plugin_set_up:
                CS2.log.w("The CS2 Workshop Tools plugin was set up successfully.")

    @classmethod
    def update_plugin(cls):
        if os.path.exists(cls.plugin_shader_path):
            if os.path.exists(cls.sp_shaders_path):
                try:
                    shutil.copytree(cls.plugin_shader_path, cls.sp_shaders_path, dirs_exist_ok=True)
                except Exception as e:
                    CS2.log.e(f"An error occurred during the plugin setup process: {e}")
                    return
            # this case is theoretically unreachable
            else:
                CS2.log.e("Substance 3D Painter files are corrupted. Try reinstalling it.")
                return
        else:
            CS2.log.e("The plugin files are corrupted. Try reinstalling it.")
            return

        cls.is_plugin_set_up = True

    @classmethod
    def delete_plugin(cls):
        to_delete = ['cs2.glsl', 'custom-ui/cs2']
        for file_name in to_delete:
            file_path = os.path.join(cls.sp_shaders_path, file_name)
            if os.path.exists(file_path):
                try:
                    if os.path.isdir(file_path):
                        shutil.rmtree(file_path)
                    else:
                        os.remove(file_path)
                except Exception as e:
                    CS2.log.e(f"An error occurred while deleting the file '{file_name}': {e}")

        if not any(os.path.exists(os.path.join(cls.sp_shaders_path, file)) for file in to_delete):
            cls.is_plugin_set_up = False
            CS2.log.w("All plugin files were successfully deleted.")
