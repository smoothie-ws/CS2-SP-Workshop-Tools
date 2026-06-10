from .painter.shader_params import *


class TransformMatrixRow(ShaderParam):
    def __init__(
            self,
            is_first_row:bool, 
            scale_expr: str,
            rotation_expr: str,
            translationX_expr: str,
            translationY_expr: str,
            condition:bool = True, 
            is_uniform:bool = True
        ):
        expr = f'''
            const s = Math.floor(({scale_expr} + 0.005) * 100) / 100;
            const r = (Math.floor(({rotation_expr} + 0.005) * 100) / 100 * 3.1415927) / 180;
            const tx = Math.floor(({translationX_expr} + 0.005) * 100) / 100;
            const ty = Math.floor(({translationY_expr} + 0.005) * 100) / 100;

            const cos = Math.cos(r);
            const sin = Math.sin(r);

            const m = 0.5 / (s != 0.0 ? s : 1.0);
            const m0 = m  *  cos - m * -sin;
            const m1 = m0 * -sin + m *  cos;

            return {
                "[cos * s, -sin * s, 0.0, s * cos * m0 + s * -sin * m1 + tx - 0.5]"
                if is_first_row else
                "[sin * s,  cos * s, 0.0, s * sin * m0 + s *  cos * m1 + ty - 0.5]"
            };
        '''
        super().__init__("vec4", [1.0, 0.0, 0.0, 0.0] if is_first_row else [0.0, 1.0, 0.0, 0.0], condition, is_uniform, expr)


