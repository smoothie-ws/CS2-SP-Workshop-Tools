import QtQuick 2.15

QtObject {
    property var parameters: {}

    function isShaderParameter(param) {
        if (JSON.parse(internal.js("alg.project.isOpen()")))
            return Object.keys(JSON.parse(internal.js(`alg.shaders.parameters(0)`))).includes(param);
        else
            return param.startsWith("u");
    }

    // connect widgets to shader
    function connect() {
        for (const [param, component] of Object.entries(parameters)) 
            if (isShaderParameter(param)) {
                if (["filePath", "url"].includes(component.prop))
                    component.control[component.prop + "Changed"].connect(() => 
                        internal.js(`alg.shaders.parameter(0, "${param}").value = "${component.control[component.prop]}"`)
                    );
                else if (["range", "arrayColor", "transform"].includes(component.prop))
                    component.control[component.prop + "Changed"].connect(() => 
                        internal.js(`alg.shaders.parameter(0, "${param}").value = [${component.control[component.prop]}]`)
                    );
                else
                    component.control[component.prop + "Changed"].connect(() => 
                        internal.js(`alg.shaders.parameter(0, "${param}").value = ${component.control[component.prop]}`)
                    );
            }
    }

    // load weapon finish parameters
    function load() {
        const values = JSON.parse(internal.js("alg.project.settings.value(\"weapon_finish\")"));
        for (const [param, value] of Object.entries(values)) {
            const component = parameters[param];
            if (component !== undefined) {
                // set value from shader if possible
                if (isShaderParameter(param) && JSON.parse(internal.js("alg.project.isOpen()")))
                    component.control[component.prop] = JSON.parse(internal.js(`alg.shaders.parameter(0, "${param}").value`));
                // else set the saved value
                else
                    component.control[component.prop] = value;
            }
        }
    }

    // save weapon finish parameters
    function save() {
        var values = {}
        for (const [param, component] of Object.entries(parameters))
            values[param] = component.control[component.prop];
        internal.saveWeaponFinish(JSON.stringify(values));
    }

    function updateEconItemPath(path) {
        const values = JSON.parse(internal.js("alg.project.settings.value(\"weapon_finish\")"));
        values["econitem"] = path;
        internal.js(`alg.project.settings.setValue("weapon_finish", ${JSON.stringify(values)})`);
    }

    function updateTexturesFolderPath(path) {
        const values = JSON.parse(internal.js("alg.project.settings.value(\"weapon_finish\")"));
        values["texturesFolder"] = path;
        internal.js(`alg.project.settings.setValue("weapon_finish", ${JSON.stringify(values)})`);
    }

    function syncShader() {
        for (const [param, component] of Object.entries(parameters)) 
            if (isShaderParameter(param)) {
                const value = component.control[component.prop];
                if (["filePath", "url"].includes(component.prop))
                    internal.js(`alg.shaders.parameter(0, "${param}").value = "${value}"`);
                else if (["range", "arrayColor", "transform"].includes(component.prop))
                    internal.js(`alg.shaders.parameter(0, "${param}").value = [${value}]`);
                else
                    internal.js(`alg.shaders.parameter(0, "${param}").value = ${value}`);
            }
    }

    function resetParameter(parameter) {
        const component = parameters[parameter];
        component.control[component.prop] = JSON.parse(internal.js("alg.project.settings.value(\"weapon_finish\")"))[parameter];
    }
}
