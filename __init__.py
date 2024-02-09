from .ui import UIExtension


ui = UIExtension()


def start_plugin():
    ui.extend()


def close_plugin():
    ui.clear()
