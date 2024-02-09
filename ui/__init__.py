from substance_painter import ui as sp_ui
from .cs2menu import CS2Menu


class UI:
    sp_main_window = sp_ui.get_main_window()

    def __init__(self) -> None:
        self.cs2_menu = CS2Menu()

    def extend(self):
        self.sp_main_window.menuBar().addMenu(self.cs2_menu)

    def clear(self):
        sp_ui.delete_ui_element(self.cs2_menu)
