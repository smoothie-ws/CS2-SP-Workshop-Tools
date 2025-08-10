import json
import substance_painter as sp

from .ui import UI, QtVersion
from .log import Log
from .path import Path
from .macro import Macro


class Plugin:
    settings: dict = {}
    version: str = "0.0.1a"
    connections: dict = {}
    
    @staticmethod
    def save():
        Path.write(Path.settings, json.dumps({
            "version": Plugin.version,
            "settings": Plugin.settings
        }, indent=4, ensure_ascii=False))
    
    @classmethod
    def start(cls, path: str, name: str):
        Log.channel = name
        Path.plugin = path
        Path.settings = Path.join(Path.plugin, "plugin.json")
        Path.documents = sp.js.evaluate("alg.documents_directory")
        
        try:
            data = json.loads(Path.read(Path.settings, ""))
            Plugin.settings = data.get("settings", {})
            Plugin.version = data.get("version", "0.0.1a")
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
                
            cls.on_start()
            Log.warning(f'Plugin started (version {Plugin.version})')
            
            if sp.project.is_open():
                cls.on_project_opened()
        except:
            cls.on_close()
            Log.fatal()

    @classmethod
    def close(cls):
        try:
            UI.clear()
            Plugin.save()
            for event, callback in Plugin.connections.items():
                sp.event.DISPATCHER.disconnect(event, callback)
            cls.on_close()
            Log.warning("Plugin closed")
        except:
            Log.fatal()
    
    @classmethod
    def preprocess(cls):
        asset_view_path = Path.asset("view")
        
        if Path.exists(asset_view_path):
            view_path = Path.cleardir(Path.join(Path.plugin, "view"))
            def process(path: str):
                asset_path = Path.join(asset_view_path, path)
                if Path.isdir(asset_path):
                    Path.cleardir(Path.join(view_path, path))
                    for p in Path.listdir(asset_path):
                        process(Path.join(path, p))
                else:
                    view_asset_path = Path.join(view_path, path)
                    if path.lower().endswith("qml"):
                        sources = Path.read(asset_path)
                        sources = Macro.process(sources, {"QT_VERSION": QtVersion})
                        Path.write(view_asset_path, sources)
                    else:
                        Path.copy(asset_path, view_asset_path)
                
            for p in Path.listdir(asset_view_path):
                process(p)
                
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
