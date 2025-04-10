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
    property alias value: control.value
    property alias stepSize: control.stepSize
    property int precision: stepSize.toString().includes('.') ? stepSize.toString().split('.').pop().length : 0

    ColumnLayout {
        spacing: 5
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            AlgLabel {
                Layout.fillWidth: true
                id: label
            }

            SPTextInput {
                Layout.preferredWidth: 40
                text: parseFloat(value).toFixed(precision)
                validator: RegExpValidator { regExp: /^-?[0-9]*\.?[0-9]*$/ }
                horizontalAlignment: TextInput.AlignRight
                onEditingFinished: root.value = parseFloat(text)
            }
        }

        RowLayout {
            Layout.fillWidth: true

            AlgLabel {
                text: root.from
            }

            Slider {
                id: control
                Layout.fillWidth: true
                snapMode: RangeSlider.SnapAlways
                stepSize: 0.01
                
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
                text: root.to
            }
        }
    }
}
