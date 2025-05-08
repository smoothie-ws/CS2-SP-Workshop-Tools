import QtQuick 2.15

QtObject {
    property var parameters: {}

    function isShaderParameter(param) {
        if (JSON.parse(CS2WT.js("alg.project.isOpen()")))
            return Object.keys(JSON.parse(CS2WT.js(`alg.shaders.parameters(0)`))).includes(param);
        else
            return param.startsWith("u");
    }

    // connect widgets to shader
    function connect() {
        for (const [param, component] of Object.entries(parameters)) 
            if (isShaderParameter(param)) {
                if (["filePath", "url"].includes(component.prop))
                    component.control[component.prop + "Changed"].connect(() => 
                        CS2WT.js(`alg.shaders.parameter(0, "${param}").value = "${component.control[component.prop]}"`)
                    );
                else if (["range", "arrayColor", "transform"].includes(component.prop))
                    component.control[component.prop + "Changed"].connect(() => 
                        CS2WT.js(`alg.shaders.parameter(0, "${param}").value = [${component.control[component.prop]}]`)
                    );
                else
                    component.control[component.prop + "Changed"].connect(() => 
                        CS2WT.js(`alg.shaders.parameter(0, "${param}").value = ${component.control[component.prop]}`)
                    );
            }
    }

    // load weapon finish parameters
    function load() {
        const values = JSON.parse(CS2WT.js("alg.project.settings.value(\"weapon_finish\")"));
        for (const [param, value] of Object.entries(values)) {
            const component = parameters[param];
            if (component !== undefined)
                    component.control[component.prop] = value;
        }
    }

    // dump weapon finish parameters
    function dump() {
        const w = {};
        for (const [param, component] of Object.entries(parameters))
            w[param] = component.control[component.prop];
        CS2WT.dumpWeaponFinish(JSON.stringify(w));
    }

    // sync weapon finish
    function sync() {
        CS2WT.syncWeaponFinish();
    }

    function updateEconItemPath(path) {
        const values = JSON.parse(CS2WT.js("alg.project.settings.value(\"weapon_finish\")"));
        values["econitem"] = path;
        CS2WT.js(`alg.project.settings.setValue("weapon_finish", ${JSON.stringify(values)})`);
    }

    function updateTexturesFolderPath(path) {
        const values = JSON.parse(CS2WT.js("alg.project.settings.value(\"weapon_finish\")"));
        values["texturesFolder"] = path;
        CS2WT.js(`alg.project.settings.setValue("weapon_finish", ${JSON.stringify(values)})`);
    }

    function syncShader() {
        for (const [param, component] of Object.entries(parameters)) 
            if (isShaderParameter(param)) {
                const value = component.control[component.prop];
                if (["filePath", "url"].includes(component.prop))
                    CS2WT.js(`alg.shaders.parameter(0, "${param}").value = "${value}"`);
                else if (["range", "arrayColor", "transform"].includes(component.prop))
                    CS2WT.js(`alg.shaders.parameter(0, "${param}").value = [${value}]`);
                else
                    CS2WT.js(`alg.shaders.parameter(0, "${param}").value = ${value}`);
            }
    }

    function resetParameter(parameter) {
        const component = parameters[parameter];
        component.control[component.prop] = JSON.parse(CS2WT.js("alg.project.settings.value(\"weapon_finish\")"))[parameter];
    }
}
