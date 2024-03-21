function updateComponentValue(qmlComponent, propertyKey, shaderParameter) {
    const getProperty = (propKey, param) => {
        const propType = typeof qmlComponent[propKey];
        return propType === "number" ? shader_bridge.get_number(param) :
               propType === "boolean" ? shader_bridge.get_bool(param) :
               shader_bridge.get_list(param);
    };

    qmlComponent[propertyKey] = getProperty(propertyKey, shaderParameter);
}

function connect(qmlComponent, propertyKey, shaderParameter) {
    const updateShader = () => {
        const propType = typeof qmlComponent[propertyKey];
        const propValue = propType === "number" || propType === "boolean" ?
                          qmlComponent[propertyKey] :
                          "[" + qmlComponent[propertyKey] + "]";
        shader_bridge.set_parameter_value(shaderParameter, propValue);
    };

    qmlComponent[propertyKey + "Changed"].connect(updateShader);
}