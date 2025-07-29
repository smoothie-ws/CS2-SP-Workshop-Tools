import QtQuick 2.15
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

RowLayout {
    id: root
    layoutDirection: Qt.RightToLeft
    
    signal resetRequested()

    SPButton {
        id: resetButton
        padding: 5
        implicitWidth: 30
        implicitHeight: implicitWidth
        icon.source: "./icons/cycle.png"
        icon.width: 15
        icon.height: 15
        tooltip.text: "Reset value"

        transform: Rotation { 
            origin.x: resetButton.width * 0.5
            origin.y: resetButton.height * 0.5 
            angle: 0

            NumberAnimation on angle {
                id: rotationAnimation
                duration: 250
                easing.type: Easing.OutQuad
            }
        }

        onPressed: {
            root.resetRequested();
            rotationAnimation.from = 0;
            rotationAnimation.to = 360;
            rotationAnimation.start();
        }
    }
}