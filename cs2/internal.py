import json
import substance_painter as sp

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
        if ProjectSettings.get("weapon_finish") is not None:
            self.projectKindChanged.emit(2)
        else:
            self.projectKindChanged.emit(1)

    def on_project_about_to_close(self):
        self.projectKindChanged.emit(0)

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

    @QtCore.Slot(bool)
    def ignoreTexturesMissing(self, ignore:bool):
        Settings.set("ignore_textures_are_missing", ignore)

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
        weapon_list:dict = Settings.get("weapon_list")
        return "&".join([f'{key}:{weapon_list.get(key)}' for key in weapon_list.keys()])
    
    @QtCore.Slot(str, str, str, int)
    def createWeaponFinish(self, file_path:str, name:str, weapon:str, finish_style:int):
        def callback(res, msg):
            self.state = InternalState.Started
            if res:
                self.projectKindChanged.emit(2)
                Log.warning(msg)
            else:
                Log.error(f'Failed to create weapon finish: {msg}')
        self.state = InternalState.CreatingWeaponFinish
        WeaponFinish.create(file_path, name, weapon, finish_style, callback)

    @QtCore.Slot(str, str, int)
    def setupAsWeaponFinish(self, name:str, weapon:str, finish_style:int):
        def callback(res, msg):
            if res:
                self.projectKindChanged.emit(2)
                Log.warning(msg)
            else:
                Log.error(f'Failed to set up weapon finish: {msg}')
        WeaponFinish.set_up(name, weapon, finish_style, callback)

    @QtCore.Slot(str, result=str)
    def js(self, code:str):
        try:
            return json.dumps(sp.js.evaluate(code))
        except Exception as e:
            Log.error(f'Failed to evaluate js code: {str(e)}')
            Log.info(code)
    
    @QtCore.Slot(str)
    def saveWeaponFinish(self, values:str):
        WeaponFinish.save(json.loads(values))
