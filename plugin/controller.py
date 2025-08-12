import json

from .painter import UI, Log, Path, Resource, Plugin, ProjectSettings, Updates
from .painter.qml import QtWidgets, QmlDialog, QmlView, QtCore, QtGui

from .decompiler import Decompiler
from .weapon_finish import WeaponFinish


class MainView(QmlView):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("Plugin")
        
        def cb(container: QtWidgets.QWidget):
            container.setWindowIcon(icon)
            container.setWindowTitle("CS2 Workshop Tools")
            UI.add_dock(container)

        self.load(path, cb)
        
    # signals
    cs2PathIsMissing = QtCore.Signal()
    projectKindChanged = QtCore.Signal(int)
    projectAboutToSave = QtCore.Signal()
    styleReady = QtCore.Signal()
    pluginAboutToClose = QtCore.Signal()

    # slots
    @QtCore.Slot(str, result=str)
    def importTexture(self, path:str) -> str:
        return Resource.import_session_resource(path, Resource.Usage.TEXTURE).identifier().url()
        
    @QtCore.Slot(str)
    def showInExplorer(self, path:str):
        Path.show_in_explorer(path)
        
    @QtCore.Slot(result=str)
    def getWeapons(self):
        return json.dumps(Plugin.settings.get("weapons", {}))

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
        WeaponFinish.export_econ()

    @QtCore.Slot()
    def exportWeaponFinishTextures(self):
        WeaponFinish.export_textures()


class WeaponFinishInitWindow(QmlDialog):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("Create Weapon Finish", icon, "Plugin", path)
        self.view.setMinimumSize(QtCore.QSize(400, 260))
        self.is_new = False
    
    opened = QtCore.Signal(bool)
    
    def open(self, is_new: bool):
        self.is_new = is_new
        if is_new:
            self.window.setWindowTitle("Create Weapon Finish")
        else:
            self.window.setWindowTitle("Set up Weapon Finish")
        self.opened.emit(is_new)
        self.show()
        
    def on_confirmed(self, data: str):
        d: dict = json.loads(data)
        mesh_file: str = d.get("mesh", "")
        # fetch default weapon finish settings
        weapon_finish: dict = Plugin.settings.get("weapon_finish", {}).copy()
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
    def getWeapons(self):
        return json.dumps(Plugin.settings.get("weapons"))

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
    

class UpdateWindow(QmlDialog):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("CS2 Workshop Tools Update", icon, "Plugin", path)
        self.view.setMinimumSize(QtCore.QSize(500, 500))
        
    opened = QtCore.Signal(str, str)
    
    def check_for_updates(self):
        try:
            latest, commits_raw = Updates.check_for_updates("smoothie-ws/CS2-SP-Workshop-Tools", Plugin.version)
            if latest and commits_raw:
                self.latest = latest
                commits_added = []
                commits_fixed = []
                commits_misc = []
                for commit in commits_raw:
                    msg: str = commit["message"].lower().strip()
                    if msg.startswith("feat:"):
                        commit["message"] = msg[5:]
                        commits_added.append(commit)
                    elif msg.startswith("fix:"):
                        commit["message"] = msg[4:]
                        commits_fixed.append(commit)
                    else:
                        commits_misc.append(commit)
                        
                self.open(self.latest, [
                    { "name": "Added", "color": "#60206332", "commits": commits_added },
                    { "name": "Fixed", "color": "#60204E63", "commits": commits_fixed },
                    { "name": "Misc", "color": "#60612063", "commits": commits_misc }
                ])
        except Exception as e:
            Log.info(f'Failed to check for updates: {e}')
        
    def open(self, latest: str, commits: list):
        self.opened.emit(latest, json.dumps(commits))
        self.show()
    
    # signals
    downloadingStarted = QtCore.Signal()
    downloadingUpdated = QtCore.Signal(float)
    downloadingStateChanged = QtCore.Signal(str)
    downloadingFinished = QtCore.Signal()

    # slots
    @QtCore.Slot(str)
    def confirm(self, _: str):
        try:
            def state_changed(state):
                if state != "Finished" and state != "Error":
                    self.downloadingStateChanged.emit(state)
                else:
                    self.downloadingFinished.emit()
                    self.window.close()
                    if state == "Finished":
                        Plugin.version = self.latest
                        Log.warning(f'Installed version {Plugin.version}. Please restart the plugin to apply.')
                        
            self.downloadingStarted.emit()
            Updates.update(
                "smoothie-ws/CS2-SP-Workshop-Tools", 
                self.latest, 
                Path.join(Path.plugin, self.latest), 
                state_changed,
                self.downloadingUpdated.emit
            )
        except Exception as e:
            Log.error(f'Failed to download an update: {e}')
    
    @QtCore.Slot(result=bool)
    def getCheckForUpdates(self) -> bool:
        return Plugin.settings.get("check_for_updates", True)
    
    @QtCore.Slot(bool)
    def setCheckForUpdates(self, check: bool):
        Plugin.settings["check_for_updates"] = check
    

class SettingsWindow(QmlDialog):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__("CS2 Workshop Tools Settings", icon, "Plugin", path)
        self.view.setMinimumSize(QtCore.QSize(735, 425))
        
    def on_confirmed(self, data: str) -> None:
        for key, value in json.loads(data).items():
            Plugin.settings[key] = value
        Plugin.save()
            
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
        
    @QtCore.Slot()
    def checkForUpdates(self) -> None:
        from . import CS2WT
        CS2WT.update_window.check_for_updates()
        
    @QtCore.Slot(str, list)
    def startDecompilation(self, cs2_path, weapons: list):
        def state_changed(state):
            if state != "Finished":
                self.decompilationStateChanged.emit(state)
            else:
                self.decompilationFinished.emit()
        
        self.decompilationStarted.emit()
        Plugin.settings["cs2_path"] = cs2_path
        Decompiler.decompile(
            Path.join(cs2_path, "game", "csgo", "pak01_dir.vpk"), 
            Path.asset("textures"),
            weapons,
            state_changed,
            self.decompilationUpdated.emit
        )
