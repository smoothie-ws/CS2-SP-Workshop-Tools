import substance_painter as sp

# qt5 vs qt6 check
if sp.application.version_info() < (10, 1, 0):
    from PySide2 import QtQuickWidgets, QtWidgets, QtQuick, QtCore, QtGui
else:
    from PySide6 import QtQuickWidgets, QtWidgets, QtQuick, QtCore, QtGui


class UI:
    widgets: list[QtWidgets.QWidget] = []
    windows: list[QtWidgets.QMainWindow] = []
    
    class MainWindow:
        @staticmethod
        def get() -> QtWidgets.QMainWindow:
            return sp.ui.get_main_window()

        @staticmethod
        def show():
            sp.ui.show_main_window()

    class Layout:
        @staticmethod
        def reset(mode: sp.ui.UIMode):
            sp.ui.reset_layout(mode)

        @staticmethod
        def mode(layout: bytes) -> sp.ui.UIMode:
            return sp.ui.get_layout_mode(layout)

        @staticmethod
        def get(mode: sp.ui.UIMode) -> bytes:
            return sp.ui.get_layout(mode)
        
        @staticmethod 
        def set(layout: bytes):
            return sp.ui.set_layout(layout)

    @staticmethod
    def get_mode():
        return sp.ui.get_current_mode()

    @staticmethod
    def set_mode(mode: sp.ui.UIMode) -> None:
        sp.ui.switch_to_mode(mode)

    @staticmethod
    def add_widget(widget: QtWidgets.QWidget):
        UI.widgets.append(widget)
        return widget
    
    @staticmethod
    def add_window(window: QtWidgets.QMainWindow):
        UI.windows.append(window)
        return window
        
    @staticmethod
    def add_toolbar(title: str, object_name: str, ui_modes: int = sp.ui.UIMode.Edition) -> QtWidgets.QToolBar:
        return UI.add_widget(sp.ui.add_toolbar(title, object_name, ui_modes))

    @staticmethod
    def add_dock(widget: QtWidgets.QWidget, ui_modes: int = sp.ui.UIMode.Edition) -> QtWidgets.QDockWidget:
        return UI.add_widget(sp.ui.add_dock_widget(widget, ui_modes))

    @staticmethod
    def add_plugins_toolbar(widget: QtWidgets.QWidget):
        return UI.add_widget(sp.ui.add_plugins_toolbar_widget(widget))

    @staticmethod
    def add_menu(menu: QtWidgets.QMenu):
        sp.ui.add_menu(menu)
        return UI.add_widget(menu)

    @staticmethod
    def add_action(menu: sp.ui.ApplicationMenu, action: QtWidgets.QWidgetAction):
        return UI.add_widget(sp.ui.add_action(menu, action))

    @staticmethod
    def remove_widget(widget: QtWidgets.QWidget):
        if widget in UI.widgets:
            sp.ui.delete_ui_element(widget)
            UI.widgets.remove(widget)

    @staticmethod
    def remove_window(window: QtWidgets.QMainWindow):
        if window in UI.windows:
            window.destroy()
            UI.windows.remove(window)

    @staticmethod
    def clear():
        while len(UI.widgets) > 0:
            UI.remove_widget(UI.widgets[0])
        while len(UI.windows) > 0:
            UI.remove_window(UI.windows[0])
    