import QtQuick 2.15
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
#if QT_VERSION == 5
import QtGraphicalEffects 1.15
#endif
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

Item {
    id: root
    height: 32

    property string url: ""
    property string label: "Select texture"
    property string resourceName: ""
    property alias filters: resourcePicker.filters
    property alias hovered: mouseArea.containsMouse

    function isImageFile(path) {
        const ext = path.slice((path.lastIndexOf(".") || -1) + 1).toLowerCase();
        return ['jpg', 'jpeg', 'png', 'tga', 'bmp'].includes(ext);
    }

    onUrlChanged: {
        if (url !== "") {
            const info = JSON.parse(Plugin.js(`alg.resources.getResourceInfo("${url}")`));
            if (info !== null && isImageFile(info.filePath) && Plugin.pathExists(info.filePath)) {
                resourceName = info.name;
                preview.source = `file:///${info.filePath}`;
            } else 
                url = "";
            return;
        }
        resourceName = "";
        preview.source = "";
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

            layer.enabled: true

            property real shadeOffset: root.hovered ? 0.25 : 0.05
            property real scaleFactor: root.hovered ? 1.1 : 1.0

            Behavior on shadeOffset {
                NumberAnimation { 
                    duration: 250
                    easing.type: Easing.OutQuart
                }
            }

            #if QT_VERSION == 5
            layer.enabled: true
            layer.samples: 4
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: background.width
                    height: background.height
                    radius: background.radius - preview.anchors.margins
                }
            }
            #else

            #endif

            SPLinearGradient {
                anchors.fill: parent

                GradientStop { position: 0.0 + preview.shadeOffset; color: background.color }
                GradientStop { position: 1.0 + preview.shadeOffset; color: "transparent" }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: resourcePicker.show(parent.mapToGlobal(mouse.x, mouse.y))

            DropArea {
                id: dropArea
                anchors.fill: parent
                
                onDropped: {
                    var data = null;
                    if (drop.hasUrls)
                        data = drop.urls[0];
                    root.url = data;
                    drop.accept();
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 10

            SPButton {
                padding: 5
                implicitWidth: Math.min(20, parent.height)
                implicitHeight: implicitWidth
                icon.source: "./icons/close.png"
                icon.width: implicitWidth * 0.5
                icon.height: implicitHeight * 0.5
                tooltip.text: "Clear"
                background.color: "black"
                background.opacity: hovered ? 0.5 : 0.25

                onClicked: root.url = "";
            }

            Label {
                id: label
                antialiasing: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                text: root.resourceName == "" ? root.label : root.resourceName
                color: AlgStyle.text.color.normal
                opacity: root.hovered ? 1.0 : 0.75

                property alias scaleFactor: textScale.factor

                Behavior on color {
                    ColorAnimation { 
                        duration: 100
                        easing.type: Easing.OutQuart
                    }
                }

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
    }

    AlgResourcePicker {
        id: resourcePicker
        onResourceSelected: root.url = previewID
    }
}
