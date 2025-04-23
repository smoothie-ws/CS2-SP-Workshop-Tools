from .plugin import Plugin

plugin = None

def start_plugin():
    global plugin
    plugin = Plugin()

def close_plugin():
    global plugin
    plugin.close()
