import json
import copy
import re
import substance_painter as sp

from .painter import UI, Log, Path, Resource, Plugin
from .painter.qml import QtWidgets, QmlDialog, QmlView, QtCore, QtGui

from .weapon_finish import WeaponFinish
from .weapons import WEAPONS_JSON


class MainView(QmlView):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("Plugin")
        
        def cb(container: QtWidgets.QWidget):
            container.setWindowIcon(icon)
            container.setWindowTitle("CS2 Workshop Tools")
            container.setObjectName("CS2WorkshopTools.MainView")
            # Painter may restore a closed dock as hidden after a plugin reload.
            # Explicitly show it so a successful restart has a usable panel.
            dock = UI.add_dock(container)
            dock.show()

        self.load(path, cb)
        
    # signals
    projectKindChanged = QtCore.Signal(int)
    projectAboutToSave = QtCore.Signal()
    styleReady = QtCore.Signal()
    pluginAboutToClose = QtCore.Signal()

    # slots
    @QtCore.Slot(str, result=str)
    def importTexture(self, path:str) -> str:
        return Resource.import_session_resource(path, Resource.Usage.TEXTURE, group="CS2").identifier().url()
        
    @QtCore.Slot(str)
    def showInExplorer(self, path:str):
        Path.show_in_explorer(path)
        
    @QtCore.Slot(result=str)
    def getWeapons(self):
        return WEAPONS_JSON

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
        
    @QtCore.Slot(str, result=str)
    def updateWeapon(self, weapon: str):
        return json.dumps(WeaponFinish.update_weapon(weapon))

    @QtCore.Slot(str)
    def updateStyle(self, style: str):
        def change(res: bool, msg: str):
            if res:
                Log.warning(msg) 
                self.styleReady.emit()
            else:
                Log.error(msg)
        WeaponFinish.update_style(style, change)

    @QtCore.Slot(str)
    def updateEconPath(self, path: str):
        WeaponFinish.set("econitem", path)
        
    @QtCore.Slot(str)
    def updateTexturesFolderPath(self, path: str):
        WeaponFinish.set("texturesFolder", path)
        
    @QtCore.Slot()
    def importWeaponFinishEcon(self):
        WeaponFinish.import_econ()

    @QtCore.Slot()
    def exportWeaponFinishEcon(self):
        try:
            WeaponFinish.export_econ()
        except Exception as error:
            Log.error(f"Failed to export .econitem: {error}")

    @QtCore.Slot()
    def exportWeaponFinishTextures(self):
        try:
            WeaponFinish.export_textures()
        except Exception as error:
            Log.error(f"Failed to export textures: {error}")

    @QtCore.Slot(result=str)
    def getFinishStyles(self):
        return json.dumps(Plugin.settings.get("finish_styles", {}))

    @QtCore.Slot(result=str)
    def getPreviewEnvs(self) -> str:
        return json.dumps({e: Path.filename(e) for e in Path.listdir(Path.asset("envs"))})

    @QtCore.Slot(str)
    def setPreviewEnv(self, env: str) -> None:
        if WeaponFinish.is_open():
            sp.display.set_environment_resource(Resource.import_session_resource(
                Path.asset("envs", env), 
                Resource.Usage.ENVIRONMENT, 
                Path.filename(env), 
                "CS2"
            ).identifier())

    @QtCore.Slot(result=str)
    def getDefaultWeaponFinishParameters(self) -> str:
        return json.dumps(Plugin.settings.get("weapon_finish", {}))

    @QtCore.Slot(str, result=str)
    def getDefaultWeaponFinishParameter(self, parameter: str) -> str:
        return json.dumps(Plugin.settings.get("weapon_finish", {}).get(parameter))

    @QtCore.Slot(str)
    def setDefaultWeaponFinishParameters(self, parameters: str):
        Plugin.settings["weapon_finish"] = json.loads(parameters)
        Log.warning("Updated default weapon finish parameters")


class WeaponFinishInitWindow(QmlDialog):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("Create Weapon Finish", icon, "Plugin", path)
        self.view.setMinimumSize(QtCore.QSize(400, 260))
        self.is_new = False
    
    opened = QtCore.Signal(bool)
    
    def open(self, is_new: bool):
        self.is_new = is_new
        self.window.setWindowTitle("Create Weapon Finish" if is_new else "Set up Weapon Finish")
        self.opened.emit(is_new)
        self.show()
        
    def on_confirmed(self, data: str):
        d: dict = json.loads(data)
        mesh_file: str = d.get("mesh", "")
        # fetch default weapon finish settings
        weapon_finish: dict = copy.deepcopy(Plugin.settings.get("weapon_finish", {}))
        weapon_finish.update(econitem="", texturesFolder="", **{key: d.get(key) for key in ("name", "style", "weapon")})
        
        def callback(res: bool, msg: str):
            if res:
                from . import CS2WT
                CS2WT.main_view.projectKindChanged.emit(2)
                Log.warning(msg)
            else:
                Log.error(f'Failed to set up weapon finish: {msg}')
                
        if self.is_new:
            WeaponFinish.create(mesh_file, weapon_finish, callback)
        else:
            WeaponFinish.set_up(weapon_finish, callback)
            
    @QtCore.Slot(result=str)
    def getFinishStyles(self):
        return json.dumps(Plugin.settings.get("finish_styles", {}))

    @QtCore.Slot(result=str)
    def getDefaultStyle(self):
        return Plugin.settings.get("weapon_finish", {}).get("style", "gs")

    @QtCore.Slot(result=str)
    def getWeapons(self):
        return WEAPONS_JSON

    @QtCore.Slot(str, result=int)
    def valWeaponFinishName(self, name: str):
        if not re.fullmatch(r"[A-Za-z0-9_-]+", name):
            return 2
        cs2_path = Plugin.settings.get("cs2_path")
        if not cs2_path:
            return 0
        return 3 if Path.exists(Path.join(
            cs2_path, "content", "csgo_addons", "workshop_items", "items",
            "assets", "paintkits", "workshop", f"{name}.econitem"
        )) else 1
    

class SettingsWindow(QmlDialog):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("CS2 Workshop Tools Settings", icon, "Plugin", path)
        self.view.setMinimumSize(QtCore.QSize(600, 425))
        
    def on_confirmed(self, data: str) -> None:
        settings = json.loads(data)
        settings.pop("weapons", None)
        Plugin.settings.update(settings)
        Plugin.save()

    @QtCore.Slot(result=str)
    def getWeapons(self):
        return WEAPONS_JSON
            
    @QtCore.Slot(str, result=bool)
    def valCs2Path(self, path: str) -> bool:
        return Path.isdir(Path.join(path, "content", "csgo")) and Path.isdir(Path.join(path, "game", "csgo"))

    @QtCore.Slot(str, result=bool)
    def checkWeaponTextures(self, weapon: str) -> bool:
        return WeaponFinish.check_weapon_textures(weapon)
