import os

from .cs2 import CS2Plugin


CS2_PLUGIN = CS2Plugin(os.path.dirname(__file__))


def start_plugin():
    global CS2_PLUGIN
    CS2_PLUGIN.enable() 


def close_plugin():
    global CS2_PLUGIN
    CS2_PLUGIN.disable()


if __name__ == "__main__":
    start_plugin()
