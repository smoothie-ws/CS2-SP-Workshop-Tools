import substance_painter as sp

from .log import Log
from .path import Path
from .settings import Settings
from .project_settings import ProjectSettings
from .resource import search as resource_search


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

	ECON_TEMPLATE = """
	<!-- kv3 encoding:text:version{e21c7f3c-8a33-41c5-9977-a76d3a32aa0d} format:generic:version{7412167c-06e9-4698-aff2-e63eb59037e7} -->
	{
		cs2_item_type = "CCS2EconNode_PaintKit"
		CCS2EconNode_PaintKit = 
		{
			description_string = "#CSGO_Workshop_EmptyString"
			description_tag = "#CSGO_Workshop"
			rarity = "common"
			composite_material_class = "PaintKit_{finish_style}"
			composite_material_keys = 
			{
				econ_instance.g_flPatternTexCoordRotation = {tex_rotation}
				econ_instance.g_flWearAmount = {wear}
				econ_instance.g_vPatternTexCoordOffset.0 = {tex_offsetx}
				econ_instance.g_vPatternTexCoordOffset.1 = {tex_offsety}
				exposed_params.g_bIgnoreWeaponSizeScale = {ignore_weapon_size_scale}
				exposed_params.g_bOverrideAmbientOcclusion = {custom_ao_tex}
				exposed_params.g_bOverrideDefaultMasks = {custom_mat_masks}
				exposed_params.g_bUseNormalMap = {custom_normal_map}
				exposed_params.g_bUsePearlescenceMask = {custom_normal_map}
				exposed_params.g_bUseRoughness = {custom_normal_map}
				exposed_params.g_flPatternTexCoordScale = {tex_scale}
				exposed_params.g_flPearlescentScale = {pearl_scale}
				exposed_params.g_tPaintRoughness = "{rough_tex_path}"
				exposed_params.g_tPattern = "{albedo_tex_path}"
				exposed_params.g_vColor0 = {color0}
				exposed_params.g_vColor1 = {color1}
				exposed_params.g_vColor2 = {color2}
				exposed_params.g_vColor3 = {color3}
			}
			all_composite_material_keys = 
			{
				econ_instance.g_flPatternTexCoordRotation = {tex_rotation}
				econ_instance.g_flWearAmount = {wear}
				econ_instance.g_vPatternTexCoordOffset.0 = {tex_offsetx}
				econ_instance.g_vPatternTexCoordOffset.1 = {tex_offsety}
				exposed_params.g_bIgnoreWeaponSizeScale = {ignore_weapon_size_scale}
				exposed_params.g_bOverrideAmbientOcclusion = {custom_ao_tex}
				exposed_params.g_bOverrideDefaultMasks = {custom_mat_masks}
				exposed_params.g_bUseNormalMap = {custom_normal_map}
				exposed_params.g_bUsePearlescenceMask = {custom_normal_map}
				exposed_params.g_bUseRoughness = {custom_normal_map}
				exposed_params.g_bUseRoughnessByColor = false
				exposed_params.g_flPaintRoughness = {rough}
				exposed_params.g_flPatternTexCoordScale = 1.0
				exposed_params.g_flPearlescentScale = {pearl_scale}
				exposed_params.g_tFinalAmbientOcclusion = "{ao_tex_path}"
				exposed_params.g_tNormal = "{normal_tex_path}"
				exposed_params.g_tPaintByNumberMasks = "{masks_tex_path}"
				exposed_params.g_tPaintRoughness = "{rough_tex_path}"
				exposed_params.g_tPattern = "{albedo_tex_path}"
				exposed_params.g_tPearlescenceMask = "{pearl_tex_path}"
				exposed_params.g_vColor0 = {color0}
				exposed_params.g_vColor1 = {color1}
				exposed_params.g_vColor2 = {color2}
				exposed_params.g_vColor3 = {color3}
				exposed_params.g_vPaintMetalness.0 = 0.0
				exposed_params.g_vPaintMetalness.1 = 0.0
				exposed_params.g_vPaintMetalness.2 = 0.0
				exposed_params.g_vPaintMetalness.3 = 0.0
				exposed_params.g_vPaintRoughness.0 = 0.6
				exposed_params.g_vPaintRoughness.1 = 0.6
				exposed_params.g_vPaintRoughness.2 = 0.6
				exposed_params.g_vPaintRoughness.3 = 0.6
			}
			preview_weapon = "weapon_{weapon}"
			associate_assets = 
			[
				resource_name:"weapons/paints/workshop/{name}.vcompmat",
			]
		}
	}
	"""

	@staticmethod
	def create(file_path:str, name:str, weapon:str, finish_style:int, callback):
		# create project
		export_path = None
		cs2_path = Settings.get("cs2_path")
		if cs2_path is not None:
			export_path = Path.join(cs2_path, "content", "csgo", "workshop", "paintkits", name)
		if sp.project.is_open():
			if sp.project.needs_saving():
				try:
					sp.project.save()
				except sp.exception.ProjectError:
					pass
			sp.project.close()
		try:
			sp.project.create(
				mesh_file_path=file_path, 
				settings=sp.project.Settings(
					import_cameras=False,
					normal_map_format=sp.project.NormalMapFormat.OpenGL,
					tangent_space_mode=sp.project.TangentSpace.PerVertex,
					export_path=export_path
				)
			)
			sp.project.execute_when_not_busy(lambda: WeaponFinish.set_up(name, weapon, finish_style, callback))
		except sp.exception.ProjectError as e:
			callback(False, f'Failed to create Weapon finish: {str(e)}')

	@staticmethod
	def format(
		name:str,
		weapon:str,
		finish_style:str,
		tex_scale:float,
		ignore_weapon_size_scale:bool,
		tex_rotation:list,
		tex_offsetx:list,
		tex_offsety:list,
		color0:list,
		color1:list,
		color2:list,
		color3:list,
		wear:list,
		custom_pearl_mask:bool,
		pearl_scale:float,
		custom_rough_tex:bool,
		rough:float,
		custom_normal_map:bool,
		custom_mat_mask:bool,
		custom_ao_tex:bool
		):
		return WeaponFinish.ECON_TEMPLATE.format(
			name=name,
			weapon=weapon,
			finish_style=finish_style,
			tex_scale=tex_scale,
			ignore_weapon_size_scale=ignore_weapon_size_scale,
			tex_rotation=tex_rotation,
			tex_offsetx=tex_offsetx,
			tex_offsety=tex_offsety,
			color0=color0,
			color1=color1,
			color2=color2,
			color3=color3,
			wear=wear,
			custom_pearl_mask=custom_pearl_mask,
			pearl_scale=pearl_scale,
			custom_rough_tex=custom_rough_tex,
			rough=rough,
			custom_normal_map=custom_normal_map,
			custom_mat_mask=custom_mat_mask,
			custom_ao_tex=custom_ao_tex
		)

	@staticmethod
	def set_up(name:str, weapon:str, finish_style:int, callback):
		def _set_up(callback):
			try:
				# update channel stacks
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

				# update project settings
				ProjectSettings.set("weapon_finish", {
					"name": name,
					"weapon": weapon,
					"finishStyle": finish_style
				})

				WeaponFinish.change_finish_style(finish_style, 
					lambda res, msg: callback(res, 
						f'The project was set up as Weapon Finish' if res else f'Failed to set up Weapon Finish: {msg}'
					)
				)
			except Exception as e:
				callback(False, f'Failed to set up weapon finish: {str(e)}')

		if sp.resource.Shelf("your_assets").is_crawling():
			sp.event.DISPATCHER.strong_connect(sp.event.ShelfCrawlingEnded, lambda _: _set_up(callback))
		else:
			_set_up(callback)

	@staticmethod
	def save(parameters):
		ProjectSettings.set("weapon_finish", parameters)

	@staticmethod
	def change_finish_style(finish_style: int, callback):
		fs = WeaponFinish.FINISH_STYLES[finish_style]
		# update shader instance
		def update_shader(resources):
			if len(resources) > 0:
				sp.js.evaluate(f'alg.shaders.updateShaderInstance(0, "{resources[0].identifier().url()}")')
				callback(True, f'Finish Style was changed to `{fs.upper()}`')
			else:
				callback(False, f'Failed to find shader for `{fs.upper()}` finish style')
			
		resource_search(update_shader, "your_assets", "shader", f'cs2_{fs}')
		