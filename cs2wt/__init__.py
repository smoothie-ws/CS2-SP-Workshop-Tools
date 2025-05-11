import substance_painter as sp

from .ui import UI
from .internal import Internal, InternalState
from .settings import Settings
from .utils.log import Log

class Plugin:
    internal = Internal()

    @staticmethod
    def start():
        Settings.load()
        try:
            UI.init(Plugin.internal)
            Plugin.internal.state = InternalState.Preparing

            connections = {
                sp.event.ProjectOpened: lambda _: Plugin.internal.on_project_opened(),
                sp.event.ProjectAboutToClose: lambda _: Plugin.internal.on_project_about_to_close()
            }
            for event, callback in connections.items():
                sp.event.DISPATCHER.connect_strong(event, callback)

            Log.warning(f'Plugin started (version {Settings.plugin_version})')

            Plugin.internal.checkout_weapon_textures()
            if sp.project.is_open():
                Plugin.internal.on_project_opened()

        except Exception as e:
            Log.error(f'Fatal error occured: {str(e)}')
            UI.close()

    @staticmethod
    def close():
        Settings.save()
        UI.close()
        Log.warning("Plugin closed")
    