import json
import substance_painter as sp

from .utils import Decompiler
from .weapon_finish import WeaponFinish
from .painter import UI, Log, Path, Plugin, ProjectSettings
from .painter.qml import QtWidgets, QmlDialog, QmlView, QtCore, QtGui


class WeaponFinishInitWindow(QmlDialog):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("Create Weapon Finish", icon, "Plugin", path)
        self.window.setMinimumSize(400, 250)
        self.is_new = False
    
    opened = QtCore.Signal(bool)
    
    def open(self, is_new: bool):
        super().open()
        self.is_new = is_new
        self.opened.emit(is_new)
    
    def on_confirmed(self, data: str):
        d: dict = json.loads(data)
        
        file_path = d.get("file_path")
        finish_name = d.get("finish_name")
        weapon = d.get("weapon")
        finish_style = d.get("finish_style")
        
        if self.is_new:
            def callback(res, weapon_finish, msg):
                if res:
                    ProjectSettings.set("weapon_finish", weapon_finish)
                    self.on_project_opened()
                    Log.warning(msg)
                else:
                    Log.error(f'Failed to create weapon finish: {msg}')
            WeaponFinish.create(file_path, finish_name, weapon, finish_style, callback)
        else:
            def callback(res, msg):
                if res:
                    self.projectKindChanged.emit(2)
                    Log.warning(msg)
                else:
                    Log.error(f'Failed to set up weapon finish: {msg}')
            WeaponFinish.set_up(finish_name, weapon, finish_style, callback)
            
    @QtCore.Slot(result=str)
    def getDefaultFinishStyle(self):
        return Plugin.settings.get("weapon_finish", {}).get("finishStyle", "gs")

    @QtCore.Slot(result=str)
    def getWeaponList(self):
        return json.dumps(Plugin.settings.get("weapon_list"))

    
class DockView(QmlView):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("Plugin")
        self.wf_init_window = WeaponFinishInitWindow(QmlView.plugin_file("WeaponFinishInitWindow.qml"), icon)
        
        def cb(container: QtWidgets.QWidget):
            container.setWindowIcon(icon)
            container.setWindowTitle("CS2 Workshop Tools")
            UI.add_dock(container)

        self.load(path, cb)
        
    def decompile_textures(self, cs2_path: str):
        def state_changed(state):
            if state != "Finished":
                self.decompilationStateChanged.emit(state)
            else:
                self.decompilationFinished.emit()
        
        self.decompilationStarted.emit()
        Decompiler.decompile(
            Path.join(cs2_path, "game", "csgo", "pak01_dir.vpk"), 
            Path.asset("textures"),
            self.missing_weapon_list,
            state_changed,
            self.decompilationUpdated.emit
        )

    # signals
    texturesAreMissing = QtCore.Signal()
    cs2PathIsMissing = QtCore.Signal(str)
    decompilationStarted = QtCore.Signal()
    decompilationUpdated = QtCore.Signal(float, str)
    decompilationStateChanged = QtCore.Signal(str)
    decompilationFinished = QtCore.Signal()
    projectKindChanged = QtCore.Signal(int)
    finishStyleReady = QtCore.Signal()
    pluginAboutToClose = QtCore.Signal()

    # slots
    @QtCore.Slot(bool)
    def setIgnoreTexturesAreMissing(self, ignore:bool):
        Plugin.settings["ignore_textures_are_missing"] = ignore

    @QtCore.Slot()
    def startTexturesDecompilation(self):
        cs2_path = Plugin.settings.get("cs2_path")
        if cs2_path is not None:
            self.decompile_textures(cs2_path)
        else:
            self.emit_cs2_path_is_missing()

    @QtCore.Slot(str, result=bool)
    def setCs2Path(self, cs2_path: str):
        Plugin.settings["cs2_path"] = cs2_path
        self.decompile_textures(cs2_path)

    @QtCore.Slot(str, result=int)
    def valWeaponFinishName(self, name: str):
        cs2_path = Plugin.settings.get("cs2_path")
        if cs2_path:
            if len(name) > 0:
                if Path.exists(Path.join(cs2_path, 
                    "content", "csgo_addons", "workshop_items", "items", "assets", "paintkits", "workshop", 
                    f'{name}.econitem'
                )):
                    return 3
                else:
                    return 1
            else:
                return 2
        else:
            return 0
        
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

    @QtCore.Slot(bool)
    def initWeaponFinish(self, is_new: bool):
        self.wf_init_window.open(is_new)
        
    @QtCore.Slot(result=str)
    def getWeaponFinish(self):
        return json.dumps(ProjectSettings.get("weapon_finish"))
        
    @QtCore.Slot(str)
    def dumpWeaponFinish(self, weapon_finish: str):
        ProjectSettings.set("weapon_finish", json.loads(weapon_finish))
        
    @QtCore.Slot(str)
    def syncWeaponFinish(self, weapon_finish: str):
        self.dumpWeaponFinish(weapon_finish)
        WeaponFinish.export_econ(json.loads(weapon_finish))

    @QtCore.Slot(str)
    def importWeaponFinishEconItem(self, weapon_finish: str):
        self.dumpWeaponFinish(weapon_finish)
        WeaponFinish.import_econ(json.loads(weapon_finish))

    @QtCore.Slot(str)
    def exportWeaponFinishTextures(self, weapon_finish: str):
        self.dumpWeaponFinish(weapon_finish)
        WeaponFinish.export_textures(json.loads(weapon_finish))

    @QtCore.Slot(result=str)
    def getWeaponList(self):
        return json.dumps(Plugin.settings.get("weapon_list"))


class SettingsWindow(QmlDialog):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("CS2 Workshop Tools Settings", icon, "Plugin", path)
        self.window.setMinimumSize(735, 425)
        
    def on_confirmed(self, data: str):
        for key, value in json.loads(data).items():
            Plugin.settings[key] = value
            

class ClearDocsWindow(QmlDialog):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("Clear CS2 Workshop Tools Documents", icon, "Plugin", path)
        self.window.setMinimumSize(400, 250)
        
    def on_confirmed(self, _: str):
        total = 0
        for path in Plugin.settings.get("files", []):
            if Path.remove(path):
                total += 1
        Log.warning(f'Removed {total} files')
