from .painter import Log, Plugin
from .controller import DockView


class PythonPlugin(Plugin):
    "Your Python plugin"
    
    dock_view = None
    
    @classmethod
    def start(cls, path):
        super().start(path, "PythonPlugin")
        
    @classmethod
    def on_start(cls):
        PythonPlugin.dock_view = DockView.from_plugin_file("View.qml")
    
    @classmethod
    def on_project_opened(cls):
        Log.info("Project opened")

    @classmethod
    def on_project_about_to_close(cls):
        Log.info("Project about to close")
