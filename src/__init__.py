import substance_painter.ui as ui
from PySide2.QtGui import QIcon
from PySide2.QtWidgets import QMainWindow, QMenu, QAction
from PySide2.QtCore import Qt

from ._utils import Log

main_window: QMainWindow = ui.get_main_window()

plugin_widgets = []


def start_plugin():
    myMenuMenu = QMenu("CS2 Workshop Tools")
    # myMenuMenu.setIcon(QIcon("C:\\Users\\kibot\\Downloads\\512x512.png"))
    file_menu: QMenu = main_window.menuBar().findChild(QMenu, "file")

    myMenuMenu.addAction("About the plugin")
    myMenuMenu.addSeparator()
    myMenuMenu.addAction("Export project as .econitem")
    myMenuMenu.addAction("Blah3")

    plugin_widgets.append(myMenuMenu)

    file_menu_actions = file_menu.actions()
    file_menu.insertMenu(file_menu_actions[4], myMenuMenu)
    file_menu.insertSeparator(file_menu_actions[3])


def close_plugin():
    try:
        for widget in plugin_widgets:
            ui.delete_ui_element(widget)

        plugin_widgets.clear()
    except Exception as e:
        Log.e(e)


if __name__ == "__main__":
    start_plugin()
