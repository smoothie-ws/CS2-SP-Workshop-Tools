from PySide2.QtWidgets import QMenu
from cs2 import CS2

class CS2Menu(QMenu):
    def __init__(self) -> None:
        super().__init__("CS2 Workshop Tools")

        act_about = self.addAction("About the plugin")
        act_about.triggered.connect(self.on_about_click)

        self.addSeparator()

        act_save_as_econitem = self.addAction("Save project as econitem")
        act_save_as_econitem.triggered.connect(self.on_save_econ_click)

        act_autoupdate_on_save = self.addAction("Autoupdate econitem on save")
        act_autoupdate_on_save.setCheckable(True)
        act_autoupdate_on_save.setChecked(True)
        act_autoupdate_on_save.triggered.connect(self.on_autoupdate_click)

    def on_about_click(self):
        CS2.log.i("CS2 Workshop Tools")

    def on_save_econ_click(self):
        CS2.log.i("Project saved as econitem")

    def on_autoupdate_click(self):
        CS2.log.i("Enable autoupdate")