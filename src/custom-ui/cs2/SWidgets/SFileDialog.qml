import QtQuick 2.7
import QtQuick.Dialogs 1.0

FileDialog {
    modality: Qt.ApplicationModal
    
    enum Mode {
        OpenFile = 0,
        SaveFile = 1
    }

    property int mode: 0
}