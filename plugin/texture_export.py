"""Validate, render and publish texture sets without changing project metadata."""
import copy
import os
import tempfile
from contextlib import nullcontext

import substance_painter as sp

from .export_presets import weapon_finish_preset
from .painter import Path


def export_textures(weapon_finish):
	folder_path = weapon_finish.get("texturesFolder", "")

	if not folder_path or not Path.isdir(folder_path):
		raise ValueError(f'Texture export folder does not exist: {folder_path}')

	# get finish name
	finish_name: str = weapon_finish.get("econitem", "")
	if not finish_name or not finish_name.strip():
		finish_name = weapon_finish.get("name") or weapon_finish.get("weapon") or "untitled"
	else:
		finish_name = Path.filename(finish_name) or "untitled"

	export_preset = weapon_finish_preset(weapon_finish, finish_name)

	texture_sets = list(sp.textureset.all_texture_sets())
	if not texture_sets:
		raise ValueError("No texture sets to export")
	export_config = {
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
		}]
	}

	jobs = []
	expected = {item["fileName"] for item in export_preset["maps"]}
	for index, texture_set in enumerate(texture_sets):
		name = texture_set.name()
		if weapon_finish.get("g_bOverrideAmbientOcclusion"):
			baked_ao = texture_set.get_mesh_map_resource(sp.textureset.MeshMapUsage.AO)
			if not baked_ao and any(not stack.has_channel(sp.textureset.ChannelType.AO) for stack in texture_set.all_stacks()):
				raise ValueError(f"Cannot export {name}: missing inputs for {finish_name}_ao. Add an AO channel, bake an AO mesh map, or disable the AO override.")
		# The single econitem references the first set. Additional sets use
		# separate directories to prevent collisions.
		target = folder_path if index == 0 else Path.join(folder_path, f"texture_set_{index + 1}")
		config = copy.deepcopy(export_config)
		config["exportPath"] = target
		config["exportList"] = [{"rootPath": name, "exportPreset": "weapon_finish"}]
		planned = sp.export.list_project_textures(config)
		available = {Path.filename(path) for files in planned.values() for path in files}
		missing = expected - available
		if missing:
			raise ValueError(f"Cannot export {name}: missing inputs for {', '.join(sorted(missing))}. Check enabled maps; AO requires an AO channel or a baked AO mesh map.")
		jobs.append((name, target, config))

	# Painter's MapExporter can reject UNC file:// hosts even when the
	# share is writable. Render every set locally before publishing any
	# network output, leaving the project paths and econitem unchanged.
	is_unc = folder_path.replace("\\", "/").startswith("//")
	staging = tempfile.TemporaryDirectory(prefix="cs2wt-export-") if is_unc else nullcontext(None)
	with staging as local_root:
		outputs = []
		for index, (name, target, config) in enumerate(jobs):
			if local_root:
				config = dict(config, exportPath=local_root if index == 0 else os.path.join(local_root, f"texture_set_{index + 1}"))
			os.makedirs(config["exportPath"], exist_ok=True)
			export_result = sp.export.export_project_textures(config)
			if export_result.status != sp.export.ExportStatus.Success:
				raise RuntimeError(export_result.message)
			files = [path for paths in export_result.textures.values() for path in paths]
			written = {Path.filename(path) for path in files}
			missing = expected - written
			if missing:
				raise RuntimeError(f"Incomplete export for {name}: {', '.join(sorted(missing))}")
			if local_root:
				for path in files:
					relative = os.path.relpath(path, config["exportPath"])
					if relative == os.pardir or relative.startswith(os.pardir + os.sep) or os.path.isabs(relative):
						raise RuntimeError(f"Export reported a path outside its staging folder: {path}")
					if not os.path.isfile(path):
						raise RuntimeError(f"Export did not create the reported file: {path}")
					outputs.append((path, os.path.join(target, relative)))
		for source, destination in outputs:
			os.makedirs(os.path.dirname(destination), exist_ok=True)
			Path.copy_atomic(source, destination)
