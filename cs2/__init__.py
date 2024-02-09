from .ui_extension import UI
import substance_painter.event as sp_event

ui_extension = UI()

def project_opened(event: sp_event.Event):
    print("Project Opened")

def start_plugin():
    sp_event.DISPATCHER.connect(sp_event.ProjectOpened, project_opened)
    ui_extension.extend()

def close_plugin():
    ui_extension.clear()
