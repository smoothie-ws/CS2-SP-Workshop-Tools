import QtQuick 2.15
#if QT_VERSION == 5
import QtQuick.Dialogs 1.3
#else
import QtQuick.Dialogs
#endif

FileDialog {
    id: root
    modality: Qt.ApplicationModal
    
    function show(path) {
        let folder = "C:";
        if (path !== undefined && path !== null) {
            path = path.replace("\\", "/");
            folder = Qt.resolvedUrl(path.substring(0, path.lastIndexOf("/")));
        }
        #if QT_VERSION >= 6
        if (selectFolder) {
            folderDialog.currentFolder = folder;
            folderDialog.open();
        } else {
            currentFolder = folder;
            open();
        }
        #else
        open();
        #endif
    }

    #if QT_VERSION >= 6
    property alias fileUrl: root.selectedFile
    property bool selectFolder: false
    
    FolderDialog {
        id: folderDialog

        onAccepted: {
            root.fileUrl = selectedFolder;
            root.accepted();
        }
    }
    #endif
}
