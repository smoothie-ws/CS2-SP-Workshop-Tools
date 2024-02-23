import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

RowLayout {
    spacing: 10

    property string label
    property real minValue: 0.25
    property real maxValue: 0.50
    property real firstValue: 0.1
    property real secondValue: 0.0
    property real step: 0.1
    property bool isFloat: false
    property int precision: 2
    property var defaults: []

    Component.onCompleted: {
        defaults = [firstValue, secondValue];
    }

    ColumnLayout {
        spacing: 10
        
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
                text: parseFloat(firstValue).toFixed(precision)
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
                    firstValue = parseFloat(text).toFixed(precision)
                }
            }

            AlgTextInput {
                Layout.preferredWidth: 40
                id: maxValueText
                text: parseFloat(secondValue).toFixed(precision)
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
                    secondValue = parseFloat(text).toFixed(precision)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            AlgLabel {
                text: minValue
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
                    x: control.first.visualPosition * control.width - width / 2
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
                            ctx.fillStyle = control.hovered ? "#1a8dff" : "#d0d0d0";
                            ctx.fill();
                        }
                    }
                }

                second.handle: Item {
                    x: control.second.visualPosition * control.width - width / 2
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
                    width: control.width
                    height: 2
                    radius: Math.round(Math.min(width/2, height/2))
                    color: (control.first.pressed | control.second.pressed) ? "#d0d0d0" : "#666666"
                    anchors.centerIn: parent

                    Rectangle {
                        x: control.first.visualPosition * parent.width
                        y: 0
                        width: control.second.visualPosition * parent.width - control.first.visualPosition * parent.width
                        height: 2
                        color: (control.hovered | control.first.pressed | control.second.pressed) ? "#1a8dff" : "#d0d0d0"
                    }
                }
            }

            AlgLabel {
                text: maxValue
            }
        }
    }

    AlgButton {
        text: "Restore Defaults"

        onClicked: {
            firstValue = defaults[0];
            secondValue = defaults[1];
        }
    }
}
