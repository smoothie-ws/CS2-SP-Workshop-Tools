from .plugin import Plugin
from .settings import Settings

plugin = None

def start_plugin():
    global plugin
    Settings._init()
    plugin = Plugin()

def close_plugin():
    global plugin
    Settings.dump()
    plugin.close()
