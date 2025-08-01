import math
import substance_painter as sp

from .painter import Log, Path, Plugin, Resource, ProjectSettings
from .utils import Decompiler


class WeaponFinish:
	FINISH_STYLES = [
		"so", # Solid Color
		"hy", # Hydrographic
		"sp", # Spray-Paint
		"an", # Anodized
		"am", # Anodized Multicolored
		"aa", # Anodized Airbrushed
		"cu", # Custom Paint Job
		"aq", # Patina
		"gs"  # Gunsmith
	]

	@staticmethod
	def current() -> dict:
		return ProjectSettings.get("weapon_finish")
    
	@staticmethod
	def dump(weapon_finish: dict):
		ProjectSettings.set("weapon_finish", weapon_finish)
        
	@staticmethod
	def set(key: str, value):
		weapon_finish = WeaponFinish.current()
		weapon_finish[key] = value
		WeaponFinish.dump(weapon_finish)
    
	@staticmethod
	def is_open() -> bool:
		return sp.project.is_open() and WeaponFinish.current() is not None
    
	@staticmethod
	def create(mesh_file: str, weapon_finish: dict, callback):
		# create project
		if sp.project.is_open():
			if sp.project.needs_saving() and sp.project.file_path() is not None:
				try:
					sp.project.save()
				except Exception as e:
					callback(False, f'Failed to save current project: {e}')
					return
			sp.project.close()
		try:
			sp.project.create(
				mesh_file_path=mesh_file, 
				settings=sp.project.Settings(
					import_cameras=False,
					normal_map_format=sp.project.NormalMapFormat.OpenGL,
					tangent_space_mode=sp.project.TangentSpace.PerVertex
				)
			)
			sp.project.execute_when_not_busy(lambda: WeaponFinish.set_up(weapon_finish, callback))
		except sp.exception.ProjectError as e:
			callback(False, f'Failed to create Weapon finish: {str(e)}')

	@staticmethod
	def set_up(weapon_finish: dict, callback):
		delayed = False
		finish_name: str = weapon_finish["name"]
		finish_style: str = weapon_finish["style"]
  
		def proceed(_):
			if delayed:
				sp.event.DISPATCHER.disconnect(sp.event.ShelfCrawlingEnded, proceed)

			# update the document channel stack
			new_stack = {
				sp.textureset.ChannelType.BaseColor: (sp.textureset.ChannelFormat.sRGB8, None),
				sp.textureset.ChannelType.Roughness: (sp.textureset.ChannelFormat.L8, None),
				sp.textureset.ChannelType.User0: (sp.textureset.ChannelFormat.RGB8, "Masks"),
				sp.textureset.ChannelType.User1: (sp.textureset.ChannelFormat.L8, "Alpha"),
				sp.textureset.ChannelType.User2: (sp.textureset.ChannelFormat.L8, "Pearlescence")
			}
			allowed_channels = [
				sp.textureset.ChannelType.BaseColor,
				sp.textureset.ChannelType.Roughness,
				sp.textureset.ChannelType.User0,
				sp.textureset.ChannelType.User1,
				sp.textureset.ChannelType.User2,
				sp.textureset.ChannelType.Height,
				sp.textureset.ChannelType.Normal
			]
			try:
				for texture_set in sp.textureset.all_texture_sets():
					for stack in texture_set.all_stacks():
						for channel_type, channel in new_stack.items():
							channel_format, channel_label = channel
							if stack.has_channel(channel_type):
								stack_channel = stack.get_channel(channel_type)
								if stack_channel.format() != channel_format or stack_channel.label() != channel_label:
									stack.edit_channel(channel_type, channel_format, channel_label)
							else:
								stack.add_channel(channel_type, channel_format, channel_label)
						# remove unnecessary channels 
						for channel_type, channel in stack.all_channels().items():
							if channel_type not in allowed_channels:
								stack.remove_channel(channel_type)
			except Exception as e:
				callback(False, f'Failed to set up the document channel stack: {str(e)}')
			
			# create files associated with the weapon finish
			cs2_path = Plugin.settings.get("cs2_path")
			if cs2_path is not None and Path.exists(cs2_path):

				# create folder for textures
				textures_folder = Path.join(cs2_path, "content", "csgo", "weapons", "paints", "workshop", finish_name)
				if not Path.exists(textures_folder):
					Path.makedirs(textures_folder)
					weapon_finish["texturesFolder"] = textures_folder
				else:
					Log.warning(f'Failed to create folder for textures: path "{textures_folder}" already exists')

				# create .econitem file
				econitem = Path.join(cs2_path, 
					"content", "csgo_addons", "workshop_items", "items", "assets", "paintkits", "workshop", 
					f'{finish_name}.econitem'
				)
				if not Path.exists(econitem):
					weapon_finish["econitem"] = econitem
					WeaponFinish.dump(weapon_finish)
					WeaponFinish.export_econ()
				else:
					Log.warning(f'Failed to create .econitem file: path "{econitem}" already exists')

			else:
				Log.warning("CS2 path not found. Please set it in the plugin settings menu")

			# update shader instance
			WeaponFinish.update_style(finish_style, 
				lambda res, msg: callback(res,
					f'The project was successfully set up as Weapon Finish ({finish_style.upper()})' 
     				if res else 
         			f'Failed to set finish style: {msg}'
				)
			)

		if sp.resource.Shelf("your_assets").is_crawling():
			delayed = True
			sp.event.DISPATCHER.connect_strong(sp.event.ShelfCrawlingEnded, proceed)
		else:
			proceed(None)

	@staticmethod
	def update_style(finish_style: str, callback):
		if WeaponFinish.is_open():
			def update_shader(resources):
				if len(resources) > 0:
					url = resources[0].identifier().url()
					sp.js.evaluate(f"""
						if (alg.shaders.instances()[0].url != "{url}")
							alg.shaders.updateShaderInstance(0, "{url}")
					""")
					callback(True, f'Finish Style was set to `{finish_style.upper()}`')
				else:
					callback(False, f'Failed to find shader for `{finish_style.upper()}` finish style')
				
			Resource.search_resource(update_shader, "your_assets", "shader", f'cs2_{finish_style.lower()}')

	@staticmethod
	def update_weapon(weapon: str):
		resources = {}
		if WeaponFinish.is_open():
			WeaponFinish.set("weapon", weapon)
			path = Path.asset("textures", "models", weapon)
			for param in ["uBaseColor", "uBaseRough", "uBaseSurface", "uBaseMasks", "uBaseCavity"]:
				tex_path = Path.join(path, f'{weapon}_{param[5:].lower()}.png')
				if Path.exists(tex_path):
					resources[param] = Resource.import_session_resource(tex_path, Resource.Usage.TEXTURE).identifier().url()
		return resources

	@staticmethod
	def import_econ():
		weapon_finish: dict = WeaponFinish.current()
		econitem_path = weapon_finish.get("econitem", "")
		if Path.exists(econitem_path):
			with open(econitem_path, "r", encoding="utf-8") as f:
				econitem_content = f.read()
		else:
			Log.error(f'Failed to import parameters from .econitem: Path {econitem_path} does not exists')

	@staticmethod
	def export_econ():
		weapon_finish: dict = WeaponFinish.current()
		# helper functions
		def uint8(value:float) -> int:
			return int(math.floor(max(0.0, min(1.0, value)) * 255 + 0.5))
		
		def get_bool(param: str) -> str:
			return "true" if weapon_finish.get(param) else "false"
		
		econitem = weapon_finish.get("econitem")
		if econitem is not None:
			textures_folder = weapon_finish.get("texturesFolder", "")
			
			if not Path.exists(textures_folder):
				Log.error(f'Failed to sync .econitem file: path "{textures_folder}" for textures does not exist')
				return
			
			# fetch textures folder
			textures_folder = textures_folder.split("csgo")[-1]
			if textures_folder[0] == "/":
				textures_folder = textures_folder[1:]

			# fetch weapon finish parameters
			finish_name = Path.filename(econitem)
			finish_style = {
				"so": "SolidColor",
				"hy": "HydroGraphic",
				"sp": "SprayPaint",
				"an": "Anodized",
				"am": "AnodizedMulticolor",
				"aa": "AnodizedAirbrushed",
				"cu": "CustomPaintJob",
				"aq": "Patina",
				"gs": "Gunsmith"
			}.get(weapon_finish.get("style", "gs"))

			wear = weapon_finish.get("wearRange", [0.0, 1.0])

			# packed values: [offsetX, offsetY, scale, rotation]
			tex_transform = weapon_finish.get("uTexTransform", [0.0, 0.0, 1.0, 0.0])
			# radians to degrees
			tex_transform[3] *= 180 / math.pi

			tex_offsetx = weapon_finish.get("texOffsetXRange", [-1.0, 1.0])
			tex_offsety = weapon_finish.get("texOffsetYRange", [-1.0, 1.0])
			tex_rotation = weapon_finish.get("texRotationRange", [-360.0, 360.0])

			# map colors
			colors = [
				list(map(uint8, weapon_finish.get(f'uCol{i}', [1.0, 1.0, 1.0])))
				for i in range(4)
			]

			try:
				with open(Path.asset("template.econitem"), "r", encoding="utf-8") as f:
					econitem_content = f.read().format(
						finish_name=finish_name,
						finish_style=finish_style,
						weapon=weapon_finish.get("weapon", "ak47"),
						wear=[wear[0], weapon_finish.get("uWearAmt", 0.5), wear[1]],
						tex_offsetx=[tex_offsetx[0], tex_transform[0], tex_offsetx[1]],
						tex_offsety=[tex_offsety[0], tex_transform[1], tex_offsety[1]],
						tex_scale=tex_transform[2],
						tex_rotation=[tex_rotation[0], tex_transform[3], tex_rotation[1]],
						ignore_weapon_size_scale=get_bool("uIgnoreWeaponSizeScale"),
						color0=colors[0],
						color1=colors[1],
						color2=colors[2],
						color3=colors[3],
						pearl_scale=weapon_finish.get("uPearlScale", 0.0),
						rough=weapon_finish.get("uPaintRoughness", 0.6),
						custom_pearl_mask=get_bool("uUsePearlMask"),
						custom_rough_tex=get_bool("uUseCustomRough"),
						custom_normal_map=get_bool("uUseCustomNormal"),
						custom_mat_masks=get_bool("uUseCustomMasks"),
						custom_ao_tex=get_bool("uUseCustomAOTex"),
						ao_tex_path=f'{textures_folder}/{finish_name}_ao.tga',
						normal_tex_path=f'{textures_folder}/{finish_name}_normal.tga',
						masks_tex_path=f'{textures_folder}/{finish_name}_masks.tga',
						rough_tex_path=f'{textures_folder}/{finish_name}_rough.tga',
						albedo_tex_path=f'{textures_folder}/{finish_name}_color.tga',
						pearl_tex_path=f'{textures_folder}/{finish_name}_pearl.tga',
					)
				with open(econitem, "w", encoding="utf-8") as f:
					f.write(econitem_content)
			except Exception as e:
				Log.error(f'Failed to sync .econitem file: {str(e)}')

	@staticmethod
	def export_textures():
		weapon_finish: dict = WeaponFinish.current()
		folder_path = weapon_finish.get("texturesFolder", "")

		if Path.exists(folder_path):
			# get finish name
			finish_name: str = weapon_finish.get("econitem", "")
			if finish_name is None:
				finish_name = weapon_finish.get("weapon", "untitled")
			else:
				finish_name = Path.filename(finish_name)
			
			export_preset = {
				"name" : "weapon_finish",
				"maps" : [
					# Albedo color
					{
						"fileName" : f'{finish_name}_color',
						"channels" : [
							{
								"destChannel" : "R",
								"srcChannel" : "R",
								"srcMapType" : "documentMap",
								"srcMapName" : "baseColor"
							},
							{
								"destChannel" : "G",
								"srcChannel" : "G",
								"srcMapType" : "documentMap",
								"srcMapName" : "baseColor"
							},
							{
								"destChannel" : "B",
								"srcChannel" : "B",
								"srcMapType" : "documentMap",
								"srcMapName" : "baseColor"
							},
							{
								"destChannel" : "A",
								"srcChannel" : "L",
								"srcMapType" : "documentMap",
								"srcMapName" : "user1"
							}
						]
					},
				]
			}
			
			# Masks
			if weapon_finish.get("style", "gs") != "cu" and weapon_finish.get("uUseCustomMasks"):
				export_preset["maps"].append({
					"fileName" : f'{finish_name}_masks',
					"channels" : [
						{
							"destChannel" : "R",
							"srcChannel" : "R",
							"srcMapType" : "documentMap",
							"srcMapName" : "user0"
						},
						{
							"destChannel" : "G",
							"srcChannel" : "G",
							"srcMapType" : "documentMap",
							"srcMapName" : "user0"
						},
						{
							"destChannel" : "B",
							"srcChannel" : "B",
							"srcMapType" : "documentMap",
							"srcMapName" : "user0"
						}
					]
				})

			# Normal
			if weapon_finish.get("uUseCustomNormal"):
				export_preset["maps"].append({
					"fileName" : f'{finish_name}_normal',
					"channels" : [
						{
							"destChannel" : "R",
							"srcChannel" : "R",
							"srcMapType" : "virtualMap",
							"srcMapName" : "Normal_OpenGL"
						},
						{
							"destChannel" : "G",
							"srcChannel" : "G",
							"srcMapType" : "virtualMap",
							"srcMapName" : "Normal_OpenGL"
						},
						{
							"destChannel" : "B",
							"srcChannel" : "B",
							"srcMapType" : "virtualMap",
							"srcMapName" : "Normal_OpenGL"
						}
					]
				})

			# AO
			if weapon_finish.get("uUseCustomAOTex"):
				export_preset["maps"].append({
					"fileName" : f'{finish_name}_ao',
					"channels" : [
						{
							"destChannel" : "L",
							"srcChannel" : "L",
							"srcMapType" : "virtualMap",
							"srcMapName" : "AO_Mixed"
						}
					]
				})

			# Roughness
			if weapon_finish.get("uUseCustomRough"):
				export_preset["maps"].append({
					"fileName" : f'{finish_name}_rough',
					"channels" : [
						{
							"destChannel" : "L",
							"srcChannel" : "L",
							"srcMapType" : "documentMap",
							"srcMapName" : "roughness"
						}
					]
				})

			# Pearlescence
			if weapon_finish.get("uUsePearlMask"):
				export_preset["maps"].append({
					"fileName" : f'{finish_name}_pearl',
					"channels" : [
						{
							"destChannel" : "L",
							"srcChannel" : "L",
							"srcMapType" : "documentMap",
							"srcMapName" : "user2"
						}
					]
				})

			export_config = {
				"exportPath": folder_path,
				"exportShaderParams": False,
				"exportPresets": [export_preset],
				"exportParameters" : [{
					"parameters" : {
						"fileFormat" : "tga",
						"bitDepth" : "8",
						"dithering" : True,
						"sizeLog2" : 12,
						"paddingAlgorithm" : "diffusion",
						"dilationDistance" : 16
					}
				}],
				"exportList" : [{
					"rootPath" : texture_set.name(),
					"exportPreset" : "weapon_finish"
				} for texture_set in sp.textureset.all_texture_sets()]
			}
			
			export_result = sp.export.export_project_textures(export_config)
			if export_result.status != sp.export.ExportStatus.Success:
				Log.error(export_result.message)

		else:
			Log.error(f'Failed to export textures: Path {folder_path} does not exists')
