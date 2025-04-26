import os
import substance_painter as sp

# Qt5 vs Qt6 check
if sp.application.version_info() < (10, 1, 0):
    from PySide2 import QtCore, QtQml
else:
    from PySide6 import QtCore, QtQml

from .project import Project
from .settings import Settings
from .decompiler import Decompiler


class InternalState:
    Started = 0
    Decompiling = 1
    Closed = 2


class Internal(QtCore.QObject):
    "Bridge class between python and qml"

    # Signals
    texturesAreMissing = QtCore.Signal()
    cs2PathIsMissing = QtCore.Signal(str)
    decompilationStarted = QtCore.Signal()
    decompilationUpdated = QtCore.Signal(float, str)
    decompilationStateChanged = QtCore.Signal(str)
    decompilationFinished = QtCore.Signal()
    projectKindChanged = QtCore.Signal(int)

    def __init__(self, root:QtQml.QQmlContext):
        super().__init__()
        self.state = InternalState.Closed
        self.root = root
        self.root.setContextProperty("internal", self)

        self.project = None
        self.weapon_list = {}
    
    def push_weapon_list(self, weapon_list:dict):
        if len(weapon_list) > 0 and Settings.get("ignore_textures_are_missing") is not True:
            self.weapon_list = weapon_list
            self.texturesAreMissing.emit()
    
    def init_project(self):
        self.project = Project()
        self.projectKindChanged.emit(2 if self.project.is_weapon_finish else 1)

    def emit_cs2_path_is_missing(self):
        path = os.path.join("C:\\Program Files (x86)", "Steam", "steamapps", "common", "Counter-Strike Global Offensive")
        if os.path.exists(path):
            self.cs2PathIsMissing.emit(path)
        else:
            self.cs2PathIsMissing.emit("")

    def decompile_textures(self, cs2_path:str):
        def state_changed(state):
            if state != "Finished":
                self.decompilationStateChanged.emit(state)
            else:
                self.decompilationFinished.emit()
        
        self.decompilationStarted.emit()
        Decompiler.decompile(
            os.path.join(cs2_path, "game", "csgo", "pak01_dir.vpk"), 
            os.path.join(Settings.documents_path, "assets", "shaders", "custom-ui", "cs2", "assets", "textures"),
            self.weapon_list,
            state_changed,
            self.decompilationUpdated.emit
        )

    # Slots

    @QtCore.Slot()
    def ignoreTexturesMissing(self):
        Settings.set("ignore_textures_are_missing", True)

    @QtCore.Slot()
    def startTexturesDecompilation(self):
        self.state = InternalState.Decompiling
        cs2_path = Settings.get("cs2_path")
        if cs2_path is not None:
            self.decompile_textures(cs2_path)
        else:
            self.emit_cs2_path_is_missing()

    @QtCore.Slot(str, result=bool)
    def valCs2Path(self, path: str):
        if os.path.exists(os.path.join(path, "game", "csgo", "pak01_dir.vpk")):
            return True
        else:
            return False

    @QtCore.Slot(str, result=bool)
    def setCs2Path(self, cs2_path: str):
        Settings.set("cs2_path", cs2_path)
        if self.state == InternalState.Decompiling:
            self.decompile_textures(cs2_path)

    @QtCore.Slot(result=str)
    def getWeaponList(self):
        weapon_list:dict = Settings.get("weapon_list")
        return "&".join([f'{key}:{weapon_list.get(key)}' for key in weapon_list.keys()])
    
    @QtCore.Slot(str, str, int)
    def createNewWeaponFinish(self, file_path, weapon, finish_style):
        sp.project.create(
            file_path,

        )
        self.init_project()
    
    @QtCore.Slot(str)
    def openAsWeaponFinish(self, file_path):
        sp.project.open(file_path)
        self.init_project()
    