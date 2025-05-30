import substance_painter as sp

from .ui import UI
from .settings import Settings
from .utils.log import Log


class Plugin:
    @staticmethod
    def start():
        Settings.load()
        try:
            UI.init()
            Log.warning(f'Plugin started (version {Settings.plugin_version})')

            connections = {
                sp.event.ProjectOpened: lambda _: UI.dock_view.internal.on_project_opened(),
                sp.event.ProjectAboutToClose: lambda _: UI.dock_view.internal.on_project_about_to_close()
            }
            for event, callback in connections.items():
                sp.event.DISPATCHER.connect_strong(event, callback)

            UI.dock_view.internal.checkout_weapon_textures()
            if sp.project.is_open():
                UI.dock_view.internal.on_project_opened()
        except Exception as e:
            UI.close()
            Log.error(f'Fatal error occured: {str(e)}')

    @staticmethod
    def close():
        Settings.save()
        UI.close()
        Log.warning("Plugin closed")
    