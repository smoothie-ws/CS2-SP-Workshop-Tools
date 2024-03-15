import os

from .cs2 import CS2Plugin


CS2_PLUGIN = None


def start_plugin():
    global CS2_PLUGIN
    CS2_PLUGIN = CS2Plugin(os.path.dirname(__fie__))


def close_plugin():
    global CS2_PLUGIN
    del CS2_PLUGIN


if __name__ == "__main__":
    start_plugin()
