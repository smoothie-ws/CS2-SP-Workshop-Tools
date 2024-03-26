import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "SPWidgets"

ScrollView {
    id: root
    clip: true
    visible: true
    anchors.fill: parent
    padding: 10
    ScrollBar.vertical.policy: root.contentHeight > root.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    ScrollBar.horizontal.policy: root.contentWidth > root.width ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

    background: Rectangle {
            anchors.fill: parent
            color: AlgStyle.background.color.mainWindow
        }

}
