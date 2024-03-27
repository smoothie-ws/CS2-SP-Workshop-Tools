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
    property real controlValue: 0.1
    property real step: 0.1
    property bool isFloat: false
    property int precision: 2

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
                id: valueText
                text: parseFloat(controlValue).toFixed(precision)
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
                    controlValue = Math.max(minValue, Math.min(parseFloat(text).toFixed(precision), maxValue))
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            AlgLabel {
                text: minValue
            }

            Slider {
                id: control
                Layout.fillWidth: true
                from: minValue
                to: maxValue
                snapMode: RangeSlider.SnapAlways
                stepSize: step
                value: controlValue

                onValueChanged: {
                    controlValue = value
                }
                
                handle: Item {
                    x: control.visualPosition * control.availableWidth
                    y: control.topPadding + ((control.availableHeight - height) / 2)
                    width: 10
                    height: 10

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        scale: control.pressed ? 1.3 : 1
                        color: control.pressed ? "#1a8dff" : "#d0d0d0"
                        border.color: "#1a8dff"
                        border.width: control.pressed ? 2 : 0
                        radius: 180
                    }
                }

                background: Rectangle {
                    width: control.availableWidth
                    height: 2
                    radius: Math.round(Math.min(width/2, height/2))
                    color: control.pressed ? "#d0d0d0" : "#666666"
                    anchors.centerIn: parent

                    Item {
                        x: 0
                        y: 0
                        width: control.visualPosition * parent.width
                        height: 2

                        LinearGradient {
                            anchors.fill: parent
                            start: Qt.point(0, 0)
                            end: Qt.point(parent.width, 0)
                            
                            gradient: Gradient {
                                GradientStop {
                                    position: 0.0
                                    color: "#d0d0d0"
                                }
                                GradientStop {
                                    position: 1.0
                                    color: control.pressed ? "#1a8dff" : "#d0d0d0"
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
