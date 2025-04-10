function block(item, f) {
    return () => {
        var state = item.state;
        if (state == "block") return;
        item.state = "block";
        f();
        item.state = state;
    };
}

export class Shader {
    static connect(item, prop, param) {
        item[prop] = param.value;
        item[prop + "Changed"].connect(
            block(item, () => (param.value = item[prop]))
        );
        param.valueChanged.connect(
            block(item, () => (item[prop] = param.value))
        );
    }
}
