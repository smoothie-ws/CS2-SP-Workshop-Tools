import QtQuick 2.15
import QtGraphicalEffects 1.15

SPControl {
    id: root

    property alias icon: icon
    property alias overlay: overlay

    Image {
        id: icon
        anchors.fill: parent
        mipmap: true
        fillMode: Image.PreserveAspectFit
    }
        
    ColorOverlay {
        id: overlay
        anchors.fill: icon
        source: icon
        opacity: 1.0
    }
}
