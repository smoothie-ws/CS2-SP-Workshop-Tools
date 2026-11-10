import QtQuick 2.15

QtObject {
    id: weaponFinish

    property var parameters: {}

    property bool loading: false
    property var initialValues: ({})
    property var connections: []

    function captureDefaults() {
        const snapshot = {};
        for (const [param, component] of Object.entries(parameters))
            if (component.control)
                snapshot[param] = component.control[component.prop];
        initialValues = JSON.parse(JSON.stringify(snapshot));
    }

    function loadParams() {
        const stored = loadWeaponFinishProject() || {};
        const defaults = JSON.parse(Plugin.getDefaultWeaponFinishParameters()) || {};
        const values = Object.assign({}, initialValues, defaults, stored);
        // Older projects store only matrices. New/partial projects use the
        // configured scale instead of inheriting controls from the previous project.
        if (!stored.uTexTransform) {
            delete values.uTexTransform;
            if (!stored.g_vPatternTexCoordXform0 && !stored.g_vPatternTexCoordXform1)
                values.uTexTransform = [values.g_flPatternTexCoordScale, 0, 0, 0];
        }
        loading = true;
        try {
            if (parameters.g_bPBRValidation && parameters.g_bPBRValidation.control)
                parameters.g_bPBRValidation.control.checked = Boolean(stored.pbrValidationEnabled !== undefined
                    ? stored.pbrValidationEnabled : stored.g_bPBRValidation);
            // Set ranges first: changing a range can move its current value.
            for (const key of ["wearRange", "texRotationRange", "texOffsetXRange", "texOffsetYRange"])
                if (values[key] !== undefined && parameters[key] && parameters[key].control)
                    parameters[key].control[parameters[key].prop] = values[key];
            for (const [param, value] of Object.entries(values)) {
                const component = parameters[param];
                if (!component || !component.control || param.endsWith("Range") || param === "uTexTransform") continue;
                if (values.uTexTransform && param.startsWith("g_vPatternTexCoordXform")) continue;
                component.control[component.prop] = value;
            }
            if (values.uTexTransform)
                parameters.uTexTransform.control.components = values.uTexTransform;
        } finally {
            loading = false;
        }
        return stored;
    }

    function dumpParams() {
        const w = loadWeaponFinishProject() || {};
        for (const [param, component] of Object.entries(parameters))
            if (component.control)
                w[param] = component.control[component.prop];
        if (parameters.g_bPBRValidation && parameters.g_bPBRValidation.control)
            w.pbrValidationEnabled = parameters.g_bPBRValidation.control.checked;
        return w;
    }

    function disconnect() {
        for (const component of connections) {
            try { component.control[component.prop + 'Changed'].disconnect(component.slot); } catch (e) {}
            component.slot = null;
        }
        connections = [];
    }

    // Keep live writes synchronous; only the initial snapshot is batched.
    function connect() {
        disconnect();
        const shaderParams = JSON.parse(Plugin.js('Object.keys(alg.shaders.parameters(0))')) || [];
        const assignments = [];
        const connected = [];

        for (const param of shaderParams) {
            const component = parameters[param];
            if (!component) continue;
            const { prop, control, expr } = component;
            if (!control) continue;
            const signalName = prop + 'Changed';

            const prefix = `alg.shaders.parameter(0,${JSON.stringify(param)}).value = `;
            const assignment = () => prefix + JSON.stringify(expr == null ? control[prop] : expr(control[prop]));
            const fn = () => { if (!loading) Plugin.js(assignment()); };
            // Keep each write isolated so one stale/incompatible parameter
            // does not prevent the remaining controls from reaching the shader.
            assignments.push(`try { ${assignment()}; } catch (e) {}`);

            if (control[signalName]) {
                control[signalName].connect(fn);
                component.slot = fn;
                connected.push(component);
            }
        }
        connections = connected;
        if (assignments.length) Plugin.js(assignments.join(';'));
    }

    function dump() {
        Plugin.dumpWeaponFinish(JSON.stringify(dumpParams()));
    }

    function updateWeapon(weapon, preserveSelected = false) {
        if (!preserveSelected)
            for (const param of ["g_tColor", "g_tMetalness", "g_tSurface", "g_tMasks", "g_tAmbientOcclusion"])
                if (parameters[param] && parameters[param].control)
                    parameters[param].control.url = "";
        for (const [param, path] of Object.entries(JSON.parse(Plugin.updateWeapon(weapon))))
            if (parameters[param] && parameters[param].control && (!preserveSelected || !parameters[param].control.url))
                parameters[param].control.url = path;
    }

    function syncEcon() {
        dump();
        Plugin.exportWeaponFinishEcon();
    }

    function importEcon() {
        const previousWeapon = parameters.weapon.control.currentKey;
        Plugin.importWeaponFinishEcon();
        loadParams();
        const weapon = parameters.weapon.control.currentKey;
        updateWeapon(weapon, weapon === previousWeapon);
        updateStyle();
    }

    function resetParameter(parameter) {
        const value = JSON.parse(Plugin.getDefaultWeaponFinishParameter(parameter));
        if (value !== undefined && value !== null) {
            const component = parameters[parameter];
            if (component && component.control)
                component.control[component.prop] = value;
        }
    }

    function saveDefaults() {
        const values = dumpParams();
        for (const key of ["name", "econitem", "texturesFolder"])
            delete values[key];
        Plugin.setDefaultWeaponFinishParameters(JSON.stringify(values));
    }

    function restoreDefaults() {
        const exclude = ["weapon", "econitem", "texturesFolder"];
        const values = JSON.parse(Plugin.getDefaultWeaponFinishParameters());

        for (const [param, value] of Object.entries(values)) 
            if (!exclude.includes(param) && param in parameters) {
                const component = parameters[param];
                if (component.control)
                    component.control[component.prop] = value;
            }
    }

    function loadWeaponFinishProject() {
        return JSON.parse(Plugin.getWeaponFinish());
    }
}
