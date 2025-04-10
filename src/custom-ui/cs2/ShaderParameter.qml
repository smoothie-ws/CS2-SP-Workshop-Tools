import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import "SPWidgets"

RowLayout {
    id: root
    implicitHeight: loader.height

    // shader related
    property var value: 0
    property var defaultValue: 0
    property bool updating: false
    property string prop: ""
    property string parameter: ""

    default property alias children: loader.sourceComponent
    property alias control: loader.item
    property alias text: label.text
    property real scopeWidth: label.width
    property alias resettable: resetButton.visible

    onVisibleChanged: scale = visible

    Behavior on scale {
        NumberAnimation { 
            duration: 100
            easing.type: Easing.OutQuart
        }
    }

    Component.onCompleted: {
        if (prop !== "") {
            control[prop + "Changed"].connect(() => update(() => value = control[prop]));
            valueChanged.connect(() => update(() => control[prop] = value));
        }
    }

    function connect(shaderId) {
        if (parameter !== "") {
            const param = alg.shaders.parameter(shaderId, parameter);
            value = param.value;
            valueChanged.connect(() => 
                update(() => (param.value = value))
            );
            param.valueChanged.connect(() => 
                update(() => (value = param.value))
            );
        }
    }

    function update(f) {
        if (!updating) {
            updating = true;
            f();
            updating = false;
        }
    }

    AlgLabel { 
        id: label
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: scopeWidth
    }

    Loader {
        id: loader
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true
    }

    SPButton {
        id: resetButton
        Layout.alignment: Qt.AlignVCenter
        enabled: root.value !== root.defaultValue
        icon.source: "./assets/icons/icon_cycle.png"
        icon.width: 14
        icon.height: 14
        background: null

        onClicked: {
            if (root.defaultValue !== null) 
                root.value = root.defaultValue 
        }
    }
}
