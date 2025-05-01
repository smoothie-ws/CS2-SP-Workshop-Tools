from .plugin import Plugin
from .settings import Settings

plugin = None

def start_plugin():
    global plugin
    Settings.load()
    plugin = Plugin()

def close_plugin():
    global plugin
    Settings.save()
    plugin.close()
