import os

from .cs2 import CS2Plugin

CS2Plugin.set_plugin_dir(os.path.dirname(__file__))
CS2_PLUGIN = None


def start_plugin():
    global CS2_PLUGIN
    CS2_PLUGIN = CS2Plugin()


def close_plugin():
    global CS2_PLUGIN

    if CS2_PLUGIN is not None:
        CS2_PLUGIN.stop()


if __name__ == "__main__":
    start_plugin()
