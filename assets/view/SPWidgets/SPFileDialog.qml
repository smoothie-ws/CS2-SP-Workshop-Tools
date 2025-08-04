import QtQuick 2.15
#if QT_VERSION == 5
import QtQuick.Dialogs 1.3
#else
import QtQuick.Dialogs
#endif

FileDialog {
    id: root
    modality: Qt.ApplicationModal
    
    enum Mode {
        OpenFile = 0,
        SaveFile = 1
    }

    property int mode: 0

    #if QT_VERSION >= 6
    property alias fileUrl: root.selectedFile
    property alias folder: root.currentFolder
    property bool selectFolder: false
    
    function show() {
        if (selectFolder)
            folderDialog.show();
        else
            open();
    }

    FolderDialog {
        id: folderDialog
        currentFolder: root.folder

        onAccepted: {
            root.fileUrl = selectedFolder;
            root.accepted();
        }

        function show() {
            selectedFolder = root.fileUrl;
            open();
        }
    }
    
    #endif
}
