// Connect a shader parameter to the property of a QML component
// @param qmlComponent QML component
// @param propertyKey QML component key to bind
// @param shaderParameter Shader parameter object
function connect(qmlComponent, propertyKey, shaderParameter) {
    // Set QML property to the current parameter value
    qmlComponent[propertyKey] = shaderParameter.value;

    // When the QML property has changed, update shader parameter data
    qmlComponent[propertyKey + "Changed"].connect(function () {
        shaderParameter.value = qmlComponent[propertyKey];
    });

    // When the shader parameter data has changed, update the QML property
    shaderParameter.valueChanged.connect(function () {
        qmlComponent[propertyKey] = shaderParameter.value;
    });
}