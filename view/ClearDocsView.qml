import QtQuick 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

SPDialog {
    confirm.text: "Continue"
    cancel.text: "Cancel"

    Text {
        color: AlgStyle.text.color.normal
        wrapMode: Text.WordWrap
        textFormat: Text.RichText
        lineHeight: 1.4
        text: "<p>You are about to remove all the files associated with the plugin.</p><p>Are you sure?</p>"
    }
}
