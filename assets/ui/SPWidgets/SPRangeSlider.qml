import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import AlgWidgets 2.0
import "math.js" as MathUtils

ColumnLayout {
    id: root
    opacity: enabled ? 1.0 : 0.5

    property alias mouseArea: mouseArea
    property alias text: label.text
    property alias pressed: mouseArea.pressed
    property alias hovered: mouseArea.hovered

    property real from: 0.0
    property real to: 1.0
    property real minValue: 0.0
    property real value: 0.5
    property real maxValue: 1.0
    property var range: [minValue, maxValue]

    readonly property real minVisualPosition: MathUtils.norm(minValue, from, to)
    readonly property real visualPosition: MathUtils.norm(value, from, to)
    readonly property real maxVisualPosition: MathUtils.norm(maxValue, from, to)

    property bool pickValue: true

    onRangeChanged: {
        internal.update(() => {
            minValue = range[0];
            maxValue = range[1];
        });
        internal.syncValue();
    }

    onValueChanged: internal.update(() => {
        internal.normPosition = MathUtils.norm(value, minValue, maxValue)
    })

    onMinValueChanged: {
        internal.update(() => range = [minValue, maxValue]);
        internal.syncValue();
    }
    
    onMaxValueChanged: {
        internal.update(() => range = [minValue, maxValue]);
        internal.syncValue();
    }
    
    QtObject {
        id: internal

        property bool updating: false
        property bool syncing: false
        property real normPosition: 0.5

        function update(f) {
            if (!updating) {
                updating = true;
                f();
                updating = false;
            }
        }

        function sync(f) {
            if (!syncing) {
                syncing = true;
                f();
                syncing = false;
            }
        }

        function syncValue() {
            sync(() => value = MathUtils.mapNorm(normPosition, minValue, maxValue));
        }
    }
    
    RowLayout {
        id: sliderParameters
        Layout.fillWidth: true

        AlgLabel {
            id: label
            color: "#d0d0d0"
            Layout.fillWidth: true
        }

        SPButton {
            id: clampButton
            padding: 5
            visible: root.pickValue
            implicitWidth: 30
            icon.source: "./icons/clamp.png"
            icon.width: 20
            icon.height: 20
            tooltip.text: "Shrink range to current value"

            onClicked: {
                internal.sync(() => {
                    root.minValue = root.value;
                    root.maxValue = root.value;
                });
            }
        }

        Repeater {
            model: ["minValue", "value", "maxValue"]
            delegate: SPTextInput {
                Layout.preferredWidth: 50
                text: root[modelData].toFixed(2)
                visible: index == 1 ? root.pickValue : true
                validator: RegExpValidator { regExp: /^-?[0-9]*\.?[0-9]*$/ }

                Component.onCompleted: {
                    if (index == 0)
                        editingFinished.connect(() => 
                            root[modelData] = MathUtils.clamp(parseFloat(text), from, root.maxValue)
                        );
                    else if (index == 1)
                        editingFinished.connect(() => 
                            root[modelData] = MathUtils.clamp(parseFloat(text), root.minValue, root.maxValue)
                        );
                    else
                        editingFinished.connect(() => 
                            root[modelData] = MathUtils.clamp(parseFloat(text), root.minValue, to)
                        );
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        height: 20.0
        spacing: 10.0

        AlgLabel {
            color: "#d0d0d0"
            text: root.from
        }

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            Layout.fillWidth: true
            Layout.fillHeight: true

            property bool hovered: false

            property int closest: -1

            onEntered: hovered = true
            onExited: hovered = false
            onPressed: syncMousePosition()
            onPositionChanged: {
                if (pressed)
                    syncMousePosition();
                else
                    pickClosest();
            }

            function pickClosest() {
                const position = MathUtils.norm(mouseX - line.x, 0.0, line.width);
                const d = visualPosition - position;
                const mind = minVisualPosition - position;
                const maxd = maxVisualPosition - position;
                if (root.pickValue) {
                    if (d + mind >= 0)
                        closest = 0;
                    else if (d + maxd > 0)
                        closest = 1;
                    else
                        closest = 2;
                } else {
                    if (mind + maxd >= 0)
                        closest = 0;
                    else
                        closest = 2;
                }
            }

            function syncMousePosition() {
                const position = MathUtils.norm(mouseX - line.x, 0.0, line.width);
                if (mouseArea.closest == 0) {
                    const clamped = MathUtils.clamp(position, 0.0, root.maxVisualPosition);
                    root.minValue = MathUtils.mapNorm(clamped, root.from, root.to);
                }
                else if (mouseArea.closest == 1) {
                    const clamped = MathUtils.clamp(position, root.minVisualPosition, root.maxVisualPosition);
                    root.value = MathUtils.mapNorm(clamped, root.from, root.to);
                }
                else if (mouseArea.closest == 2) {
                    const clamped = MathUtils.clamp(position, root.minVisualPosition, 1.0);
                    root.maxValue = MathUtils.mapNorm(clamped, root.from, root.to);
                }
            }

            Rectangle {
                id: line
                height: 2.0
                color: "#707070"
                radius: Math.min(width, height) * 0.5
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                
                readonly property color minHandlerColor: Qt.hsva(0.55 + 0.45 * root.minVisualPosition, 0.5, 1.0)
                readonly property color handlerColor: Qt.hsva(0.55 + 0.45 * root.visualPosition, 0.5, 1.0)
                readonly property color maxHandlerColor: Qt.hsva(0.55 + 0.45 * root.maxVisualPosition, 0.5, 1.0)

                LinearGradient {
                    x: root.minVisualPosition * parent.width
                    width: (root.maxVisualPosition - root.minVisualPosition) * parent.width
                    height: parent.height
                    start: Qt.point(0, 0)
                    end: Qt.point(width, 0)

                    gradient: Gradient {
                        GradientStop { 
                            position: 0.0
                            color: root.pressed && mouseArea.closest == 0 ? line.minHandlerColor : "#d0d0d0" 
                        }
                        GradientStop { 
                            position: {
                                if (root.pickValue)
                                    MathUtils.norm(root.visualPosition, root.minVisualPosition, root.maxVisualPosition);
                                else
                                    mouseArea.closest == 0 ? 0.0 : 1.0;
                            }
                            color: root.pressed && mouseArea.closest == 1 ? line.handlerColor : "#d0d0d0" 
                        }
                        GradientStop { 
                            position: 1.0
                            color: root.pressed && mouseArea.closest == 2 ? line.maxHandlerColor : "#d0d0d0" 
                        }
                    }
                }

                Repeater {
                    model: ["min", "", "max"]
                    delegate: SPSliderHandler {
                        z: 1
                        text: root[modelData + (modelData.length == 0 ? "value" : "Value")].toFixed(2)
                        x: root[modelData + (modelData.length == 0 ? "visualPosition" : "VisualPosition")] * parent.width - width * 0.5
                        anchors.verticalCenter: parent.verticalCenter
                        visible: index == 1 ? root.pickValue : true
                        pressed: root.pressed && mouseArea.closest == index
                        hovered: root.hovered && mouseArea.closest == index
                        color: pressed ? line[`${modelData + (modelData.length == 0 ? "handler" : "Handler")}Color`] : "#d0d0d0"
                    }
                }
            }
        }

        AlgLabel {
            color: "#d0d0d0"
            text: root.to
        }
    }
}
