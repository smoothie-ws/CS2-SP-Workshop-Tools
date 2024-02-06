import QtQuick 2.7
import QtQuick.Layouts 1.3
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

Rectangle {
    id: root
    color: AlgStyle.background.color.mainWindow
    height: mainLayout.height + 100
    onHeightChanged: {
        if (height != mainLayout.height)
        {
            height = Qt.binding(function() { return mainLayout.height + 100});
        }
    }

    property var parameterGroups: []
    property var parameters: []

    function displayShaderParameters(shaderId)
    {
        parameterGroups = alg.shaders.groups(0);
        parameters = alg.shaders.parameters(0);

        // for (var i in parameters) {
        //     var parameter = parameters[i];
        //     var group = "group" in parameter.description? parameter.description.group : "";
        //     alg.log.info(group);
        // }

        for (var i in parameterGroups) {
            if (parameterGroups[i].startsWith("Weapon Finish/"))
            {
                var subgroups = parameterGroups[i].split("/");
                alg.log.info(subgroups[1]);
            }
        }
    }

    ColumnLayout {
        id: mainLayout
        width: parent.width
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            Layout.alignment: Qt.AlignJustify

            AlgLabel {
                text: "Finish style:"
            }

            AlgComboBox {
                id: f_style_box
                Layout.fillWidth: true
                tooltip: "Finish Style"
                model: [
                { text: "Anodized Airbrushed", value: 0 },
                { text: "Anodized Multicolored", value: 1 },
                { text: "Anodized", value: 2 },
                { text: "Custom Paint Job", value: 3 },
                { text: "Gunsmith", value: 4 },
                { text: "Hydrographic", value: 5 },
                { text: "Patina", value: 6 },
                { text: "Spray Paint", value: 7 }
                ]
                textRole: "text"
                currentIndex: 4 // gunsmith
                spacing: 5
                onActivated: {
                    fstyle_settings_group.text = model[index].text
                }
            }
        }

        finishStyleParameters {
            id: fstyle_settings_group
        }
    }
}
