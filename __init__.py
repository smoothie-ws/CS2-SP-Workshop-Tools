from .plugin import CS2WT
from .plugin.painter import Path

def start_plugin():
    CS2WT.start(Path.to(__file__))


def close_plugin():
    CS2WT.close()
