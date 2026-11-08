"""Typed conversion of the supported KV3 assignments, independent of Painter."""
import copy
import json
import math
import re


STYLE_CODES = ("so", "hy", "sp", "an", "am", "aa", "cu", "aq", "gs")
BOOL_KEYS = (
    "g_bIgnoreWeaponSizeScale", "g_bOverrideAmbientOcclusion",
    "g_bOverrideDefaultMasks", "g_bUseNormalMap", "g_bUsePearlescenceMask",
    "g_bUseRoughness",
)
NUMBER_KEYS = ("g_flPearlescentScale", "g_flPaintRoughness", "g_flPatternTexCoordScale")
RANGE_KEYS = ("g_flWearAmount", "g_vPatternTexCoordOffset.0",
              "g_vPatternTexCoordOffset.1", "g_flPatternTexCoordRotation")
COLOR_KEYS = tuple(f"g_vColor{i}" for i in range(4))
KEYS = set(BOOL_KEYS + NUMBER_KEYS + RANGE_KEYS + COLOR_KEYS +
           ("preview_weapon", "composite_material_class"))
ASSIGNMENT = re.compile(r'^\s*(?:(?:econ_instance|exposed_params)\.)?([\w.]+)\s*=\s*(.*)$')


def number(value):
    if type(value) not in (int, float) or not math.isfinite(value):
        raise ValueError("expected a finite number")
    return value


def vector(value):
    if not isinstance(value, list) or len(value) != 3:
        raise ValueError("expected three numeric components")
    return [number(component) for component in value]


def import_parameters(content, current, styles):
    """Apply validated first assignments; reject malformed known fields atomically.

    The exported KV3 repeats fields in all_composite_material_keys. The first
    occurrence (the editable composite_material_keys section) takes precedence.
    """
    result = copy.deepcopy(current)
    transform = list(result.get("uTexTransform", [1.0, 0.0, 0.0, 0.0]))
    if len(transform) != 4:
        raise ValueError("invalid stored texture transform")
    seen = set()
    decoder = json.JSONDecoder()
    for line_number, line in enumerate(content.splitlines(), 1):
        match = ASSIGNMENT.match(line)
        if not match:
            continue
        key, raw = match.groups()
        if key not in KEYS or key in seen:
            continue
        try:
            value, end = decoder.raw_decode(raw)
            tail = raw[end:].strip().lstrip(",").strip()
            if tail and not tail.startswith("//"):
                raise ValueError("unexpected content after value")
            if key in BOOL_KEYS:
                if type(value) is not bool:
                    raise ValueError("expected true or false")
                result[key] = value
            elif key in NUMBER_KEYS:
                value = number(value)
                result[key] = value
                if key == "g_flPatternTexCoordScale":
                    transform[0] = value
            elif key in RANGE_KEYS:
                low, middle, high = vector(value)
                if not low <= middle <= high:
                    raise ValueError("range must contain the current value")
                if key == "g_flWearAmount":
                    result["wearRange"] = [low, high]
                    result[key] = middle
                elif key == "g_flPatternTexCoordRotation":
                    result["texRotationRange"] = [low, high]
                    transform[3] = middle
                else:
                    axis = "X" if key.endswith(".0") else "Y"
                    result[f"texOffset{axis}Range"] = [low, high]
                    transform[1 if axis == "X" else 2] = middle
            elif key in COLOR_KEYS:
                color = vector(value)
                if not all(0 <= component <= 255 for component in color):
                    raise ValueError("color components must be in 0..255")
                result[key] = [component / 255 for component in color]
            elif key == "preview_weapon":
                if not isinstance(value, str) or not re.fullmatch(r"weapon_[a-z0-9_]+", value):
                    raise ValueError("invalid weapon identifier")
                result["weapon"] = value[len("weapon_"):]
            elif key == "composite_material_class":
                names = {"PaintKit_" + name.replace(" ", "").replace("-", ""): code
                         for code, name in styles.items() if code in STYLE_CODES}
                if not isinstance(value, str) or value not in names:
                    raise ValueError("unsupported finish style")
                result["style"] = names[value]
        except (ValueError, TypeError) as error:
            raise ValueError(f"line {line_number}, {key}: {error}") from error
        seen.add(key)
    if not seen:
        raise ValueError("no supported parameters found")
    result["uTexTransform"] = transform
    return result
