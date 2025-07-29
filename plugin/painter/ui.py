import substance_painter as sp

# qt5 vs qt6 check
if sp.application.version_info() < (10, 1, 0):
    from PySide2 import QtQuickWidgets, QtWidgets, QtCore, QtGui
else:
    from PySide6 import QtQuickWidgets, QtWidgets, QtCore, QtGui


class UI:
    widgets: list[QtWidgets.QWidget] = []
    
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

    @property
    @staticmethod
    def mode():
        return sp.ui.get_current_mode()

    @mode.setter
    @staticmethod
    def set_mode(mode: sp.ui.UIMode) -> None:
        sp.ui.switch_to_mode(mode)

    @staticmethod
    def add_widget(widget: QtWidgets.QWidget):
        UI.widgets.append(widget)
        return widget
    
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
        return UI.add_widget(sp.ui.add_menu(menu))

    @staticmethod
    def add_action(menu: sp.ui.ApplicationMenu, action: QtWidgets.QAction):
        return UI.add_widget(sp.ui.add_action(menu, action))

    @staticmethod
    def remove_widget(widget: QtWidgets.QWidget):
        sp.ui.delete_ui_element(widget)
        UI.widgets.remove(widget)

    @staticmethod
    def clear():
        for widget in UI.widgets:
            UI.remove_widget(widget)
    