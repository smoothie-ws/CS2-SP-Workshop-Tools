import QtQuick 2.7
import QtQuick.Controls 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.15

Item {
    id: root
    anchors.fill: parent

    property color color: "#000"
    property var arrayColor: [color.r, color.g, color.b]

    function clamp(value, min, max) {
        return Math.min(Math.max(value, min), max);
    }

    function updateCursor(mouseX, mouseY) {
        const maxX = colorGradient.width;
        const maxY = colorGradient.height;

        cursor.x = clamp(mouseX, 0, maxX) - cursor.offsetX;
        cursor.y = clamp(mouseY, 0, maxY) - cursor.offsetY;
    }

    function updateColor(color) {
        var col = rgb2hsv(color);

        hueSlider.value = col.h;
        updateCursor(colorGradient.width * col.s, colorGradient.height * (1.0 - col.v));
    }

    function rgb2hsv(color) {
        var r = color.r / 255;
        var g = color.g / 255;
        var b = color.b / 255;

        var max = Math.max(r, g, b);
        var min = Math.min(r, g, b);
        var delta = max - min;
        var h, s, v;

        if (delta === 0) {
            h = 0;
        } else if (max === r) {
            h = ((g - b) / delta) % 6;
        } else if (max === g) {
            h = (b - r) / delta + 2;
        } else {
            h = (r - g) / delta + 4;
        }

        h = Math.round(h * 60);
        if (h < 0) {
            h += 360;
        }

        v = max;
        s = delta === 0 ? 0 : delta / max;

        return { h: h / 360, s: s, v: v * 255 };
    }

    Component.onCompleted: {
        updateColor(color);
        previousColor.color = color;
        currentColor["colorChanged"].connect(function() { 
            root.color = currentColor.color;
            colorTextInput.text = currentColor.color;
        });
    }

    ColumnLayout {
        id: layout
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
                        GradientStop { position: 1.0; color: Qt.hsva(currentColor.hue, 1, 1) }
                        GradientStop { position: 0.0; color: Qt.hsva(currentColor.hue, 0, 1) }
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
                    id: mouseArea
                    anchors.fill: parent

                    onPressed: {
                        updateCursor(mouse.x, mouse.y);
                    }

                    onPositionChanged: {
                        if (pressedButtons == Qt.LeftButton) {
                            updateCursor(mouse.x, mouse.y);
                        }
                    }
                }

                onWidthChanged: {
                    cursor.x = currentColor.saturation * width - cursor.offsetX;
                }

                onHeightChanged: {
                    cursor.y = (1.0 - currentColor.value) * height - cursor.offsetY;
                }

                Canvas {
                    id: cursor
                    width: 20
                    height: 20

                    property real offsetX: width / 2
                    property real offsetY: width / 2

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = "#000"
                        ctx.lineWidth = 2;

                        ctx.beginPath();
                        ctx.moveTo(width / 2, 0);
                        ctx.lineTo(width / 2, height);
                        ctx.stroke();

                        ctx.beginPath();
                        ctx.moveTo(0, height / 2);
                        ctx.lineTo(width, height / 2);
                        ctx.stroke();
                    }

                    onXChanged: {
                        currentColor.saturation = (cursor.x + cursor.offsetX) / colorGradient.width
                    }

                    onYChanged: {
                        currentColor.value = 1.0 - (cursor.y + cursor.offsetY) / colorGradient.height
                    }
                }
            }

            Rectangle {
                id: hueSlider
                Layout.fillHeight: true
                Layout.minimumWidth: 10

                property real value

                onValueChanged: {
                    currentColor.hue = value
                }

                LinearGradient {
                    anchors.fill: parent
                    start: Qt.point(0, parent.height)
                    end: Qt.point(0, 0)
                    cached: true
                    gradient: Gradient {
                        GradientStop { position: 6 / 6; color: Qt.rgba(1, 0, 0, 1) }
                        GradientStop { position: 5 / 6; color: Qt.rgba(1, 1, 0, 1) }
                        GradientStop { position: 4 / 6; color: Qt.rgba(0, 1, 0, 1) }
                        GradientStop { position: 3 / 6; color: Qt.rgba(0, 1, 1, 1) }
                        GradientStop { position: 2 / 6; color: Qt.rgba(0, 0, 1, 1) }
                        GradientStop { position: 1 / 6; color: Qt.rgba(1, 0, 1, 1) }
                        GradientStop { position: 0 / 6; color: Qt.rgba(1, 0, 0, 1) }
                    }
                }

                Item {
                    x: hueSlider.width
                    y: clamp(hueSlider.value * hueSlider.height, 0, hueSlider.height) - height / 2
                    width: 10
                    height: 10

                    Canvas {
                        anchors.fill: parent
                        
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.beginPath()
                            ctx.moveTo(0, height / 2)
                            ctx.lineTo(width / 2, 0)
                            ctx.lineTo(width / 2, height)
                            ctx.lineTo(0, height / 2)
                            ctx.closePath()
                            ctx.fillStyle = "#fff"
                            ctx.fill()
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onPressed: {
                        hueSlider.value = mouse.y / hueSlider.height;
                    }

                    onPositionChanged: {
                        hueSlider.value = mouse.y / hueSlider.height;
                    }
                }
            }
        }

        RowLayout {
            RowLayout {
                spacing: 0

                Rectangle {
                    id: currentColor

                    Layout.fillWidth: true
                    Layout.minimumWidth: 50
                    Layout.maximumWidth: 100
                    Layout.minimumHeight: 25

                    property real hue
                    property real saturation
                    property real value

                    color: Qt.hsva(hue, saturation, value)
                }

                Rectangle {
                    id: previousColor

                    Layout.fillWidth: true
                    Layout.minimumWidth: 25
                    Layout.maximumWidth: 50
                    Layout.minimumHeight: 25

                    property real hue
                    property real saturation
                    property real value

                    color: Qt.hsva(hue, saturation, value)
                }
            }

            Item {
                Layout.fillWidth: true
            }
            
            SPTextInput  {
                id: colorTextInput
                Layout.preferredWidth: 75
                Layout.minimumHeight: 25
                color: "#999999"

                onTextChanged: {
                    text = text.replace(/[^#a-fA-F0-9]/g, "")
                    if (text.length > 0 && text[0] !== "#") {
                        text = "#" + text
                    }
                    if (text.length > 7) {
                        text = text.substring(0, 7)
                    }
                }

                onEditingFinished: {
                    if (text.length < 6) {
                        text = text.padStart(6, '0')
                    }
                    updateColor(text)
                }
            }
        }
    }
}