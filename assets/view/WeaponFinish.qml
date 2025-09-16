import QtQuick 2.15

QtObject {
    id: weaponFinish

    property var parameters: {}

    // load weapon finish parameters
    function loadParams() {
        const values = loadWeaponFinishProject();
        for (const [param, value] of Object.entries(values)) 
            if (param in parameters) {
                const component = parameters[param];
                component.control[component.prop] = value;
            }
        return values;
    }

    function getParams() {
        const w = {};
        for (const [param, component] of Object.entries(parameters))
            w[param] = component.control[component.prop];
        return w;
    }

    // connect widgets to shader
    function connect() {
        for (const [param, component] of Object.entries(parameters)) 
            if (param.startsWith("u")) {
                const control = component.control;
                const prop = component.prop;
                if (["filePath", "url"].includes(prop))
                    control[prop + "Changed"].connect(() => 
                        Plugin.js(`alg.shaders.parameter(0, "${param}").value = "${control[prop]}"`)
                    );
                else if (["range", "ranges", "array", "arrayColor", "transform"].includes(prop))
                    control[prop + "Changed"].connect(() => 
                        Plugin.js(`alg.shaders.parameter(0, "${param}").value = [${control[prop]}]`)
                    );
                else
                    control[prop + "Changed"].connect(() => 
                        Plugin.js(`alg.shaders.parameter(0, "${param}").value = ${control[prop]}`)
                    );
            }
    }

    function dump() {
        Plugin.dumpWeaponFinish(JSON.stringify(getParams()));
    }

    function updateWeapon(weapon) {
        for (const [param, path] of Object.entries(JSON.parse(Plugin.updateWeapon(weapon))))
            parameters[param].control.url = path;
    }

    function syncShader() {
        for (const [param, component] of Object.entries(parameters)) 
            if (param.startsWith("u")) {
                const value = component.control[component.prop];
                if (["filePath", "url"].includes(component.prop))
                    Plugin.js(`alg.shaders.parameter(0, "${param}").value = "${value}"`);
                else if (["range", "ranges", "array", "arrayColor", "transform"].includes(component.prop))
                    Plugin.js(`alg.shaders.parameter(0, "${param}").value = [${value}]`);
                else
                    Plugin.js(`alg.shaders.parameter(0, "${param}").value = ${value}`);
            }
    }

    function syncEcon() {
        dump();
        Plugin.exportWeaponFinishEcon();
    }

    function updateEconPath(path) {
        const values = loadWeaponFinishProject();
        values["econitem"] = path;
        Plugin.js(`alg.project.settings.setValue("weapon_finish", ${JSON.stringify(values)})`);
    }

    function updateTexturesFolderPath(path) {
        const values = loadWeaponFinishProject();
        values["texturesFolder"] = path;
        Plugin.js(`alg.project.settings.setValue("weapon_finish", ${JSON.stringify(values)})`);
    }

    function resetParameter(parameter) {
        const value = JSON.parse(Plugin.getDefaultWeaponFinishParameter(parameter));
        if (value !== undefined && value !== null) {
            const component = parameters[parameter];
            component.control[component.prop] = value;
        }
    }

    function loadWeaponFinishProject() {
        return JSON.parse(Plugin.getWeaponFinish());
    }
}
