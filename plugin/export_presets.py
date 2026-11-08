"""Painter export configuration, independent of application services."""


def _channels(source, components, map_type="documentMap"):
    return [{"destChannel": component, "srcChannel": component,
             "srcMapType": map_type, "srcMapName": source}
            for component in components]


def weapon_finish_preset(finish, name):
    color = _channels("baseColor", "RGB")
    color.append(dict(destChannel="A", srcChannel="L", srcMapType="documentMap", srcMapName="user1"))
    maps = [{"fileName": f"{name}_color", "channels": color}]
    options = (
        ("masks", "g_bOverrideDefaultMasks", "user0", "RGB", "documentMap"),
        ("normal", "g_bUseNormalMap", "Normal_OpenGL", "RGB", "virtualMap"),
        ("ao", "g_bOverrideAmbientOcclusion", "AO_Mixed", "L", "virtualMap"),
        ("rough", "g_bUseRoughness", "roughness", "L", "documentMap"),
        ("pearl", "g_bUsePearlescenceMask", "user2", "L", "documentMap"),
    )
    for suffix, enabled, source, components, map_type in options:
        if not finish.get(enabled) or (suffix == "masks" and finish.get("style", "gs") == "cu"):
            continue
        maps.append({"fileName": f"{name}_{suffix}", "channels": _channels(source, components, map_type)})
    return {"name": "weapon_finish", "maps": maps}
