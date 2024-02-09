from PySide2.QtWidgets import QMenu
from cs2.tools import CS2

class CS2Menu(QMenu):
    def __init__(self) -> None:
        super().__init__("CS2 Workshop Tools")

        self.act_about = self.addAction("About the plugin")
        self.act_about.triggered.connect(self.on_about_click)

        self.addSeparator()

        self.act_save_as_econitem = self.addAction("Save project as econitem")
        self.act_save_as_econitem.triggered.connect(self.on_save_econ_click)

        self.act_autoupdate_on_save = self.addAction("Autoupdate econitem on save")
        self.act_autoupdate_on_save.setCheckable(True)
        self.act_autoupdate_on_save.setChecked(True)
        self.act_autoupdate_on_save.triggered.connect(self.on_autoupdate_click)

    def on_about_click(self):
        CS2.log.i("CS2 Workshop Tools")

    def on_save_econ_click(self):
        CS2.log.i("Project saved as econitem")

    def on_autoupdate_click(self):
        if self.act_autoupdate_on_save.isChecked():
            CS2.log.i("Econitem autoupdate enabled")
        else:
            CS2.log.i("Econitem autoupdate disabled")
