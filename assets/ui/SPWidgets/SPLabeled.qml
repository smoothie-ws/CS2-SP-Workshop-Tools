import QtQuick 2.15
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import AlgWidgets 2.0

RowLayout {
    opacity: enabled ? 1.0 : 0.5
    
    property alias text: label.text
    property real scopeWidth: label.width
    
    onVisibleChanged: scale = visible

    Behavior on scale {
        NumberAnimation { 
            duration: 100
            easing.type: Easing.OutQuart
        }
    }

    AlgLabel { 
        id: label
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: scopeWidth
    }
}
