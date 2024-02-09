from .plugin_manager import PluginManager


def start_plugin():
    PluginManager.init_plugin()


def close_plugin():
    PluginManager.delete_plugin()


if __name__ == "__main__":
    raise RuntimeError("The plugin must be launched from the Substance Painter")
