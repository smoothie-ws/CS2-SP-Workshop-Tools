"""Exact-version shader snapshots for reversible project setup."""
import json
import substance_painter as sp


_CAPTURE = """(function() {
	var instances = alg.shaders.instances();
	for (var i = 0; i < instances.length; ++i) {
		if (instances[i].id !== 0) continue;
		var parameters = alg.shaders.parameters(0);
		var values = {};
		Object.keys(parameters).forEach(function(name) {
			values[name] = parameters[name].value;
		});
		return {id: 0, url: instances[i].url, parameters: values};
	}
	throw new Error("No main shader instance is available");
})()"""

# Restore by URL: Painter's generic serializer resolves names ambiguously.
_RESTORE = """(function(saved) {
	var instances = alg.shaders.instances();
	var current = null;
	for (var i = 0; i < instances.length; ++i)
		if (instances[i].id === saved.id) current = instances[i];
	if (!current) throw new Error("Original shader instance is missing");
	if (current.url !== saved.url)
		alg.shaders.updateShaderInstance(saved.id, saved.url);
	var parameters = alg.shaders.parameters(saved.id);
	Object.keys(saved.parameters).forEach(function(name) {
		parameters[name].value = saved.parameters[name];
	});
})("""


def capture_main_shader():
    return sp.js.evaluate(_CAPTURE)


def restore_shader(snapshot):
    sp.js.evaluate(_RESTORE + json.dumps(snapshot) + ")")
