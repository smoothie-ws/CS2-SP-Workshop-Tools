import json
import shutil
import substance_painter as sp


from ..settings import Settings
from ..weapon_finish import WeaponFinish
from ..project_settings import ProjectSettings
from ..utils import Log, Path, Decompiler, shader_preprocess, resource_search

from .qml import QmlInternal, QmlWidget, QtCore, QtWidgets, QtGui


class DockView(QmlWidget):
    def __init__(self, path: str, icon: QtGui.QIcon):
        super().__init__()
        self.internals.append(DockInternal())
        self.widget = None

        def cb(container: QtWidgets.QWidget):
            container.setWindowIcon(icon)
            container.setWindowTitle("CS2 Workshop Tools")
            self.widget = sp.ui.add_dock_widget(container)

        self.load(path, cb)
    

class DockInternal(QmlInternal):
    def __init__(self):
        super().__init__("CS2WT")
        
    def on_project_opened(self):
        if self.is_weapon_finish_opened():
            self.projectKindChanged.emit(2)
        else:
            self.projectKindChanged.emit(1)

    def on_project_about_to_close(self):
        self.projectKindChanged.emit(0)

    def on_close(self):
        if self.is_weapon_finish_opened():
            self.pluginAboutToClose.emit()
        
    def is_weapon_finish_opened(self):
        return sp.project.is_open() and ProjectSettings.get("weapon_finish")
    
    def checkout_weapon_textures(self):
        sp_shaders_path = Path.join(Settings.documents_path, "assets", "shaders")
        sp_shaders_ui_path = Path.join(sp_shaders_path, "custom-ui")

        shader_path = Path.get_asset_path("shader")

        # shader files
        with open(Path.get_asset_path("shader", "cs2.glsl"), "r", encoding="utf-8") as f:
            shader_source = f.read()

        for i, fs in enumerate(WeaponFinish.FINISH_STYLES):
            sp_shader_file_path = Path.join(sp_shaders_path, f'cs2_{fs}.glsl')
            if not Path.exists(sp_shader_file_path):
                with open(sp_shader_file_path, "w", encoding="utf-8") as f:
                    f.write(shader_preprocess(shader_source, {"FINISH_STYLE": i}))
                    Settings.push_file(sp_shader_file_path)

        def set_previews(shader_resources):
            for shader_resource in shader_resources:
                name = shader_resource.identifier().name
                shader_resource.set_custom_preview(Path.get_asset_path("ui", "icons", f'{name}.png'))

        resource_search(set_previews, "your_assets", "shader", "cs2")

        # shader ui
        sp_shader_ui_path = Path.join(sp_shaders_ui_path, "cs2-ui.qml")
        if not Path.exists(Path.join(sp_shaders_ui_path, "cs2-ui.qml")):
            shutil.copyfile(Path.join(shader_path, "cs2-ui.qml"), sp_shader_ui_path)
            Settings.push_file(sp_shader_ui_path)

        # weapon textures
        weapon_list = Settings.get("weapon_list", {}).copy()
        models_path = Path.get_asset_path("textures", "models")
        if Path.exists(models_path):
            for weapon in Path.listdir(models_path):
                weapon_path = Path.join(models_path, weapon)
                if (Path.exists(Path.join(weapon_path, f'{weapon}_color.png')) and
                    Path.exists(Path.join(weapon_path, f'{weapon}_cavity.png')) and
                    Path.exists(Path.join(weapon_path, f'{weapon}_masks.png')) and
                    Path.exists(Path.join(weapon_path, f'{weapon}_rough.png')) and
                    Path.exists(Path.join(weapon_path, f'{weapon}_surface.png'))):
                    if weapon_list.get(weapon) is not None:
                        weapon_list.pop(weapon)

        if len(weapon_list) > 0 and not Settings.get("ignore_textures_are_missing"):
            self.texturesAreMissing.emit()

    def emit_cs2_path_is_missing(self):
        self.cs2PathIsMissing.emit()

    def decompile_textures(self, cs2_path:str):
        def state_changed(state):
            if state != "Finished":
                self.decompilationStateChanged.emit(state)
            else:
                self.decompilationFinished.emit()
        
        self.decompilationStarted.emit()
        Decompiler.decompile(
            Path.join(cs2_path, "game", "csgo", "pak01_dir.vpk"), 
            Path.get_asset_path("textures"),
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
    pluginAboutToClose = QtCore.Signal()

    # Slots
    @QtCore.Slot(str)
    def setPluginSettings(self, settings:str):
        for key, value in json.loads(settings).items():
            Settings.set(key, value)

    @QtCore.Slot(result=str)
    def getDefaultFinishStyle(self):
        return Settings.get("weapon_finish", {}).get("finishStyle", "gs")
    
    @QtCore.Slot(bool)
    def setIgnoreTexturesAreMissing(self, ignore:bool):
        Settings.set("ignore_textures_are_missing", ignore)

    @QtCore.Slot()
    def startTexturesDecompilation(self):
        cs2_path = Settings.get("cs2_path")
        if cs2_path is not None:
            self.decompile_textures(cs2_path)
        else:
            self.emit_cs2_path_is_missing()

    @QtCore.Slot(str, result=bool)
    def setCs2Path(self, cs2_path: str):
        Settings.set("cs2_path", cs2_path)
        self.decompile_textures(cs2_path)

    @QtCore.Slot(str, result=bool)
    def valCs2Path(self, path: str):
        if Path.exists(Path.join(path, "game", "csgo", "pak01_dir.vpk")):
            return True
        else:
            return False

    @QtCore.Slot(str, result=int)
    def valWeaponFinishName(self, name: str):
        cs2_path = Settings.get("cs2_path")
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
        
    @QtCore.Slot(str, str, str, str)
    def createWeaponFinish(self, file_path:str, finish_name:str, weapon:str, finish_style:str):
        def callback(res, weapon_finish, msg):
            if res:
                ProjectSettings.set("weapon_finish", weapon_finish)
                self.on_project_opened()
                Log.warning(msg)
            else:
                Log.error(f'Failed to create weapon finish: {msg}')
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
    def dumpWeaponFinish(self, weapon_finish:str):
        ProjectSettings.set("weapon_finish", json.loads(weapon_finish))
        
    @QtCore.Slot(str)
    def syncWeaponFinish(self, weapon_finish:str):
        self.dumpWeaponFinish(weapon_finish)
        WeaponFinish.sync_econ(json.loads(weapon_finish))

    @QtCore.Slot(str)
    def importWeaponFinishEconItem(self, weapon_finish:str):
        self.dumpWeaponFinish(weapon_finish)
        WeaponFinish.import_econitem(json.loads(weapon_finish))

    @QtCore.Slot(str)
    def exportWeaponFinishTextures(self, weapon_finish:str):
        self.dumpWeaponFinish(weapon_finish)
        WeaponFinish.export_textures(json.loads(weapon_finish))
