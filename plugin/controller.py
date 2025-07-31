import json

from .utils import Decompiler
from .weapon_finish import WeaponFinish
from .painter import UI, Log, Path, Plugin, ProjectSettings
from .painter.qml import QtWidgets, QmlDialog, QmlView, QtCore, QtGui


class MainView(QmlView):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("Plugin")
        
        def cb(container: QtWidgets.QWidget):
            container.setWindowIcon(icon)
            container.setWindowTitle("CS2 Workshop Tools")
            UI.add_dock(container).setWindowIcon(icon)

        self.load(path, cb)
        
    # signals
    cs2PathIsMissing = QtCore.Signal()
    projectKindChanged = QtCore.Signal(int)
    projectAboutToSave = QtCore.Signal()
    styleReady = QtCore.Signal()
    pluginAboutToClose = QtCore.Signal()

    # slots
    @QtCore.Slot(str)
    def changeStyle(self, finish_style: str):
        def change(res: bool, msg: str):
            if res:
                Log.warning(msg) 
                self.styleReady.emit()
            else:
                Log.error(msg)

        # update shader instance
        WeaponFinish.change_finish_style_shader(finish_style, change)

    @QtCore.Slot()
    def openSettings(self):
        from . import CS2WT
        CS2WT.on_settings()
        
    @QtCore.Slot(str)
    def showInExplorer(self, path:str):
        Path.show_in_explorer(path)
        
    @QtCore.Slot(result=str)
    def getWeaponList(self):
        return json.dumps(Plugin.settings.get("weapon_list"))

    @QtCore.Slot(bool)
    def initWeaponFinish(self, is_new: bool):
        from . import CS2WT
        CS2WT.wf_init_window.open(is_new)
        
    @QtCore.Slot(result=str)
    def getWeaponFinish(self):
        return json.dumps(WeaponFinish.current())
        
    @QtCore.Slot(str)
    def dumpWeaponFinish(self, weapon_finish: str):
        WeaponFinish.dump(json.loads(weapon_finish))
        
    @QtCore.Slot(str)
    def updateEconItemPath(self, path: str):
        WeaponFinish.set("econitem", path)
        
    @QtCore.Slot(str)
    def updateTexturesFolderPath(self, path: str):
        WeaponFinish.set("texturesFolder", path)
        
    @QtCore.Slot()
    def syncWeaponFinish(self):
        WeaponFinish.export_econ()

    @QtCore.Slot()
    def importWeaponFinishEconItem(self):
        WeaponFinish.import_econ()

    @QtCore.Slot()
    def exportWeaponFinishTextures(self):
        WeaponFinish.export_textures()


class WeaponFinishInitWindow(QmlDialog):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("Create Weapon Finish", icon, "Plugin", path)
        self.window.setMinimumSize(400, 260)
        self.is_new = False
    
    opened = QtCore.Signal(bool)
    
    def open(self, is_new: bool):
        self.show()
        self.is_new = is_new
        self.opened.emit(is_new)
    
    def on_confirmed(self, data: str):
        d: dict = json.loads(data)
        mesh_file: str = d.get("mesh", "")
        # fetch default weapon finish settings
        weapon_finish = Plugin.settings.get("weapon_finish", {})
        weapon_finish["name"] = d.get("name")
        weapon_finish["style"] = d.get("style")
        weapon_finish["weapon"] = d.get("weapon")
        
        def callback(res: bool, msg: str):
            if res:
                from . import CS2WT
                ProjectSettings.set("weapon_finish", weapon_finish)
                CS2WT.main_view.projectKindChanged.emit(2)
                Log.warning(msg)
            else:
                Log.error(f'Failed to set up weapon finish: {msg}')
                
        if self.is_new:
            WeaponFinish.create(mesh_file, weapon_finish, callback)
        else:
            WeaponFinish.set_up(weapon_finish, callback)
            
    @QtCore.Slot(result=str)
    def getDefaultStyle(self):
        return Plugin.settings.get("weapon_finish", {}).get("style", "gs")

    @QtCore.Slot(result=str)
    def getWeaponList(self):
        return json.dumps(Plugin.settings.get("weapon_list"))

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
    
    
class SettingsWindow(QmlDialog):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("CS2 Workshop Tools Settings", icon, "Plugin", path)
        self.window.setMinimumSize(735, 425)
        
    def on_confirmed(self, data: str) -> None:
        for key, value in json.loads(data).items():
            Plugin.settings[key] = value
            
    # signals
    decompilationStarted = QtCore.Signal()
    decompilationUpdated = QtCore.Signal(float, str)
    decompilationStateChanged = QtCore.Signal(str)
    decompilationFinished = QtCore.Signal()

    # slots
    @QtCore.Slot(str, result=bool)
    def valCs2Path(self, path: str) -> bool:
        return Path.exists(Path.join(path, "game", "csgo", "pak01_dir.vpk"))
    
    @QtCore.Slot(str, result=bool)
    def checkWeaponTextures(self, weapon:str) -> bool:
        return Decompiler.check_weapon_textures(weapon)
        
    @QtCore.Slot(list)
    def startDecompilation(self, weapon_list: list):
        def state_changed(state):
            if state != "Finished":
                self.decompilationStateChanged.emit(state)
            else:
                self.decompilationFinished.emit()
        
        self.decompilationStarted.emit()
        Decompiler.decompile(
            Path.join(Plugin.settings.get("cs2_path"), "game", "csgo", "pak01_dir.vpk"), 
            Path.asset("textures"),
            weapon_list,
            state_changed,
            self.decompilationUpdated.emit
        )
