from .plugin_manager import PluginManager


def start_plugin():
    PluginManager.start_plugin()


def close_plugin():
    PluginManager.close_plugin()
