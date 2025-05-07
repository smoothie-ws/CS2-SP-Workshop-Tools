import json
import webbrowser
import substance_painter as sp
import substance_painter_plugins as sp_plugins

# Qt5 vs Qt6 check
if sp.application.version_info() < (10, 1, 0):
    from PySide2 import QtCore, QtQml
else:
    from PySide6 import QtCore, QtQml

from .log import Log
from .path import Path
from .weapon_finish import WeaponFinish
from .project_settings import ProjectSettings
from .settings import Settings
from .decompiler import Decompiler


class InternalState:
    Started = 0
    Closed = 1
    Preparing = 2
    Decompiling = 3
    CreatingWeaponFinish = 4


class Internal(QtCore.QObject):
    "Bridge class between python and qml"

    def __init__(self, root:QtQml.QQmlContext):
        super().__init__()
        self.state = InternalState.Closed
        self.root = root
        self.root.setContextProperty("internal", self)

        self.missing_weapon_list = {}
    
    def on_project_opened(self):
        if self.is_weapon_finish_opened():
            self.projectKindChanged.emit(2)
        else:
            self.projectKindChanged.emit(1)

    def on_project_about_to_close(self):
        self.projectKindChanged.emit(0)

    def on_settings(self):
        self.pluginSettingsRequested.emit()
        
    def on_help(self):
        webbrowser.open("https://github.com/smoothie-ws/CS2-SP-Workshop-Tools?tab=readme-ov-file#contents")
        
    def on_clear_docs(self):
        self.clearDocsRequested.emit()
        
    def is_weapon_finish_opened(self):
        return ProjectSettings.get("weapon_finish") is not None
    
    def emit_textures_are_missing(self):
        if len(self.missing_weapon_list) > 0 and not Settings.get("ignore_textures_are_missing"):
            self.texturesAreMissing.emit()
    
    def emit_cs2_path_is_missing(self):
        path = Path.join("C:\\Program Files (x86)", "Steam", "steamapps", "common", "Counter-Strike Global Offensive")
        if Path.exists(path):
            self.cs2PathIsMissing.emit(path)
        else:
            self.cs2PathIsMissing.emit("")

    def decompile_textures(self, cs2_path:str):
        def state_changed(state):
            if state != "Finished":
                self.decompilationStateChanged.emit(state)
            else:
                self.state = InternalState.Started
                self.decompilationFinished.emit()
        
        self.decompilationStarted.emit()
        Decompiler.decompile(
            Path.join(cs2_path, "game", "csgo", "pak01_dir.vpk"), 
            Settings.get_asset_path("textures"),
            self.missing_weapon_list,
            state_changed,
            self.decompilationUpdated.emit
        )

    # Signals
    texturesAreMissing = QtCore.Signal()
    cs2PathIsMissing = QtCore.Signal(str)
    decompilationStarted = QtCore.Signal()
    decompilationUpdated = QtCore.Signal(float, str)
    decompilationStateChanged = QtCore.Signal(str)
    decompilationFinished = QtCore.Signal()
    projectKindChanged = QtCore.Signal(int)
    finishStyleReady = QtCore.Signal()
    pluginSettingsRequested = QtCore.Signal()
    clearDocsRequested = QtCore.Signal()

    # Slots
    @QtCore.Slot(str)
    def info(self, msg:str):
        Log.info(msg)
    
    @QtCore.Slot(str)
    def warning(self, msg:str):
        Log.warning(msg)

    @QtCore.Slot(str)
    def error(self, msg:str):
        Log.error(msg)

    @QtCore.Slot(result=str)
    def pluginVersion(self):
        return Settings.plugin_version
    
    @QtCore.Slot(result=str)
    def pluginPath(self):
        return Settings.plugin_path

    @QtCore.Slot(result=int)
    def getState(self):
        return self.state
    
    @QtCore.Slot(str)
    def showInExplorer(self, path:str):
        Path.show_in_explorer(path)

    @QtCore.Slot(bool)
    def ignoreTexturesMissing(self, ignore:bool):
        Settings.set("ignore_textures_are_missing", ignore)

    @QtCore.Slot(result=bool)
    def getIgnoreTexturesMissing(self):
        return Settings.get("ignore_textures_are_missing", False)

    @QtCore.Slot(str)
    def savePluginSettings(self, settings:str):
        for key, value in json.loads(settings).items():
            Settings.set(key, value)

    @QtCore.Slot()
    def startTexturesDecompilation(self):
        self.state = InternalState.Decompiling
        cs2_path = Settings.get("cs2_path")
        if cs2_path is not None:
            self.decompile_textures(cs2_path)
        else:
            self.emit_cs2_path_is_missing()

    @QtCore.Slot(result=str)
    def getCs2Path(self):
        return Settings.get("cs2_path", "")

    @QtCore.Slot(str, result=bool)
    def setCs2Path(self, cs2_path: str):
        Settings.set("cs2_path", cs2_path)
        if self.state == InternalState.Decompiling:
            self.decompile_textures(cs2_path)

    @QtCore.Slot(str, result=bool)
    def valCs2Path(self, path: str):
        if Path.exists(Path.join(path, "game", "csgo", "pak01_dir.vpk")):
            return True
        else:
            return False

    @QtCore.Slot(result=str)
    def getWeaponList(self):
        return json.dumps(Settings.get("weapon_list"))
    
    @QtCore.Slot(str, result=int)
    def valWeaponFinishName(self, name: str):
        cs2_path = Settings.get("cs2_path")
        if cs2_path:
            if len(name) > 0:
                if Path.exists(Path.join(cs2_path, 
                    "content", "csgo_addons", "workshop_items", "items", "assets", "paintkits", "workshop", 
                    f'{name}.econitem'
                )):
                    return 2
                else:
                    return 0
            else:
                return 1
        else:
            return 0
        
    @QtCore.Slot(str, str, str, str)
    def createWeaponFinish(self, file_path:str, finish_name:str, weapon:str, finish_style:str):
        def callback(res, msg):
            self.state = InternalState.Started
            if res:
                self.projectKindChanged.emit(2)
                Log.warning(msg)
            else:
                Log.error(f'Failed to create weapon finish: {msg}')
        self.state = InternalState.CreatingWeaponFinish
        WeaponFinish.create(file_path, finish_name, weapon, finish_style, callback)

    @QtCore.Slot(str, str, str)
    def setupAsWeaponFinish(self, finish_name:str, weapon:str, finish_style:str):
        def callback(res, msg):
            if res:
                self.projectKindChanged.emit(2)
                Log.warning(msg)
            else:
                Log.error(f'Failed to set up weapon finish: {msg}')
        WeaponFinish.set_up(finish_name, weapon, finish_style, callback)

    @QtCore.Slot(str)
    def changeFinishStyle(self, finish_style: str):
        def _change(res: bool, msg: str):
            if res:
                Log.warning(msg) 
                self.finishStyleReady.emit()
            else:
                Log.error(msg)

		# update shader instance
        WeaponFinish.change_finish_style_shader(finish_style, _change)

    @QtCore.Slot(str)
    def saveWeaponFinish(self, values: str):
        WeaponFinish.save(json.loads(values))

    @QtCore.Slot()
    def importWeaponFinishEconItem(self):
        WeaponFinish.import_econitem()

    @QtCore.Slot()
    def exportWeaponFinishTextures(self):
        WeaponFinish.export_textures()

    @QtCore.Slot(str, result=str)
    def js(self, code:str):
        try:
            return json.dumps(sp.js.evaluate(code))
        except Exception as e:
            Log.error(f'Failed to evaluate js code: {str(e)}')
            Log.info(code)
    
    @QtCore.Slot()
    def clear_docsConfirmed(self):
        for path in Settings.get("files", []):
            Path.remove(path)
