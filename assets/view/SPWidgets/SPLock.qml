import QtQuick 2.15

QtObject {
    property bool updating: false

    function update(f) {
        if (!updating) {
            updating = true;
            f();
            updating = false;
        }
    }
}
