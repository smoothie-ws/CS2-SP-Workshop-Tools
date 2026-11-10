import json
import copy
import os
import substance_painter as sp

from .econ import format_parameters, import_parameters, STYLE_CODES
from .texture_export import export_textures
from .shader_state import capture_main_shader, restore_shader
from .weapons import WEAPONS
from .painter import Log, Path, Macro, Plugin, Resource, ProjectSettings


_TEXTURE_PARAMETERS = {
	"g_tColor": "color", "g_tMetalness": "rough", "g_tSurface": "normal",
	"g_tMasks": "masks", "g_tAmbientOcclusion": "cavity",
}


def _texture_path(folder, weapon, texture):
	path = Path.join(folder, f"{weapon}_{texture}.png")
	# Keep the legacy filename as a fallback without moving user files.
	if texture == "normal" and not os.path.isfile(path):
		return Path.join(folder, f"{weapon}_surface.png")
	return path


class WeaponFinish:
	_pending_setups = {}
	_generation = 0

	@staticmethod
	def cancel_pending_setups():
		WeaponFinish._generation += 1
		for callback, state in tuple(WeaponFinish._pending_setups.items()):
			state["cancelled"] = True
			try:
				sp.event.DISPATCHER.disconnect(sp.event.ShelfCrawlingEnded, callback)
			except Exception as error:
				Log.error(f"Failed to cancel pending Weapon Finish setup: {error}")
		WeaponFinish._pending_setups.clear()

	@staticmethod
	def current() -> dict:
		try:
			project_is_open = sp.project.is_open()
		except Exception as error:
			Log.error(f"Could not check current project state: {error}")
			return None
		if not project_is_open:
			return None
		try:
			value = ProjectSettings.get("weapon_finish")
		except Exception as error:
			Log.error(f"Could not read Weapon Finish project settings: {error}")
			return None
		if value is None:
			return None
		if not isinstance(value, dict):
			Log.error("Weapon Finish project settings are malformed; use Set Up to repair them")
			return None
		if value and value.get("style") not in STYLE_CODES:
			value = dict(value, style="cu")
			Log.warning("Unsupported finish style replaced with Custom Paint Job")
		return value

	@staticmethod
	def dump(weapon_finish: dict):
		if not isinstance(weapon_finish, dict):
			raise TypeError("Weapon Finish settings must be an object")
		ProjectSettings.set("weapon_finish", weapon_finish)

	@staticmethod
	def set(key: str, value):
		weapon_finish = WeaponFinish.current()
		if weapon_finish is None:
			raise RuntimeError("Open or set up a Weapon Finish project first")
		weapon_finish[key] = value
		WeaponFinish.dump(weapon_finish)

	@staticmethod
	def is_open() -> bool:
		return WeaponFinish.current() is not None

	@staticmethod
	def create(mesh_file: str, weapon_finish: dict, callback):
		if not mesh_file or not os.path.isfile(mesh_file):
			callback(False, "Select an existing mesh file")
			return
		if sp.project.is_open():
			try:
				if sp.project.needs_saving():
					if not sp.project.file_path():
						callback(False, "Save the current project with Save As before creating a new project")
						return
					sp.project.save()
					if sp.project.needs_saving():
						callback(False, "Current project has not finished saving; creation cancelled")
						return
				sp.project.close()
			except Exception as error:
				callback(False, f"Failed to save or close current project: {error}")
				return
		try:
			sp.project.create(
				mesh_file_path=mesh_file,
				settings=sp.project.Settings(
					import_cameras=False,
					normal_map_format=sp.project.NormalMapFormat.OpenGL,
					tangent_space_mode=sp.project.TangentSpace.PerVertex
				)
			)
			generation = WeaponFinish._generation

			def set_up_when_ready():
				if generation == WeaponFinish._generation:
					WeaponFinish.set_up(weapon_finish, callback)

			sp.project.execute_when_not_busy(set_up_when_ready)
		except Exception as e:
			callback(False, f'Failed to create Weapon finish: {str(e)}')

	@staticmethod
	def set_up(weapon_finish: dict, callback):
		try:
			project_is_open = sp.project.is_open()
		except Exception as error:
			callback(False, f"Could not check the current project: {error}")
			return
		if not project_is_open:
			callback(False, "Open a project before setting up Weapon Finish")
			return
		if not isinstance(weapon_finish, dict):
			callback(False, "Weapon Finish settings must be an object")
			return
		try:
			weapon_finish = copy.deepcopy(weapon_finish)
			previous = copy.deepcopy(ProjectSettings.get("weapon_finish"))
		except Exception as error:
			callback(False, f"Could not read the current project settings: {error}")
			return
		finish_name = weapon_finish.get("name", "")
		finish_style = weapon_finish.get("style", "gs")
		allowed_name_characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-"
		if (not isinstance(finish_name, str) or not finish_name or
				any(c not in allowed_name_characters for c in finish_name) or
				not isinstance(finish_style, str) or finish_style not in STYLE_CODES):
			callback(False, "Invalid finish name or unsupported style")
			return
		journal = []
		created_directories = []
		shader_snapshot = None
		delayed = False
		pending_state = {"cancelled": False}
		proceeded = False

		def ensure_directory(path):
			missing = []
			parent = os.path.abspath(path)
			while not os.path.exists(parent):
				missing.append(parent)
				parent = os.path.dirname(parent)
			for directory in reversed(missing):
				os.mkdir(directory)
				created_directories.append(directory)

		def rollback():
			# Remove only empty directories created by this operation.
			for directory in reversed(created_directories):
				try:
					os.rmdir(directory)
				except OSError as error:
					Log.error(f"Could not remove setup directory {directory}: {error}")
			for stack, channel_type, original in reversed(journal):
				try:
					if original is None:
						stack.remove_channel(channel_type)
					else:
						stack.edit_channel(channel_type, *original)
				except Exception as error:
					Log.error(f"Failed to restore channel {channel_type}: {error}")
			try:
				if shader_snapshot is not None:
					# The generic serializer stores only a shader name and can resolve
					# an older resource with the same name. Restore the exact version
					# and its parameter values. Setup only ever changes instance 0.
					restore_shader(shader_snapshot)
			except Exception as error:
				Log.error(f"Failed to restore shader state: {error}")
			try:
				if previous is None:
					ProjectSettings.remove("weapon_finish")
				else:
					WeaponFinish.dump(previous)
			except Exception as error:
				Log.error(f"Failed to restore project metadata: {error}")

		def proceed(_):
			nonlocal shader_snapshot, delayed, proceeded
			if pending_state["cancelled"] or proceeded:
				return
			if delayed:
				if getattr(_, "shelf_name", "session") != "session":
					return
				try:
					sp.event.DISPATCHER.disconnect(sp.event.ShelfCrawlingEnded, proceed)
				except Exception as error:
					Log.error(f"Failed to disconnect completed Weapon Finish setup: {error}")
				finally:
					WeaponFinish._pending_setups.pop(proceed, None)
					delayed = False
			proceeded = True
			try:
				new_stack = {
					sp.textureset.ChannelType.BaseColor: (sp.textureset.ChannelFormat.sRGB8, None),
					sp.textureset.ChannelType.Roughness: (sp.textureset.ChannelFormat.L8, None),
					sp.textureset.ChannelType.User0: (sp.textureset.ChannelFormat.RGB8, "Masks"),
					sp.textureset.ChannelType.User1: (sp.textureset.ChannelFormat.L8, "Alpha"),
					sp.textureset.ChannelType.User2: (sp.textureset.ChannelFormat.L8, "Pearlescence")
				}
				shader_snapshot = capture_main_shader()
				cs2_path = Plugin.settings.get("cs2_path")
				if cs2_path and not (Path.isdir(Path.join(cs2_path, "content", "csgo")) and Path.isdir(Path.join(cs2_path, "game", "csgo"))):
					raise ValueError("Invalid CS2 path; select a CS2 installation or clear the path in settings")
				stacks = [stack for texture_set in sp.textureset.all_texture_sets()
					for stack in texture_set.all_stacks()]
				if not stacks:
					raise ValueError("Project contains no texture set stacks")
				# Existing channel data and additional channels are preserved. Changing
				# their bit depth can be lossy, so validate before modifying any stack.
				for stack in stacks:
					for channel_type, (channel_format, _) in new_stack.items():
						if stack.has_channel(channel_type) and stack.get_channel(channel_type).format() != channel_format:
							raise ValueError(f"Existing {channel_type} has an incompatible format; convert it explicitly before setup")
				for stack in stacks:
					for channel_type, (channel_format, label) in new_stack.items():
						if stack.has_channel(channel_type):
							channel = stack.get_channel(channel_type)
							if label is not None and channel.label() != label:
								journal.append((stack, channel_type, (channel.format(), channel.label())))
								stack.edit_channel(channel_type, channel_format, label)
						else:
							journal.append((stack, channel_type, None))
							stack.add_channel(channel_type, channel_format, label)
				WeaponFinish.dump(weapon_finish)
			except Exception as error:
				rollback()
				callback(False, f"Failed to set up document channels: {error}")
				return

			def style_ready(success, message):
				if not success:
					rollback()
					callback(False, message)
					return
				try:
					cs2_path = Plugin.settings.get("cs2_path")
					if cs2_path and Path.isdir(cs2_path):
						textures_folder = Path.join(cs2_path, "content", "csgo_addons", "workshop_items", "weapons", "paints", "workshop", finish_name)
						econitem = Path.join(cs2_path, "content", "csgo_addons", "workshop_items", "items", "assets", "paintkits", "workshop", f"{finish_name}.econitem")
						if Path.exists(econitem):
							raise FileExistsError(f"Refusing to overwrite existing .econitem: {econitem}")
						ensure_directory(textures_folder)
						ensure_directory(os.path.dirname(econitem))
						weapon_finish["texturesFolder"] = textures_folder
						weapon_finish["econitem"] = econitem
						WeaponFinish.dump(weapon_finish)
						WeaponFinish.export_econ()
				except Exception as error:
					rollback()
					callback(False, f"Failed to create finish files: {error}")
					return
				callback(True, f"Project set up as Weapon Finish ({finish_style.upper()})")

			WeaponFinish.update_style(finish_style, style_ready)

		try:
			if sp.resource.Shelf("session").is_crawling():
				delayed = True
				WeaponFinish._pending_setups[proceed] = pending_state
				try:
					sp.event.DISPATCHER.connect_strong(sp.event.ShelfCrawlingEnded, proceed)
				except Exception:
					WeaponFinish._pending_setups.pop(proceed, None)
					delayed = False
					pending_state["cancelled"] = True
					try:
						sp.event.DISPATCHER.disconnect(sp.event.ShelfCrawlingEnded, proceed)
					except Exception as cleanup_error:
						Log.error(f"Failed to remove partial shelf listener: {cleanup_error}")
					raise
			else:
				proceed(None)
		except Exception as error:
			if not proceeded:
				pending_state["cancelled"] = True
				WeaponFinish._pending_setups.pop(proceed, None)
				callback(False, f"Could not prepare Weapon Finish setup: {error}")
			else:
				Log.error(f"Unexpected error after Weapon Finish setup started: {error}")

	@staticmethod
	def update_style(fs: str, callback):
		try:
			if not WeaponFinish.is_open():
				raise ValueError("No Weapon Finish project is open")
			if fs not in STYLE_CODES:
				raise ValueError(f"Unsupported finish style: {fs}")
			shader_source = Path.read(Path.asset("shader", "cs2.glsl"))
			if not shader_source:
				raise FileNotFoundError(f"Missing shader source for {fs}")
			shader_dir = Path.join(Path.plugin, "shaders")
			os.makedirs(shader_dir, exist_ok=True)
			name = f"cs2_{fs}"
			path = Path.join(shader_dir, f"{name}.glsl")
			shader_text = Macro.process(shader_source, {"PAINT_STYLE": STYLE_CODES.index(fs)})
			if not Path.write(path, shader_text):
				raise OSError(f"Failed to write shader: {path}")
			shader_resource = Resource.import_session_resource(path, Resource.Usage.SHADER, name, "CS2")
			icon_path = Path.asset("icons", f"{name}.png")
			if Path.exists(icon_path):
				shader_resource.set_custom_preview(icon_path)
			sp.js.evaluate(f'alg.shaders.updateShaderInstance(0, {json.dumps(shader_resource.identifier().url())})')
		except Exception as error:
			callback(False, f"Failed to set finish style: {error}")
			return
		callback(True, f'Finish Style was set to `{fs.upper()}`')

	@staticmethod
	def weapon_texture_path(weapon: str, texture: str):
		if weapon not in WEAPONS:
			return ""
		return _texture_path(Path.asset("textures", "models", weapon), weapon, texture)

	@staticmethod
	def check_weapon_textures(weapon: str) -> bool:
		if weapon not in WEAPONS:
			return False
		folder = Path.asset("textures", "models", weapon)
		return all(os.path.isfile(_texture_path(folder, weapon, texture))
			for texture in ("color", "cavity", "masks", "rough", "normal"))

	@staticmethod
	def update_weapon(weapon: str):
		resources = {}
		weapon_finish = WeaponFinish.current()
		if weapon_finish is not None:
			weapon_finish["weapon"] = weapon
			WeaponFinish.dump(weapon_finish)
			if weapon not in WEAPONS:
				return resources
			folder = Path.asset("textures", "models", weapon)
			for param, texture in _TEXTURE_PARAMETERS.items():
				tex_path = _texture_path(folder, weapon, texture)
				if Path.exists(tex_path):
					resources[param] = Resource.import_session_resource(tex_path, Resource.Usage.TEXTURE, group="CS2").identifier().url()
		return resources

	@staticmethod
	def import_econ():
		weapon_finish = WeaponFinish.current()
		if not weapon_finish or not weapon_finish.get("econitem"):
			return False
		try:
			with open(weapon_finish["econitem"], encoding="utf-8-sig") as source:
				values = import_parameters(source.read(), weapon_finish,
					Plugin.settings.get("finish_styles", {}))
			if values.get("weapon") != weapon_finish.get("weapon"):
				for parameter in _TEXTURE_PARAMETERS:
					values[parameter] = ""
			WeaponFinish.dump(values)
		except (OSError, ValueError, TypeError) as error:
			Log.error(f"Failed to import .econitem: {error}")
			return False
		Log.info("Imported parameters from .econitem")
		return True

	@staticmethod
	def export_econ():
		weapon_finish: dict = WeaponFinish.current()
		if weapon_finish is None:
			raise RuntimeError("Open or set up a Weapon Finish project first")
		econitem = weapon_finish.get("econitem") or ""
		if not econitem:
			return
		textures_folder = weapon_finish.get("texturesFolder", "")
		if not Path.exists(textures_folder):
			Log.info(f'Be careful: path "{textures_folder}" for textures does not exist!')
		textures_folder = textures_folder.replace("\\", "/").split("workshop_items")[-1].removeprefix("/")
		content = format_parameters(
			Path.read(Path.asset("template.econitem")), weapon_finish,
			Plugin.settings.get("finish_styles", {}), Path.filename(econitem), textures_folder
		)
		os.makedirs(os.path.dirname(os.path.abspath(econitem)), exist_ok=True)
		if not Path.write(econitem, content) > 0:
			raise OSError(f"Failed to export .econitem file: {econitem}")

	@staticmethod
	def export_textures():
		weapon_finish = WeaponFinish.current()
		if weapon_finish is None:
			raise RuntimeError("Open or set up a Weapon Finish project first")
		export_textures(weapon_finish)
