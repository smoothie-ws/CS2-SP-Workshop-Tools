"""Built-in weapon identifiers, display names and UV scales."""
import json
from types import MappingProxyType


WEAPONS = MappingProxyType({
    'ak47': ('AK-47', 0.549),
    'aug': ('AUG', 0.763),
    'awp': ('AWP', 1.029),
    'bizon': ('PP-Bizon', 0.596),
    'cz75a': ('CZ75-Auto', 0.4),
    'deagle': ('Desert Eagle', 0.3),
    'elite': ('Dual Berettas', 0.282),
    'famas': ('FAMAS', 0.66),
    'fiveseven': ('Five-SeveN', 0.264),
    'glock18': ('Glock-18', 0.446),
    'g3sg1': ('G3SG1', 0.703),
    'galilar': ('Galil AR', 0.75),
    'mac10': ('MAC-10', 0.495),
    'm249': ('M249', 1.151),
    'm4a1_silencer': ('M4A1-S', 0.9167),
    'm4a4': ('M4A4', 0.425),
    'mag7': ('MAG-7', 0.612),
    'mp5sd': ('MP5-SD', 0.446),
    'mp7': ('MP7', 0.446),
    'mp9': ('MP9', 0.485),
    'negev': ('Negev', 0.74),
    'nova': ('Nova', 0.744),
    'hkp2000': ('P2000', 0.288),
    'p250': ('P250', 0.371),
    'p90': ('P90', 0.537),
    'revolver': ('R8 Revolver', 0.5),
    'sawedoff': ('Sawed-Off', 0.445),
    'scar20': ('SCAR-20', 0.84),
    'sg556': ('SG 553', 0.809),
    'ssg08': ('SSG 08', 1.084),
    'tec9': ('Tec-9', 0.427),
    'ump45': ('UMP-45', 0.882),
    'usp_silencer': ('USP-S', 0.516),
    'xm1014': ('XM1014', 0.54),
    'taser': ('Zeus x27', 0.36),
})

WEAPONS_JSON = json.dumps({
    key: {"name": name, "uv_scale": scale}
    for key, (name, scale) in WEAPONS.items()
})
