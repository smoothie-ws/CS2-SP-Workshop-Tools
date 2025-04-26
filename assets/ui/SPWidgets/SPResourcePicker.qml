import QtQuick 2.15
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.15
import AlgWidgets 2.0

Item {
    id: root
    height: 32
    width: 32

    property alias url: internal.url
    property alias label: internal.label
    property alias filters: resourcePicker.filters
    property alias hovered: mouseArea.hovered

    QtObject {
        id: internal

        property string url: ""
        property string label: "Select texture"
        property string resourceName: "None"

        onUrlChanged: {
            var imgPath = alg.resources.getResourceInfo(url).filePath;
            if (alg.fileIO.exists(imgPath)) {
                if (imgPath.endsWith('.jpg') | imgPath.endsWith('.jpeg') | imgPath.endsWith('.png'))
                    preview.source = 'file:///' + imgPath;
            } else
                preview.source = 'image://resources/' + url;
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#2d2d2d"
        radius: 10
        border.color: root.hovered ? "#378ef0" : Qt.rgba(0.5, 0.5, 0.5, 0.5)
        border.width: 1

        Behavior on border.color {
            ColorAnimation {
                duration: 250
                easing.type: Easing.OutQuart
            }
        }

        Image {
            id: preview
            anchors.fill: parent
            anchors.margins: 3
            fillMode: Image.PreserveAspectCrop

            property real shadeOffset: root.hovered ? 0.25 : 0.05
            property real scaleFactor: root.hovered ? 1.1 : 1.0

            Behavior on shadeOffset {
                NumberAnimation { 
                    duration: 250
                    easing.type: Easing.OutQuart
                }
            }

            layer.enabled: true
            layer.samples: 4
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: background.width
                    height: background.height
                    radius: background.radius - preview.anchors.margins
                }
            }

            LinearGradient {
                width: background.width
                height: background.height
                start: Qt.point(0, 0)
                end: Qt.point(background.width, 0)
                gradient: Gradient {
                    GradientStop { position: 0.0 + preview.shadeOffset; color: background.color }
                    GradientStop { position: 1.0 + preview.shadeOffset; color: "transparent" }
                }
            }
        }

        AlgLabel {
            id: label
            antialiasing: true
            x: 16
            y: background.height * 0.5 - height * 0.5
            text: internal.label
            color: root.hovered ? Qt.rgba(0.95, 0.95, 0.95, 1.0) : Qt.rgba(0.75, 0.75, 0.75, 1.0)

            Behavior on color {
                ColorAnimation { 
                    duration: 100
                    easing.type: Easing.OutQuart
                }
            }

            property alias scaleFactor: textScale.factor

            transform: Scale {
                id: textScale
                xScale: factor
                yScale: factor
                origin.x: label.x
                origin.y: label.height * 0.5

                property real factor: 1.0

                Behavior on factor {
                    NumberAnimation { 
                        duration: 100
                        easing.type: Easing.OutQuart
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        parent: background
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        property bool hovered: false

        onEntered: hovered = true
        onExited: hovered = false

        onClicked: resourcePicker.show(parent.mapToGlobal(mouse.x, mouse.y))

        DropArea {
            id: dropArea
            anchors.fill: parent

            onEntered: mouseArea.hovered = true
            onExited: mouseArea.hovered = false
            
            onDropped: {
                var data = null;
                if (drop.hasUrls)
                    data = drop.urls[0];
                internal.url = data;
                drop.accept();
            }
        }
    }

    AlgResourcePicker {
        id: resourcePicker

        onResourceSelected: {
            internal.url = previewID;
            internal.resourceName = name;
        }
    }

    ToolTip {
        id: tooltip
        visible: root.hovered
        opacity: visible ? 1.0 : 0.0
        text: root.url
        delay: 500

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        contentItem: Text {
            text: tooltip.text
            color: "#cfcfcf"
        }

        background: Rectangle {
            color: Qt.rgba(0.12, 0.12, 0.12)
            radius: 5
        }
    }
}
