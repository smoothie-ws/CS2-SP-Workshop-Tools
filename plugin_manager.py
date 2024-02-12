from .tools import Log

import os
import shutil

_cur_dir = os.path.dirname(os.path.abspath(__file__))
_docs_path = os.path.expanduser('~/Documents')


class PluginManager:
    shader_path = os.path.join(_cur_dir, 'assets/shader')
    sp_shaders_path = (f'{_docs_path}/Adobe/'
                       f'Adobe Substance 3D Painter/assets/shaders')

    @classmethod
    def is_plugin_set_up(cls):
        try:
            for shader_file in os.listdir(cls.shader_path):
                if not os.path.exists(f'{cls.sp_shaders_path}/{shader_file}'):
                    return False
            return True
        except OSError:
            Log.w("Seems that Substance 3D Painter files are corrupted. "
                  "Try reinstalling it.")

    @classmethod
    def start_plugin(cls):
        if not cls.is_plugin_set_up():
            cls.setup_plugin()

        Log.w("The plugin was enabled successfully.")

    @classmethod
    def setup_plugin(cls):
        if os.path.exists(cls.shader_path):
            if os.path.exists(cls.sp_shaders_path):
                try:
                    shutil.copytree(cls.shader_path, cls.sp_shaders_path,
                                    dirs_exist_ok=True)
                except Exception as e:
                    Log.e(f"An error occurred: {e}")
            # this case is theoretically unreachable
            else:
                Log.e("Substance 3D Painter files are corrupted. "
                      "Try reinstalling it.")
        else:
            Log.e("The plugin files are corrupted. "
                  "Try reinstalling it.")

        Log.w("The plugin was set up successfully.")

    @classmethod
    def close_plugin(cls):
        Log.w("The plugin was disabled successfully.")
        # TODO

    @classmethod
    def delete_plugin(cls):
        for shader_file in os.listdir(cls.shader_path):
            if os.path.exists(f'{cls.sp_shaders_path}/{shader_file}'):
                try:
                    if os.path.isdir(shader_file):
                        shutil.rmtree(shader_file)
                    else:
                        os.remove(shader_file)
                except Exception as e:
                    Log.e(f"An error occurred deleting '{shader_file}': {e}")

        # checking whether all the files were deleted
        if not any(os.path.exists(f'{cls.sp_shaders_path}/{shader_file}')
                   for shader_file in os.listdir(cls.shader_path)):
            cls.is_plugin_set_up = False
            Log.w("All plugin files were successfully deleted.")
