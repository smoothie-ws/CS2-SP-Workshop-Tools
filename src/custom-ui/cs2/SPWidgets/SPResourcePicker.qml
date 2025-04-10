import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.15
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "../utils.mjs" as Utils


Item {
    id: root
    height: 32
    width: 32

    property alias url: internal.url
    property alias label: internal.label
    property alias filters: resourcePicker.filters
    
    QtObject {
        id: internal

        property string url: ""
        property string label: "Select texture"
        property string resourceName: "None"
        property bool widgetHovered: false

        onWidgetHoveredChanged: {
            if (widgetHovered) {
                background.border.color = "#378ef0";
                widgetLabel.color = Qt.rgba(0.95, 0.95, 0.95, 1.0);
                widgetLabel.scaleFactor = 1.1;
                preview.shadeOffset = 0.25;
            } else {
                background.border.color = Qt.rgba(0.5, 0.5, 0.5, 0.5);
                widgetLabel.color = Qt.rgba(0.75, 0.75, 0.75, 1.0);
                widgetLabel.scaleFactor = 1.0;
                preview.shadeOffset = 0.05;
            }
        }

        onUrlChanged: {
            var imgPath = alg.resources.getResourceInfo(url).filePath;
            if (Utils.File.exists(imgPath)) {
                if (imgPath.endsWith('.jpg') | imgPath.endsWith('.jpeg') | imgPath.endsWith('.png')) {
                    preview.source = 'file:///' + imgPath;
                }
            } else {
                preview.source = 'image://resources/' +  url;
            }
        }
    }


    Rectangle {
        id: background
        anchors.fill: parent
        color: "#2d2d2d"
        radius: 10
        border.color: Qt.rgba(0.5, 0.5, 0.5, 0.5)
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

            property real shadeOffset: 0.1
            property real scaleFactor: 1.0

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

        Text {
            id: widgetLabel
            antialiasing: true
            x: 16
            y: background.height / 2 - height / 2
            text: internal.label
            color: Qt.rgba(0.75, 0.75, 0.75, 1.0)

            Behavior on color {
                ColorAnimation { 
                    duration: 100
                    easing.type: Easing.OutQuart
                }
            }

            property alias scaleFactor: textScale.factor

            transform: Scale {
                id: textScale
                origin.x: parent.x
                origin.y: parent.height / 2

                property real factor: 1

                Behavior on factor {
                    NumberAnimation { 
                        duration: 100
                        easing.type: Easing.OutQuart
                    }
                }

                xScale: factor
                yScale: factor
            }
        }
    }

    MouseArea {
        id: mouseArea
        parent: background
        anchors.fill: parent
        hoverEnabled: true

        onEntered: internal.widgetHovered = true
        onExited: internal.widgetHovered = false

        onClicked: {
            var screenPosition = parent.mapToGlobal(mouse.x, mouse.y);
            resourcePicker.show(screenPosition);
        }

        DropArea {
            id: dropArea
            anchors.fill: parent

            onEntered: internal.widgetHovered = true
            onExited: internal.widgetHovered = false
            
            onDropped: {
                var data = null;

                if (drop.hasUrls) {
                    data = drop.urls[0];
                }

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
}
