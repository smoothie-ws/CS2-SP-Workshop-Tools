import json
import math
import substance_painter as sp

from .painter import Log, Path, Macro, Plugin, Resource, ProjectSettings

class WeaponFinish:
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
				textures_folder = Path.join(cs2_path, "content", "csgo_addons", "workshop_items", "weapons", "paints", "workshop", finish_name)
				if not Path.exists(textures_folder):
					Path.makedirs(textures_folder)
					weapon_finish["texturesFolder"] = textures_folder
				else:
					Log.info(f'Be careful: path "{textures_folder}" for textures already exists!')

				# create .econitem file
				econitem = Path.join(cs2_path, 
					"content", "csgo_addons", "workshop_items", "items", "assets", "paintkits", "workshop", 
					f'{finish_name}.econitem'
				)
				if not Path.exists(econitem):
					weapon_finish["econitem"] = econitem
				else:
					Log.warning(f'Failed to create .econitem file: path "{econitem}" already exists')

			else:
				Log.warning("CS2 path not found. Please set it in the plugin settings menu")

			WeaponFinish.dump(weapon_finish)
			WeaponFinish.export_econ()
   
			# update shader instance
			WeaponFinish.update_style(finish_style, False,
				lambda res, msg: callback(res,
					f'The project was successfully set up as Weapon Finish ({finish_style.upper()})' 
     				if res else 
         			f'Failed to set finish style: {msg}'
				)
			)

		if sp.resource.Shelf("session").is_crawling():
			delayed = True
			sp.event.DISPATCHER.connect_strong(sp.event.ShelfCrawlingEnded, proceed)
		else:
			proceed(None)

	@staticmethod
	def update_style(fs: str, extern_mode: bool, callback):
		if WeaponFinish.is_open():
			# shader files
			shader_path = Path.asset("shader", "cs2.glsl")
			shader_source = Path.read(shader_path)
   
			if len(shader_source) > 0:
				shader_dir = Path.cleardir(Path.join(Path.plugin, "shaders"))
	
				name = f'cs2_{fs}'
				path = Path.join(shader_dir, f'{name}.glsl')
				Path.write(path, Macro.process(shader_source, {
        			# "PAINT_STYLE": list(Plugin.settings.get("finish_styles", {}).keys()).index(fs),
					"PAINT_STYLE": 8,
					"EXTERN_MODE": extern_mode
           		}, path=shader_path))
				
				shader_resource = Resource.import_session_resource(path, Resource.Usage.SHADER, name, "CS2")
				sp.js.evaluate(f'alg.shaders.updateShaderInstance(0, "{shader_resource.identifier().url()}")')
				
				# icon
				icon_path = Path.asset("icons", f'{name}.png')
				if Path.exists(icon_path):
					shader_resource.set_custom_preview(icon_path)
    
				callback(True, f'Finish Style was set to `{fs.upper()}`')
			else:
				callback(False, f'Failed to find shader for `{fs.upper()}` finish style')
    
	@staticmethod
	def update_weapon(weapon: str):
		params = {
			"g_tColor": "color", 
			"g_tMetalness": "rough", 
			"g_tSurface": "normal", 
			"g_tMasks": "masks", 
			"g_tAmbientOcclusion": "cavity"
		}
		resources = {}
		if WeaponFinish.is_open():
			WeaponFinish.set("weapon", weapon)
			path = Path.asset("textures", "models", weapon)
			for param in params.keys():
				tex_path = Path.join(path, f'{weapon}_{params[param]}.png')
				if Path.exists(tex_path):
					resources[param] = Resource.import_session_resource(tex_path, Resource.Usage.TEXTURE, group="CS2").identifier().url()
		return resources

	@staticmethod
	def import_econ():
		weapon_finish: dict = WeaponFinish.current()
		tex_transform = weapon_finish.get("uTexTransform", [1.0, 0.0, 0.0, 0.0])
  
		def set_weapon(_: str, value):
			parts = value.split("_")
			if len(parts) == 2:
				weapon_finish["weapon"] = parts[1]
			else:
				Log.warning("Failed to fetch weapon")
   
		def set_style(_: str, value):
			parts = value.split("_")
			if len(parts) == 2:
				weapon_finish["style"] = {
					name.replace(" ", "").replace("-", ""): code
					for code, name in Plugin.settings.get("finish_styles", {}).items()
				}.get(parts[1], "gs")
			else:
				Log.warning("Failed to fetch style")
   
		def set_wear(_: str, value):
			if len(value) == 3:
				weapon_finish["wearRange"] = [value[0], value[2]]
				weapon_finish["g_flWearAmount"] = value[1]
			else:
				Log.warning("Failed to fetch wear")
   
		def set_tex_scale(_: str, value):
			tex_transform[0] = value
		
		def set_tex_offset(param: str, value):
			if len(value) == 3:
				weapon_finish[f'texOffset{param}Range'] = [value[0], value[2]]
				tex_transform[1 if param == "X" else 2] = value[1]
			else:
				Log.warning(f'Failed to fetch texture {param} offset')
		
		def set_tex_rotation(_: str, value):
			if len(value) == 3:
				weapon_finish["texRotationRange"] = [value[0], value[2]]
				tex_transform[3] = value[0]
			else:
				Log.warning("Failed to fetch texture rotation")
		
		def set_col(param: str, value):
			if len(value) == 3:
				weapon_finish[f'g_vColor{param}'] = [v / 255 for v in value]
			else:
				Log.warning(f'Failed to fetch color {param}')

		params = {
			"preview_weapon": ("", set_weapon),
			"composite_material_class": ("", set_style),
			"g_flWearAmount": ("", set_wear),
			"g_vPatternTexCoordOffset.0": ("X", set_tex_offset),
			"g_vPatternTexCoordOffset.1": ("Y", set_tex_offset),
			"g_flPatternTexCoordScale": ("", set_tex_scale),
			"g_flPatternTexCoordRotation": ("", set_tex_rotation),
			"g_bIgnoreWeaponSizeScale": "g_bIgnoreWeaponSizeScale",
			"g_bOverrideAmbientOcclusion": "g_bOverrideAmbientOcclusion",
			"g_bOverrideDefaultMasks": "g_bOverrideDefaultMasks",
			"g_bUseNormalMap": "g_bUseNormalMap",
			"g_bUsePearlescenceMask": "g_bUsePearlescenceMask",
			"g_bUseRoughness": "g_bUseRoughness",
			"g_flPearlescentScale": "g_flPearlescentScale",
			"g_tPaintRoughness": "g_flPaintRoughness",
			"g_vColor0": (0, set_col),
			"g_vColor1": (1, set_col),
			"g_vColor2": (2, set_col),
			"g_vColor3": (3, set_col),
		}
  
		econitem_content = Path.read(weapon_finish.get("econitem", ""))
		if (len(econitem_content) > 0):
			for l in econitem_content.splitlines():
				for p in params.keys():
					if p in l:
						param = params.pop(p)
						value = json.loads(l.split("=")[1].strip())
						if isinstance(param, tuple):
							param[1](param[0], value)
						else:
							weapon_finish[param[0]] = value
						break
  
			weapon_finish["uTexTransform"] = tex_transform
			WeaponFinish.dump(weapon_finish)
			Log.warning(f'Imported parameters from .econitem')

	@staticmethod
	def export_econ():
		weapon_finish: dict = WeaponFinish.current()
		# helper functions
		def uint8(value:float) -> int:
			return int(math.floor(max(0.0, min(1.0, value)) * 255 + 0.5))
		
		def get_bool(param: str) -> str:
			return "true" if weapon_finish.get(param) else "false"
		
		econitem: str = weapon_finish.get("econitem", "")
		if econitem != "":
			style = weapon_finish.get("style", "gs")

			# fetch weapon finish parameters
			finish_name = Path.filename(econitem)
			finish_style = Plugin.settings.get("finish_styles", {}).get(style, "Gunsmith")
			finish_style = finish_style.replace(" ", "").replace("-", "")

			wear = weapon_finish.get("wearRange", [0.0, 1.0])

			# packed values: [offsetX, offsetY, scale, rotation]
			tex_transform = weapon_finish.get("uTexTransform", [1.0, 0.0, 0.0, 0.0])
			tex_offsetx = weapon_finish.get("texOffsetXRange", [-1.0, 1.0])
			tex_offsety = weapon_finish.get("texOffsetYRange", [-1.0, 1.0])
			tex_rotation = weapon_finish.get("texRotationRange", [-360.0, 360.0])

			# map colors
			colors = [
				list(map(uint8, weapon_finish.get(f'g_vColor{i}', [1.0, 1.0, 1.0])))
				for i in range(4)
			]

			# fetch textures folder
			textures_folder = weapon_finish.get("texturesFolder", "")
			if not Path.exists(textures_folder):
				Log.info(f'Be careful: path "{textures_folder}" for textures does not exist!')
			textures_folder = textures_folder.split("workshop_items")[-1]
			if len(textures_folder) > 0 and textures_folder[0] == "/":
				textures_folder = textures_folder[1:]

			econitem_content = Path.read(Path.asset("template.econitem")).format(
				finish_name=finish_name,
				finish_style=finish_style,
				weapon=weapon_finish.get("weapon", "ak47"),
				wear=[wear[0], weapon_finish.get("g_flWearAmount", 0.5), wear[1]],
				tex_scale=tex_transform[0],
				tex_offsetx=[tex_offsetx[0], tex_transform[1], tex_offsetx[1]],
				tex_offsety=[tex_offsety[0], tex_transform[2], tex_offsety[1]],
				tex_rotation=[tex_rotation[0], tex_transform[3], tex_rotation[1]],
				ignore_weapon_size_scale=get_bool("g_bIgnoreWeaponSizeScale"),
				color0=colors[0],
				color1=colors[1],
				color2=colors[2],
				color3=colors[3],
				pearl_scale=weapon_finish.get("g_flPearlescentScale", 0.0),
				rough=weapon_finish.get("g_flPaintRoughness", 0.6),
				custom_pearl_mask=get_bool("g_bUsePearlescenceMask"),
				custom_rough_tex=get_bool("g_bUseRoughness"),
				custom_normal_map=get_bool("g_bUseNormalMap"),
				custom_mat_masks=get_bool("g_bOverrideDefaultMasks"),
				custom_ao_tex=get_bool("g_bOverrideAmbientOcclusion"),
				ao_tex_path=f'{textures_folder}/{finish_name}_ao.tga',
				normal_tex_path=f'{textures_folder}/{finish_name}_normal.tga',
				masks_tex_path=f'{textures_folder}/{finish_name}_masks.tga',
				rough_tex_path=f'{textures_folder}/{finish_name}_rough.tga',
				albedo_tex_path=f'{textures_folder}/{finish_name}_color.tga',
				pearl_tex_path=f'{textures_folder}/{finish_name}_pearl.tga',
			)
			if not Path.write(econitem, econitem_content) > 0:
				Log.error("Failed to export .econitem file")

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
			if weapon_finish.get("style", "gs") != "cu" and weapon_finish.get("g_bOverrideDefaultMasks"):
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
			if weapon_finish.get("g_bUseNormalMap"):
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
			if weapon_finish.get("g_bOverrideAmbientOcclusion"):
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
			if weapon_finish.get("g_bUseRoughness"):
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
			if weapon_finish.get("g_bUsePearlescenceMask"):
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
