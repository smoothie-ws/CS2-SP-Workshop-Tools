import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

ColumnLayout {
    id: root
    opacity: enabled ? 1.0 : 0.5
    spacing: 5
    property Component background: Rectangle {
        radius: 10
        clip: true
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.05) }
            GradientStop { position: 20 / height; color: Qt.rgba(1, 1, 1, 0.05) }
            GradientStop { position: 150 / height; color: Qt.rgba(0, 0, 0, 0) }
        }
    }

    Loader {
        width: root.width
        height: root.height
        sourceComponent: background 
    }

    default property alias children: __contentItem.children
    property alias activeScopeBorder: scopeLine.visible
    property alias toggled: groupButton.toggled
    property alias expandable: groupButton.visible
    property alias text: groupButton.text
    property alias tooltip: groupButton.tooltip
    property real padding: 5

    AlgToggleButton {
        id: groupButton
        toggled: true
        Layout.fillWidth: true
        Layout.margins: root.padding
        textAlignment: Text.AlignLeft
        __style: AlgStyle.widget.groupWidget
        iconName: checked ? AlgStyle.icons.groupwidget.expanded : AlgStyle.icons.groupwidget.collapsed
        iconSize: AlgStyle.widget.groupWidget.iconSize
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: root.padding
        Layout.topMargin: groupButton.visible ? 0 : root.padding
        visible: groupButton.toggled

        Item {
            id: scopeLine
            visible: true
            Layout.fillHeight: true
            Layout.preferredWidth: 15
        }

        ColumnLayout {
            id: __contentItem
            Layout.fillWidth: true

            Component.onCompleted: {
                var currentGroup = [];
                var maxSeparatorXForGroup = 0;

                for (var i = 0; i < __contentItem.children.length; ++i) {
                    var child = __contentItem.children[i];
                    child.Layout.fillWidth = true;

                    if (child.toString().indexOf("SPParameter") !== -1 && child.__separatorX !== 0) {
                        currentGroup.push(child);
                    } else if (currentGroup.length > 0) {
                        maxSeparatorXForGroup = 0;
                        for (var j = 0; j < currentGroup.length; ++j) {
                            var groupChild = currentGroup[j];
                            if (groupChild.__separatorX > maxSeparatorXForGroup) {
                                maxSeparatorXForGroup = groupChild.__separatorX;
                            }
                        }
                        for (var j = 0; j < currentGroup.length; ++j) {
                            var groupChild = currentGroup[j];
                            groupChild.__separatorX = maxSeparatorXForGroup;
                        }
                        currentGroup = [];
                    }
                }

                if (currentGroup.length > 0) {
                    maxSeparatorXForGroup = 0;
                    for (var j = 0; j < currentGroup.length; ++j) {
                        var groupChild = currentGroup[j];
                        if (groupChild.__separatorX > maxSeparatorXForGroup) {
                            maxSeparatorXForGroup = groupChild.__separatorX;
                        }
                    }
                    for (var j = 0; j < currentGroup.length; ++j) {
                        var groupChild = currentGroup[j];
                        groupChild.__separatorX = maxSeparatorXForGroup;
                    }
                }
            }
        }
    }
}