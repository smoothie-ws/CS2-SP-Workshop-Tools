import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

ColumnLayout {
    spacing: 5

    property string label
    property real minValue
    property real maxValue
    property real firstValue
    property real secondValue
    property real step

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        AlgLabel {
            text: label
        }

        // kind of a spacer
        Item {
            Layout.fillWidth: true
        }

        AlgTextInput {
            Layout.preferredWidth: 40
            id: minValueText
            text: parseFloat(firstValue).toFixed(2)
            validator: RegExpValidator { regExp: /^-?[0-9]*\.?[0-9]*$/ }
            horizontalAlignment: TextInput.AlignRight

            onActiveFocusChanged: {
                if (focus)
                {
                    selectAll()
                }
                else {
                    deselect()
                }
            }
            onEditingFinished: {
                firstValue = parseFloat(text)

            }
        }

        AlgTextInput {
            Layout.preferredWidth: 40
            id: maxValueText
            text: parseFloat(secondValue).toFixed(2)
            validator: RegExpValidator { regExp: /^-?[0-9]*\.?[0-9]*$/ }
            horizontalAlignment: TextInput.AlignRight

            onActiveFocusChanged: {
                if (focus)
                {
                    selectAll()
                }
                else {
                    deselect()
                }
            }
            onEditingFinished: {
                secondValue = parseFloat(text)
            }
        }
    }

    RangeSlider {
        id: control
        Layout.fillWidth: true
        from: minValue
        to: maxValue
        snapMode: RangeSlider.SnapAlways
        stepSize: step
        first.value: firstValue
        second.value: secondValue

        first.onValueChanged: {
            firstValue = first.value
        }

        second.onValueChanged: {
            secondValue = second.value
        }

        first.handle: Item {
            x: control.first.visualPosition * control.availableWidth
            y: control.topPadding + ((control.availableHeight - height) / 2) - 4
            width: 10
            height: 10

            Canvas {
                width: parent.width
                height: parent.height

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.beginPath();
                    ctx.moveTo(width / 2, height);
                    ctx.lineTo(width, 0);
                    ctx.lineTo(0, 0);
                    ctx.closePath();
                    ctx.fillStyle = "#d0d0d0";
                    ctx.fill();
                }
            }
        }

        second.handle: Item {
            x: control.second.visualPosition * control.availableWidth
            y: control.topPadding + ((control.availableHeight - height) / 2) + 4
            width: 10
            height: 10

            Canvas {
                width: parent.width
                height: parent.height

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.beginPath();
                    ctx.moveTo(width / 2, 0);
                    ctx.lineTo(width, height);
                    ctx.lineTo(0, height);
                    ctx.closePath();
                    ctx.fillStyle = "#d0d0d0";
                    ctx.fill();
                }
            }
        }

        background: Rectangle {
            width: control.availableWidth
            height: 2
            radius: Math.round(Math.min(width/2, height/2))
            color: "#666666"
            anchors.centerIn: parent


            Repeater {
                model: 9
                delegate: Rectangle {
                    x: (index + 1) * control.width / 10 - 8
                    y: -2
                    width: 2
                    height: 6
                    color: "#666666"
                }
            }

            Rectangle {
                x: control.first.position * parent.width
                y: 0
                width: control.second.position * parent.width - control.first.position * parent.width
                height: 2
                color: "#d0d0d0"
            }
        }
    }
}
