import QtQuick 2.15
import QtQuick.Dialogs

FileDialog {
    id: root
    modality: Qt.ApplicationModal
    
    function show(path) {
        const initialFolder = Plugin.folderUrl(path || "", selectFolder);
        if (selectFolder) {
            folderDialog.currentFolder = initialFolder;
            folderDialog.open();
        } else {
            currentFolder = initialFolder;
            open();
        }
    }

    property alias fileUrl: root.selectedFile
    property bool selectFolder: false
    
    FolderDialog {
        id: folderDialog

        onAccepted: {
            root.fileUrl = selectedFolder;
            root.accepted();
        }
    }
}