def get_params(PS: str, EX: bool):
    return ShaderParams.build({
        "Common": ShaderParamsGroup({
            "g_tPattern": Texture(
                name="Pattern Mask" if PS in ["hy", "sp", "am", "aa"] else "Albedo Texture",
                condition=PS not in ["so", "an"] and EX
            ),
            "g_flPatternTexCoordScale": Slider(
                name="Texture Scale", 
                default=1.0, 
                min=-10.0, 
                max=10.0,
                is_uniform=False
            ),
            "g_bIgnoreWeaponSizeScale": Checkbox(
                name="Ignore Weapon Size Scale",
                default=False,
                description="For some finishes, the automatic scale adjustment per-weapon is not desired",
                condition=PS not in ["aq", "gs"]
            ),
            "g_flWearAmount": Slider(
                name="Wear Amount", 
                default=0.0
            ),
            "g_vPatternTexCoordXform0": TransformMatrixRow(
                is_first_row=True,
                scale_expr="g_flPatternTexCoordScale * (g_bIgnoreWeaponSizeScale || g_flUvScale1)",
                rotation_expr="g_flPatternTexCoordRotation",
                translationX_expr="g_vPatternTexCoordOffset.x",
                translationY_expr="g_vPatternTexCoordOffset.y"
            ),
            "g_vPatternTexCoordXform1": TransformMatrixRow(
                is_first_row=False,
                scale_expr="g_flPatternTexCoordScale * (g_bIgnoreWeaponSizeScale || g_flUvScale1)",
                rotation_expr="g_flPatternTexCoordRotation",
                translationX_expr="g_vPatternTexCoordOffset.x",
                translationY_expr="g_vPatternTexCoordOffset.y"
            ),
            "g_vWearTexCoordXform0": TransformMatrixRow(
                is_first_row=True,
                scale_expr="g_flWearTexCoordScale * (g_bIgnoreWeaponSizeScale || g_flUvScale1)",
                rotation_expr="g_flWearTexCoordRotation",
                translationX_expr="g_vWearTexCoordOffset.x",
                translationY_expr="g_vWearTexCoordOffset.y"
            ),
            "g_vWearTexCoordXform1": TransformMatrixRow(
                is_first_row=False,
                scale_expr="g_flWearTexCoordScale * (g_bIgnoreWeaponSizeScale || g_flUvScale1)",
                rotation_expr="g_flWearTexCoordRotation",
                translationX_expr="g_vWearTexCoordOffset.x",
                translationY_expr="g_vWearTexCoordOffset.y"
            ),
            "g_vGrungeTexCoordXform0": TransformMatrixRow(
                is_first_row=True,
                scale_expr="g_flGrungeTexCoordScale * (g_bIgnoreWeaponSizeScale || g_flUvScale1)",
                rotation_expr="g_flGrungeTexCoordRotation",
                translationX_expr="g_vGrungeTexCoordOffset.x",
                translationY_expr="g_vGrungeTexCoordOffset.y"
            ),
            "g_vGrungeTexCoordXform1": TransformMatrixRow(
                is_first_row=False,
                scale_expr="g_flGrungeTexCoordScale * (g_bIgnoreWeaponSizeScale || g_flUvScale1)",
                rotation_expr="g_flGrungeTexCoordRotation",
                translationX_expr="g_vGrungeTexCoordOffset.x",
                translationY_expr="g_vGrungeTexCoordOffset.y"
            )
        }),
        "Colors": ShaderParamsGroup({
            "g_bOverrideDefaultMasks": Checkbox(
                name="Use Paint-By-Number Mask",
                condition=PS not in ["aq", "gs"]
            ),
            "g_tPaintMasks": Texture(
                name="Paint-By-Number Mask",
                condition=PS not in ["aq", "gs"] and EX
            ),
            "g_vColor0": Color(
                name="Base Metal" if PS in ["aq", "gs"] else "Base Coat",
                default=[0.50, 0.50, 0.50],
                description="The metal before patina, revealed through scratches"
                if PS in ["aq", "gs"]
                else "Color that covers all paintable areas of the weapon"
            ),
            "g_vColor1": Color(
                name="Patina Tint" if PS in ["aq", "gs"] else "Red Mask",
                default=[0.59, 0.59, 0.59],
                description="Tint of the newly applied patina" if PS in ["aq", "gs"] else "Color to store in the Red Channel of the Texture",
                condition=PS != "an"
            ),
            "g_vColor2": Color(
                name="Patina Wear" if PS in ["aq", "gs"] else "Green Mask",
                default=[0.38, 0.38, 0.38],
                description="Tint of the aged patina" if PS in ["aq", "gs"] else "Color to store in the Green Channel of the Texture",
                condition=PS != "an"
            ),
            "g_vColor3": Color(
                name="Grime" if PS in ["aq", "gs"] else "Blue Mask",
                default=[0.42, 0.42, 0.42],
                description="Color of the grime, oil accretion, or oxide that accumulates in cavities"
                if PS in ["aq", "gs"]
                else "Color to store in the Blue Channel of the Texture",
                condition=PS != "an"
            )
        }, PS not in ["cu", "ce"]),
        "Texture Placement": ShaderParamsGroup({
            "g_vSprayBiasBlend": MultiSlider(
                name="Spray Blend",
                model=["Back", "Top"],
                condition=PS == "sp"
            ),
            "g_flPatternTexCoordRotation": RangeSlider(
                name="Texture Rotation",
                min=-360.0,
                max=360.0,
                is_uniform=False
            ),
            "g_vPatternTexCoordOffset": MultiSlider(
                name="Texture Offset",
                model=["X", "Y"],
                min=-1.0,
                max=1.0,
                is_uniform=False
            )
        }),
        "Materials": ShaderParamsGroup({
            "g_bUseRoughness": Checkbox(
                name="Use Roughness Map",
                visible="!g_bRoughnessPerColor",
                condition=PS in ["so", "hy", "sp"]
            ),
            "g_bUseRoughness": Checkbox(
                name="Use Roughness Map",
                condition=PS not in ["so", "hy", "sp"]
            ),
            "g_tPaintRoughness": Texture(
                name="Roughness Map",
                visible="g_bUseRoughness"
            ),
            "g_bUseMetalness": Checkbox(
                name="Use Metalness Map",
                condition=PS == "ce"
            ),
            "g_tPaintMetalness": Texture(
                name="Metalness Map",
                visible="g_bUseMetalness",
                condition=PS == "ce"
            ),
            "g_bRoughnessPerColor": Checkbox(
                name="Use Roughness By Color",
                visible="!g_bUseRoughness",
                condition=PS in ["so", "hy", "sp"]
            ),
            "g_vPaintRoughness": MultiSlider(
                name="Paint Roughness",
                model=["Base Coat", "Red Mask", "Green Mask", "Blue Mask"],
                visible="g_bRoughnessPerColor",
                condition=PS in ["so", "hy", "sp"]
            ),
            "g_flPaintRoughness": Slider(
                name="Paint Roughness",
                default=0.6,
                visible="!g_bRoughnessPerColor && !g_bUseRoughness",
                condition=PS in ["so", "hy", "sp"]
            ),
            "g_flPaintRoughness": Slider(
                name="Paint Roughness",
                default=0.6,
                visible="!g_bUseRoughness",
                condition=PS not in ["so", "hy", "sp"]
            ),
            "g_bOverrideDefaultMasks": Checkbox(
                name="Use Material Mask",
                condition=PS in ["aq", "gs"]
            ),
            "g_tPaintMasks": Texture(
                name="Metalness Map",
                visible="g_bOverrideDefaultMasks",
                condition=PS in ["aq", "gs"]
            )
        }),
        "Overlay": ShaderParamsGroup({
            "g_bEnableOverlay": Checkbox(
                name="Enable Overlay"
            ),
            "g_tOverlay": Texture(
                name="Overlay Texture", 
                visible="g_bEnableOverlay"
            ),
            "g_bRandomizeOverlayUVs": Checkbox(
                name="Randomize Overlay UVs", 
                visible="g_bEnableOverlay"
            ),
            "nOverlayBlendMode": Combobox(
                name="Overlay Blend Mode",
                default=0,
                visible="g_bEnableOverlay",
                model=["Add", "Color", "Layer", "Multiply", "Translucent"]
            ),
            "g_fOverlayBrightness": Slider(
                name="Brightness", 
                default=1.0, 
                visible="g_bEnableOverlay"
            ),
            "g_fOverlayStrength": Slider(
                name="Albedo Strength", 
                default=1.0, 
                visible="g_bEnableOverlay"
            ),
            "g_fOverlayDurability": Slider(
                name="Durability", 
                default=0.0, 
                visible="g_bEnableOverlay"
            ),
            "g_fOverlayMaterialStrength": Slider(
                name="Material Effect Strength",
                default=0.0,
                visible="g_bEnableOverlay"
            ),
            "g_fOverlayMetalness": Slider(
                name="Metalness", 
                default=0.0, 
                visible="g_bEnableOverlay"
            ),
            "g_fOverlayRoughness": Slider(
                name="Roughness", 
                default=0.0, 
                visible="g_bEnableOverlay"
            ),
            "g_fOverlayPearlescentMask": Slider(
                name="SFX", 
                default=0.0, 
                visible="g_bEnableOverlay"
            )
        }, condition=PS == "ce"),
        "Normals": ShaderParamsGroup({
            "g_bUseNormalMap": Checkbox(
                name="Use Normal Map"
            ),
            "g_tPaintNormal": Texture(
                name="Normal Map", 
                visible="g_bUseNormalMap"
            ),
            "g_bOverrideAmbientOcclusion": Checkbox(
                name="Use Ambient Occlusion"
            ),
            "g_tPaintAO": Texture(
                name="Ambient Occlusion", 
                visible="g_bOverrideAmbientOcclusion"
            )
        }),
        "Effects": ShaderParamsGroup({
            "g_bUseSFXMask": Checkbox(
                name="Use SFX Mask",
                condition=PS == "ce"
            ),
            "g_tSFXMask": Texture(
                name="SFX Mask",
                visible="g_bUseSFXMask",
                condition=PS == "ce"
            ),
            "g_bUsePearlescenceMask": Checkbox(
                name="Use Pearlescence Mask"
            ),
            "g_tPearlescenceMask": Texture(
                name="Pearlescence Mask",
                visible="g_bUsePearlescenceMask"
            ),
            "g_flPearlescentScale": Slider(
                name="Pearlescent Scale",
                min=-6.0,
                max=6.0
            ),
            "g_vGlitter": MultiSlider(
                name="Glitter",
                model=["Intensity", "Scale", "Rainbow Balance", "Rainbow Spread"],
                condition=PS == "ce"
            ),
            "g_vIridescence": MultiSlider(
                name="Iridescent",
                model=["Strength", "Scale", "Hue Shift"],
                condition=PS == "ce"
            )
        }),
        "Wear and Grunge": ShaderParamsGroup({
            "g_vPaintDurability": MultiSlider(
                name="Paint Durability",
                model=["Base Coat", "Red Mask", "Green Mask", "Blue Mask"],
                condition=PS in ["so", "hy", "sp"]
            ),
            "WearRange": RangeSlider(
                name="Wear Range", 
                is_uniform=False
            ),
            "g_tWear": Texture(
                name="Wear Texture", 
                condition=PS == "ce"
            ),
            "g_fWearSoftness": Slider(
                name="Wear Softness", 
                min=-6.0, 
                max=6.0
            ),
            "g_flWearTexCoordRotation": RangeSlider(
                name="Wear Rotation",
                min=-360.0,
                max=360.0,
                is_uniform=False
            ),
            "g_tGrunge": Texture(
                name="Grunge Texture", 
                condition=PS == "ce"
            )
        })
    })
