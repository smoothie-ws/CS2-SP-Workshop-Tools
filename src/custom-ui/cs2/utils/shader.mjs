export class Shader {
    static connect(item, prop, param) {
        item[prop] = param.value;
        item[`${prop}Changed`].connect(
            session(item, () => (param.value = item[prop]))
        );
        param.valueChanged.connect(
            session(item, () => (item[prop] = param.value))
        );
    }
}

function session(item, f) {
    return () => {
        var state = item.state;
        if (state == "sync") return;
        item.state = "sync";
        f();
        item.state = state;
    };
}
