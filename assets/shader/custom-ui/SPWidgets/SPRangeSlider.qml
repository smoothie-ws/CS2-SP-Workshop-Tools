import QtQuick 2.7
import QtGraphicalEffects 1.15
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

RowLayout {
    spacing: 10
    opacity: enabled ? 1.0 : 0.3
    
    property string label
    property real minValue: 0.25
    property real maxValue: 0.50
    property real firstValue: 0.1
    property real secondValue: 0.0
    property real step: 0.1
    property bool isFloat: false
    property int precision: 2

    Component.onCompleted: {
        defaults = [firstValue, secondValue];
    }

    ColumnLayout {
        spacing: 5
        
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
                    x: control.first.visualPosition * control.availableWidth
                    y: control.topPadding + ((control.availableHeight - height) / 2)
                    width: 10
                    height: 10

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        scale: control.first.pressed ? 1.3 : 1
                        color: control.first.pressed ? "#1a8dff" : "#d0d0d0"
                        border.color: "#1a8dff"
                        border.width: control.first.pressed ? 2 : 0
                        radius: 180
                    }
                }

                second.handle: Item {
                    x: control.second.visualPosition * control.availableWidth
                    y: control.topPadding + ((control.availableHeight - height) / 2)
                    width: 10
                    height: 10

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        scale: control.second.pressed ? 1.3 : 1
                        color: control.second.pressed ? "#1a8dff" : "#d0d0d0"
                        border.color: "#1a8dff"
                        border.width: control.second.pressed ? 2 : 0
                        radius: 180
                    }
                }

                background: Rectangle {
                    width: control.availableWidth
                    height: 2
                    radius: Math.round(Math.min(width/2, height/2))
                    color: (control.first.pressed | control.second.pressed) ? "#d0d0d0" : "#666666"
                    anchors.centerIn: parent

                    Item {
                        x: control.first.visualPosition * parent.width
                        y: 0
                        width: (control.second.visualPosition - control.first.visualPosition) * parent.width
                        height: 2

                        LinearGradient {
                            anchors.fill: parent
                            start: Qt.point(0, 0)
                            end: Qt.point(parent.width, 0)
                            
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: control.first.pressed ? "#1a8dff" : "#d0d0d0"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: control.second.pressed ? "#1a8dff" : "#d0d0d0"
                                }
                            }
                        }
                    }
                }
            }

            AlgLabel {
                text: maxValue
            }
        }
    }
}
