import QtQuick 2.7
import QtGraphicalEffects 1.15
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

RowLayout {
    id: root
    spacing: 10
    opacity: enabled ? 1.0 : 0.3
    
    property alias text: label.text
    property alias from: control.from
    property alias to: control.to
    property alias minValue: control.first.value
    property alias maxValue: control.second.value
    property alias stepSize: control.stepSize
    property int precision: stepSize.toString().includes('.') ? stepSize.toString().split('.').pop().length : 0
    property var range: [minValue, maxValue]

    ColumnLayout {
        spacing: 5
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            AlgLabel {
                id: label
                Layout.fillWidth: true
            }

            Row {
                spacing: 10

                SPTextInput {
                    width: 40
                    text: parseFloat(root.minValue).toFixed(precision)
                    validator: RegExpValidator { regExp: /^-?[0-9]*\.?[0-9]*$/ }
                    horizontalAlignment: TextInput.AlignRight
                    onEditingFinished: root.minValue = parseFloat(text)
                }

                SPTextInput {
                    width: 40
                    text: parseFloat(root.maxValue).toFixed(precision)
                    validator: RegExpValidator { regExp: /^-?[0-9]*\.?[0-9]*$/ }
                    horizontalAlignment: TextInput.AlignRight
                    onEditingFinished: root.maxValue = parseFloat(text)
                }
            }

        }

        RowLayout {
            Layout.fillWidth: true

            AlgLabel {
                text: root.from
            }

            RangeSlider {
                id: control
                Layout.fillWidth: true
                snapMode: RangeSlider.SnapAlways
                
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
                        radius: width
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
                        radius: width
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
                text: root.to
            }
        }
    }
}
