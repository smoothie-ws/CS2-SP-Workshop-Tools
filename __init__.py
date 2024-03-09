import os
import random
import shutil

from PySide2.QtCore import QSize
from PySide2.QtGui import QKeySequence, QIcon, Qt
from PySide2.QtWidgets import QWidget, QFrame, QPushButton, QLayout, \
    QMainWindow, QGroupBox, QVBoxLayout, QScrollArea, QAction, QLabel, \
    QGridLayout, QSpacerItem, QSizePolicy, QHBoxLayout, QBoxLayout

from substance_painter import logging as splog
from substance_painter import ui as spui
from substance_painter import js as spjs


class Log:
    channel = "CS2 Workshop Tools"

    @staticmethod
    def info(message: any):
        splog.log(splog.INFO, Log.channel, str(message))

    @staticmethod
    def warning(message: any):
        splog.log(splog.WARNING, Log.channel, str(message))

    @staticmethod
    def error(message: any):
        splog.log(splog.ERROR, Log.channel, str(message))


class AssetBundle(dict):
    """Represents a bundle asset, which contains multiple assets."""

    def __init__(self, url=None):
        super().__init__()
        self._root_folder = None
        if url:
            if isinstance(url, str):
                url = os.path.abspath(url)
                self._root_folder = url
                self._load(url)
            elif isinstance(url, bytes):
                try:
                    url = os.path.abspath(url.decode('utf-8'))
                    self._root_folder = url
                    self._load(url)
                except UnicodeDecodeError:
                    pass
            elif isinstance(url, (dict, AssetBundle)):
                self.update(url)
            else:
                raise TypeError(f'{type(url)} is incompatible type')

    def _load(self, directory):
        """Load assets from the specified directory."""

        def traverse(path, tree):
            for entry in os.listdir(path):
                full_path = os.path.join(path, entry)
                if os.path.isdir(full_path):
                    tree[entry] = AssetBundle()
                    traverse(full_path, tree[entry])
                else:
                    tree[entry] = full_path

        traverse(directory, self)

    @property
    def fullpath(self):
        """Return the full path to the folder represented by the class."""

        return self._root_folder

    def fetch(self, key, default=None):
        try:
            return self[key]
        except KeyError:
            for value in self.values():
                if isinstance(value, AssetBundle):
                    result = value.fetch(key, default)
                    if result is not default:
                        return result
            return default

    def copy_assets(self, dest_dir):
        """Copy the asset bundle to a new directory."""

        dest_dir = os.path.abspath(dest_dir)

        for key, value in self.items():
            src_path = value
            dest_path = os.path.join(dest_dir, key)

            if isinstance(value, dict):
                os.makedirs(dest_path, exist_ok=True)
                sub_bundle = AssetBundle(src_path)
                sub_bundle.copy_assets(dest_path)
            else:
                shutil.copy2(src_path, dest_path)

    def __call__(self, child_name):
        child = AssetBundle(self[child_name])
        child._root_folder = os.path.join(self.fullpath, child_name)
        return child

    def __eq__(self, other):
        other_tree = AssetBundle(other)
        return self.keys() == other_tree.keys()

    def __ne__(self, other):
        return not self == other

    def __lt__(self, other):
        other_tree = AssetBundle(other)
        return set(self.keys()) < set(other_tree.keys())

    def __le__(self, other):
        other_tree = AssetBundle(other)
        return set(self.keys()) <= set(other_tree.keys())

    def __gt__(self, other):
        other_tree = AssetBundle(other)
        return set(self.keys()) > set(other_tree.keys())

    def __ge__(self, other):
        other_tree = AssetBundle(other)
        return set(self.keys()) >= set(other_tree.keys())


cs2_assets = AssetBundle(os.path.dirname(__file__))('assets')
sp_assets = AssetBundle(os.path.join(os.path.expanduser("~"), "Documents", "Adobe",
                                     "Adobe Substance 3D Painter", "assets"))


class UIButton(QPushButton):
    def __init__(self, text=None, icon=None, tooltip=None, shortcut=None,
                 is_checkable=False):
        super().__init__(text)

        self.setIcon(QIcon(icon) if icon else QIcon())
        self.setIconSize(QSize(20, 20))
        self.setCursor(Qt.PointingHandCursor)
        self.setLayoutDirection(Qt.RightToLeft)

        if tooltip:
            self.setToolTip(f"{tooltip} ({shortcut})" if shortcut else tooltip)

        if shortcut:
            self.setShortcut(QKeySequence(shortcut))

        self.setCheckable(is_checkable)
        self.setStyleSheet('''
            QPushButton {
                border: none;
                background: #333333;
                text-align: center;
                font-size: 12px;
            }
    
            QPushButton:hover {
                background: #404040;
            }
    
            QPushButton:checked {
                border: 1px solid #378ef0;
                background: #4d4d4d;
            }
        ''')


class UI(QMainWindow):
    def __init__(self):
        super().__init__()
        self.widgets: list = []
        self.main_window = spui.get_main_window()
        self.main_widget: QWidget = self.main_window.findChild(QWidget, "MainWidget")
        self.viewport: QFrame = self.main_window.findChild(QFrame, "viewermode_viewport_combobox")

    def show(self):
        layout: QLayout = self.viewport.layout()
        layout.setSpacing(10)

        for widget in self.widgets:
            layout.addWidget(widget)

    def add_widgets(self, *widgets):
        for widget in widgets:
            self.widgets.append(widget)


# -----------------------------------------------------------------------------


cs2_ui = UI()

assets2checkout = {
    "shader": "shaders",
    "export-presets": "export-presets"
}


def start_plugin():
    """This method is called when the plugin is started."""

    try:
        for src, dst in assets2checkout.items():
            if not cs2_assets(src) <= sp_assets(dst):
                cs2_assets(src).copy_assets(sp_assets(dst).fullpath)
    except Exception as e:
        Log.error(f"An error occured setting up the plugin: {e}")
        return

    def on_preview_click():
        state = 'true' if preview_button.isChecked() else 'false'
        spjs.evaluate(f"alg.shaders.parameter(0, 'u_enable_live_preview').value = {state};")

    def on_validate_click():
        state = 'true' if validate_button.isChecked() else 'false'
        spjs.evaluate(f"alg.shaders.parameter(0, 'u_enable_pbr_validation').value = {state};")

    preview_button = UIButton("Live Preview",
                              QIcon(cs2_assets.fetch("icon_eye.png")),
                              "Weapon Finish live preview",
                              "W",
                              True)
    preview_button.toggled.connect(on_preview_click)
    preview_button.setChecked(True)

    validate_button = UIButton("PBR Validate",
                               QIcon(cs2_assets.fetch("icon_tweak.png")),
                               "Weapon Finish PBR validation",
                               "E",
                               True)
    validate_button.toggled.connect(on_validate_click)
    validate_button.setChecked(True)

    cs2_ui.add_widgets(preview_button, validate_button)
    cs2_ui.show()
    Log.warning("The plugin was enabled successfully")


def close_plugin():
    """This method is called when the plugin is stopped."""

    for widget in cs2_ui.widgets:
        spui.delete_ui_element(widget)

    cs2_ui.widgets.clear()

    Log.warning("The plugin was disabled successfully")


if __name__ == "__main__":
    start_plugin()
