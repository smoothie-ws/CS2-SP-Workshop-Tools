from PySide2.QtWidgets import QMenu
from cs2.tools import Log


class CS2Menu(QMenu):
    def __init__(self) -> None:
        super().__init__("CS2 Workshop Tools")

        self.act_about = self.addAction("About the cs2")
        self.act_about.triggered.connect(self.on_about_click)

        self.addSeparator()

        self.act_save_as_econitem = self.addAction("Save project as econitem")
        self.act_save_as_econitem.triggered.connect(self.on_save_econ_click)

        self.act_autoupdate_on_save = self.addAction("Autoupdate econitem on save")
        self.act_autoupdate_on_save.setCheckable(True)
        self.act_autoupdate_on_save.setChecked(True)
        self.act_autoupdate_on_save.triggered.connect(self.on_autoupdate_click)

    def on_about_click(self):
        Log.i("CS2 Workshop Tools")

    def on_save_econ_click(self):
        Log.i("Project saved as econitem")

    def on_autoupdate_click(self):
        if self.act_autoupdate_on_save.isChecked():
            Log.i("Econitem autoupdate enabled")
        else:
            Log.i("Econitem autoupdate disabled")
