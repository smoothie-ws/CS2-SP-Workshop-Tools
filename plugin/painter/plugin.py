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
    _running = False
    _generation = 0
    _events = {
        "ProjectOpened": "on_project_opened",
        "ProjectCreated": "on_project_created",
        "ProjectAboutToClose": "on_project_about_to_close",
        "ProjectAboutToSave": "on_project_about_to_save",
        "ProjectSaved": "on_project_saved",
        "ExportTexturesAboutToStart": "on_export_textures_about_to_start",
        "ExportTexturesEnded": "on_export_textures_ended",
        "ShelfCrawlingStarted": "on_shelf_crawling_started",
        "ShelfCrawlingEnded": "on_shelf_crawling_ended",
        "ProjectEditionEntered": "on_project_edition_entered",
        "ProjectEditionLeft": "on_project_edition_left",
        "BusyStatusChanged": "on_busy_status_changed",
        "BakingProcessAboutToStart": "on_baking_process_about_to_start",
        "BakingProcessProgress": "on_baking_process_progress",
        "BakingProcessEnded": "on_baking_process_ended",
        "TextureStateEvent": "on_texture_state_event",
    }

    @classmethod
    def _connect_events(cls):
        generation = Plugin._generation
        for event_name, method_name in cls._events.items():
            method = getattr(cls, method_name)
            if getattr(method, "__func__", method) is getattr(Plugin, method_name).__func__:
                continue

            def callback(_, handler=method):
                if generation == Plugin._generation:
                    handler()

            event = getattr(sp.event, event_name)
            # Track the attempt too, so partial native registration is cleaned up.
            Plugin.connections[event] = callback
            sp.event.DISPATCHER.connect_strong(event, callback)

    @staticmethod
    def _disconnect_events():
        Plugin._generation += 1
        Plugin._running = False
        connections, Plugin.connections = Plugin.connections, {}
        errors = []
        for event, callback in reversed(tuple(connections.items())):
            try:
                sp.event.DISPATCHER.disconnect(event, callback)
            except Exception as error:
                errors.append(f"Failed to disconnect Painter event: {error}")
        return errors
    
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
        if Plugin._running or Plugin.connections or UI.widgets:
            cls.close()
        Plugin._generation += 1
        Log.channel = name
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
            cls._connect_events()
            Plugin._running = True
            cls.on_start()
            Log.warning(f'Plugin started (version {Plugin.version})')

            if sp.project.is_open():
                cls.on_project_opened()
        except Exception as startup_error:
            Log.error(f"Failed to start plugin: {startup_error}")
            for error in Plugin._disconnect_events():
                Log.error(error)
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
        errors = Plugin._disconnect_events()

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

    # Optional hooks share a no-op until a plugin overrides them.
    @classmethod
    def on_start(cls):
        pass

    on_close = on_start
    on_project_opened = on_start
    on_project_created = on_start
    on_project_about_to_close = on_start
    on_project_about_to_save = on_start
    on_project_saved = on_start
    on_export_textures_about_to_start = on_start
    on_export_textures_ended = on_start
    on_shelf_crawling_started = on_start
    on_shelf_crawling_ended = on_start
    on_project_edition_entered = on_start
    on_project_edition_left = on_start
    on_busy_status_changed = on_start
    on_baking_process_about_to_start = on_start
    on_baking_process_progress = on_start
    on_baking_process_ended = on_start
    on_texture_state_event = on_start
