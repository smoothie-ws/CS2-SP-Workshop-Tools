import QtQuick 2.15
import QtQuick.Controls 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.15
import QtQuick.Window 2.15

Window {
    id: root
    modality: Qt.ApplicationModal
    flags: Qt.Tool
    title: qsTr("Color Picker")
    width: 300
    minimumWidth: 225
    maximumWidth: 500
    height: 250
    minimumHeight: 225
    maximumHeight: 500
    
    property alias color: currentColor.color
    
    function clamp(value, min, max) { return Math.min(Math.max(value, min), max); }

    onVisibleChanged: {
        color.hsvHue = clamp(color.hsvHue, 0, 1);
        previousColor.color = color;
    }

    Rectangle { anchors.fill: parent; color: "#313131" }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        RowLayout {
            Rectangle {
                id: colorGradient
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 150
                clip: true

                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(0, 0)
                    end: Qt.point(parent.width, 0)
                    gradient: Gradient {
                        GradientStop { position: 1.0; color: Qt.hsva(root.color.hsvHue, 1, 1) }
                        GradientStop { position: 0.0; color: Qt.hsva(root.color.hsvHue, 0, 1) }
                    }
                }

                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(0, 0)
                    end: Qt.point(0, parent.height)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.hsva(0, 0, 1, 0) }
                        GradientStop { position: 1.0; color: Qt.hsva(0, 0, 0, 1) }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        root.color.hsvSaturation = clamp(mouse.x / width, 0.0, 1.0);
                        root.color.hsvValue = clamp(1.0 - (mouse.y / height), 0.0, 1.0);
                    }
                    onPositionChanged: {
                        root.color.hsvSaturation = clamp(mouse.x / width, 0.0, 1.0);
                        root.color.hsvValue = clamp(1.0 - (mouse.y / height), 0.0, 1.0);
                    }
                }

                Canvas {
                    id: cursor
                    width: 20
                    height: 20
                    x: root.color.hsvSaturation * colorGradient.width - width / 2
                    y: (1.0 - root.color.hsvValue) * colorGradient.height - height / 2
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = "#000";
                        ctx.lineWidth = 2;
                        ctx.beginPath();
                        ctx.moveTo(width / 2, 0);
                        ctx.lineTo(width / 2, height);
                        ctx.moveTo(0, height / 2);
                        ctx.lineTo(width, height / 2);
                        ctx.stroke();
                    }
                }
            }

            Rectangle {
                id: hueSlider
                Layout.fillHeight: true
                Layout.minimumWidth: 10
                rotation: 180
                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(0, parent.height)
                    end: Qt.point(0, 0)
                    gradient: Gradient {
                        GradientStop { position: 6 / 6; color: "#ff0000" }
                        GradientStop { position: 5 / 6; color: "#ffff00" }
                        GradientStop { position: 4 / 6; color: "#00ff00" }
                        GradientStop { position: 3 / 6; color: "#00ffff" }
                        GradientStop { position: 2 / 6; color: "#0000ff" }
                        GradientStop { position: 1 / 6; color: "#ff00ff" }
                        GradientStop { position: 0 / 6; color: "#ff0000" }
                    }
                }

                Item {
                    x: 0 - width
                    y: clamp(root.color.hsvHue * hueSlider.height, 0, hueSlider.height) - height / 2
                    width: 5
                    height: 10
                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.beginPath();
                            ctx.moveTo(0, 0);
                            ctx.lineTo(width, height / 2);
                            ctx.lineTo(0, height);
                            ctx.closePath();
                            ctx.fillStyle = "#fff";
                            ctx.fill();
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: root.color.hsvHue = clamp(mouse.y / hueSlider.height, 0.0, 1.0)
                    onPositionChanged: root.color.hsvHue = clamp(mouse.y / hueSlider.height, 0.0, 1.0)
                }
            }
        }

        RowLayout {
            Rectangle {
                id: currentColor
                Layout.fillWidth: true
                Layout.minimumWidth: 50
                Layout.maximumWidth: 100
                Layout.minimumHeight: 25
            }

            Rectangle {
                id: previousColor
                height: currentColor.height
                width: currentColor.width * 0.3
            }

            Item { Layout.fillWidth: true }

            SPTextInput {
                id: colorTextInput
                Layout.preferredWidth: 65
                Layout.minimumHeight: 25
                color: "#999999"
                text: root.color
                onEditingFinished: root.color = text
            }
        }
    }
}