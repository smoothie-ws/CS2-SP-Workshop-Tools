class WeaponFinish:
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
        return ECON_TEMPLATE.format(
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