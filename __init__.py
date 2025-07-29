from .plugin import PythonPlugin
from .plugin.painter import Path


def start_plugin():
    PythonPlugin.start(Path.to(__file__))


def close_plugin():
    PythonPlugin.close()
