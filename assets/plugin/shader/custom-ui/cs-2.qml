import QtQuick 2.7
import QtQuick.Layouts 1.3
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

Rectangle {
    id: root
    color: AlgStyle.background.color.mainWindow
    height: mainLayout.height
    onHeightChanged: {
        if (height != mainLayout.height) {
            height = Qt.binding(function() { return mainLayout.height });
        }
    }

    property var parameterGroups: []
    property var parameters: []

    Component.onCompleted: {
        parameterGroups = alg.shaders.groups(0);
        parameters = alg.shaders.parameters(0);

        // for (var i in parameters) {
        //     var parameter = parameters[i];
        //     var group = "group" in parameter.description? parameter.description.group : "";
        //     alg.log.info(group);
        // }

        for (var i in parameterGroups) {
        if (parameterGroups[i].startsWith("Weapon Finish/")) {
            var subgroups = parameterGroups[i].split("/");
            alg.log.info(subgroups[1]);
        }
    }

    }

    ColumnLayout {
        id: mainLayout
        width: parent.width
        spacing: AlgStyle.defaultSpacing

        AlgComboBox {
          id: finish_style
          width: parent.width
          tooltip: "Finish Style: "
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
        }
    }
}
