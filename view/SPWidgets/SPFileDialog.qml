import QtQuick 2.15
import QtQuick.Dialogs 1.0

FileDialog {
    modality: Qt.ApplicationModal
    
    enum Mode {
        OpenFile = 0,
        SaveFile = 1
    }

    property int mode: 0
}