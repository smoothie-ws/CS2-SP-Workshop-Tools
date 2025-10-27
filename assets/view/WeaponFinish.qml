import QtQuick 2.15

QtObject {
    id: weaponFinish

    property var parameters: {}

    function loadParams() {
        const values = loadWeaponFinishProject();
        for (const [param, value] of Object.entries(values)) 
            if (param in parameters) {
                const component = parameters[param];
                component.control[component.prop] = value;
            }
        return values;
    }

    function dumpParams() {
        const w = {};
        for (const [param, component] of Object.entries(parameters))
            w[param] = component.control[component.prop];
        return w;
    }

    // connects widgets to shader
    function connect() {
        const shaderParams = Object.keys(JSON.parse(Plugin.js('alg.shaders.parameters(0)')));

        for (const param of shaderParams) {
            if (!parameters.hasOwnProperty(param)) continue;

            const { prop, control, expr } = parameters[param];
            const signalName = prop + 'Changed';

            if (parameters[param].slot) {
                try { control[signalName].disconnect(parameters[param].slot); } catch (e) {}
                parameters[param].slot = null;
            }

            const fn = expr == null ? 
                () => Plugin.js(`alg.shaders.parameter(0,"${param}").value = ${JSON.stringify(control[prop])}`) : 
                () => Plugin.js(`alg.shaders.parameter(0,"${param}").value = ${JSON.stringify(expr(control[prop]))}`);
            fn();
            
            if (control[signalName]) {
                control[signalName].connect(fn);
                parameters[param].slot = fn;
            }
        }
    }

    function dump() {
        Plugin.dumpWeaponFinish(JSON.stringify(dumpParams()));
    }

    function updateWeapon(weapon) {
        for (const [param, path] of Object.entries(JSON.parse(Plugin.updateWeapon(weapon))))
            parameters[param].control.url = path;
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
