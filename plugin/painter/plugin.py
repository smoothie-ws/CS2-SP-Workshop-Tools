import json
import substance_painter as sp

from .ui import UI
from .log import Log
from .path import Path
from .preprocess import sync_views


class Plugin:
    settings: dict = {}
    version: str = "v0.0.1a"
    connections: dict = {}
    
    @staticmethod
    def save():
        written = Path.write(Path.settings, json.dumps({
            "version": Plugin.version,
            "settings": Plugin.settings
        }, indent=4, ensure_ascii=False))
        if not written:
            raise OSError(f"Could not save plugin settings: {Path.settings}")
    
    @classmethod
    def start(cls, path: str, name: str):
        if Plugin.connections or UI.widgets:
            cls.close()
        Log.channel = name
        connected = []
        try:
            Path.plugin = path
            Path.settings = Path.join(Path.plugin, "plugin.json")
            Path.documents = sp.js.evaluate("alg.documents_directory")
            data = json.loads(Path.read(Path.settings, ""))
            if not isinstance(data, dict) or not isinstance(data.get("settings", {}), dict):
                raise ValueError("Plugin settings must be a JSON object")
            Plugin.settings = data.get("settings", {})
            Plugin.version = data.get("version", "v0.0.1a")
            Plugin.preprocess()
            Plugin.connections = {
                sp.event.ProjectOpened: lambda _: cls.on_project_opened(),
                sp.event.ProjectCreated: lambda _: cls.on_project_created(),
                sp.event.ProjectAboutToClose: lambda _: cls.on_project_about_to_close(),
                sp.event.ProjectAboutToSave: lambda _: cls.on_project_about_to_save(),
                sp.event.ProjectSaved: lambda _: cls.on_project_saved(),
                sp.event.ExportTexturesAboutToStart: lambda _: cls.on_export_textures_about_to_start(),
                sp.event.ExportTexturesEnded: lambda _: cls.on_export_textures_ended(),
                sp.event.ShelfCrawlingStarted: lambda _: cls.on_shelf_crawling_started(),
                sp.event.ShelfCrawlingEnded: lambda _: cls.on_shelf_crawling_ended(),
                sp.event.ProjectEditionEntered: lambda _: cls.on_project_edition_entered(),
                sp.event.ProjectEditionLeft: lambda _: cls.on_project_edition_left(),
                sp.event.BusyStatusChanged: lambda _: cls.on_busy_status_changed(),
                sp.event.BakingProcessAboutToStart: lambda _: cls.on_baking_process_about_to_start(),
                sp.event.BakingProcessProgress: lambda _: cls.on_baking_process_progress(),
                sp.event.BakingProcessEnded: lambda _: cls.on_baking_process_ended(),
                sp.event.TextureStateEvent: lambda _: cls.on_texture_state_event()
            }
            for event, callback in Plugin.connections.items():
                sp.event.DISPATCHER.connect_strong(event, callback)
                connected.append((event, callback))

            cls.on_start()
            Log.warning(f'Plugin started (version {Plugin.version})')

            if sp.project.is_open():
                cls.on_project_opened()
        except Exception as startup_error:
            Log.error(f"Failed to start plugin: {startup_error}")
            for event, callback in reversed(connected):
                try:
                    sp.event.DISPATCHER.disconnect(event, callback)
                except Exception as error:
                    Log.error(f"Failed to disconnect Painter event after startup failure: {error}")
            Plugin.connections = {}
            try:
                cls.on_close()
            except Exception as error:
                Log.error(f"Failed to close partially started plugin: {error}")
            try:
                UI.clear()
            except Exception as error:
                Log.error(f"Failed to clear partial plugin UI: {error}")
            Log.fatal()

    @classmethod
    def close(cls):
        errors = []
        for event, callback in list(Plugin.connections.items()):
            try:
                sp.event.DISPATCHER.disconnect(event, callback)
            except Exception as error:
                errors.append(f"Failed to disconnect Painter event: {error}")
        Plugin.connections = {}

        try:
            cls.on_close()
        except Exception as error:
            errors.append(f"Plugin close handler failed: {error}")
        try:
            UI.clear()
        except Exception as error:
            errors.append(f"Failed to clear plugin UI: {error}")
        try:
            Plugin.save()
        except Exception as error:
            errors.append(f"Failed to save plugin settings: {error}")

        for error in errors:
            Log.error(error)
        if errors:
            Log.fatal()
        else:
            Log.warning("Plugin closed")
    
    @classmethod
    def preprocess(cls):
        sync_views(Path.asset("view"), Path.join(Path.plugin, "view"))

    # to override
    
    @classmethod
    def on_start(cls):
        pass
    
    @classmethod
    def on_close(cls):
        pass
        
    @classmethod
    def on_project_opened(cls):
        pass
    
    @classmethod
    def on_project_created(cls):
        pass

    @classmethod
    def on_project_about_to_close(cls):
        pass
    
    @classmethod
    def on_project_about_to_save(cls):
        pass

    @classmethod
    def on_project_saved(cls):
        pass

    @classmethod
    def on_export_textures_about_to_start(cls):
        pass

    @classmethod
    def on_export_textures_ended(cls):
        pass

    @classmethod
    def on_shelf_crawling_started(cls):
        pass

    @classmethod
    def on_shelf_crawling_ended(cls):
        pass

    @classmethod
    def on_project_edition_entered(cls):
        pass

    @classmethod
    def on_project_edition_left(cls):
        pass

    @classmethod
    def on_busy_status_changed(cls):
        pass

    @classmethod
    def on_baking_process_about_to_start(cls):
        pass

    @classmethod
    def on_baking_process_progress(cls):
        pass

    @classmethod
    def on_baking_process_ended(cls):
        pass

    @classmethod
    def on_texture_state_event(cls):
        pass
