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
    property alias hovered: mouseArea.containsMouse

    property real from: 0.0
    property real to: 1.0
    property real value: 0.5

    readonly property real visualPosition: MathUtils.norm(value, from, to)
    
    RowLayout {
        id: sliderParameters
        Layout.fillWidth: true

        AlgLabel {
            id: label
            color: "#d0d0d0"
            Layout.fillWidth: true
        }

        SPTextInput {
            Layout.preferredWidth: 50
            text: root.value.toFixed(2)
            validator: RegExpValidator { regExp: /^-?[0-9]*\.?[0-9]*$/ }

            onEditingFinished: root.value = MathUtils.clamp(parseFloat(text), from, to);
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

            onPressed: sync()
            onPositionChanged: if (pressed) sync()

            function sync() {
                const position = MathUtils.norm(mouseX - line.x, 0.0, line.width);
                root.value = MathUtils.mapNorm(MathUtils.clamp(position, 0.0, 1.0), root.from, root.to);
            }

            Rectangle {
                id: line
                height: 2.0
                color: "#707070"
                radius: Math.min(width, height) * 0.5
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: handler.width * 0.5
                anchors.rightMargin: handler.width * 0.5
                
                readonly property color handlerColor: Qt.hsva(0.55 + 0.45 * root.visualPosition, 0.5, 1.0)

                LinearGradient {
                    width: root.visualPosition * parent.width
                    height: parent.height
                    start: Qt.point(0, 0)
                    end: Qt.point(width, 0)

                    gradient: Gradient {
                        GradientStop { 
                            position: 0.0
                            color: "#d0d0d0" 
                        }
                        GradientStop { 
                            position: 1.0
                            color: root.pressed ? line.handlerColor : "#d0d0d0"
                        }
                    }
                }

                SPSliderHandler {
                    id: handler
                    z: 1
                    x: root.visualPosition * parent.width - width * 0.5
                    anchors.verticalCenter: parent.verticalCenter
                    pressed: root.pressed
                    hovered: root.hovered
                    text: root.value.toFixed(2)
                    color: pressed ? line.handlerColor : "#d0d0d0"
                }
            }
        }

        AlgLabel {
            color: "#d0d0d0"
            text: root.to
        }
    }
}
