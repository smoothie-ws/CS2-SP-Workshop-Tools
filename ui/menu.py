from PySide2.QtWidgets import QMenu

class Menu(QMenu):
    def __init__(self) -> None:
        super().__init__("CS2 Workshop Tools")
        self.about_window = None

        act_about = self.addAction("About the plugin")
        act_settings = self.addAction("Plugin settings")

        self.addSeparator()

        act_save_as_econitem = self.addAction("Save project as .econitem")

        act_autosave = self.addAction("Autosave")
        act_autosave.setCheckable(True)

    def on_about_click(self):
        pass
    
    def on_settings_click(self):
        pass

    def on_save_click(self):
        pass

    def on_autosave_click(self):
        pass