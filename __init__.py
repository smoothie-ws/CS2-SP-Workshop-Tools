import substance_painter as sp

from cs2.plugin import Plugin
from cs2.internal import InternalState
from cs2.settings import Settings
from cs2.utils.log import Log


def start_plugin():
    Settings.load()
    try:
        Plugin.init()
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
        Plugin.close()


def close_plugin():
    Settings.save()
    Plugin.close()
    Log.warning("Plugin closed")
    