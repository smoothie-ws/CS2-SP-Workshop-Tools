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
        if (height != mainLayout.height)
        {
            height = Qt.binding(function() { return mainLayout.height});
        }
    }

    property var parameterGroups: []
    property var parameters: []


    Component.onCompleted: {
        var textureSet = alg.texturesets.getActiveTextureSet();
        var channels = alg.mapexport.channelIdentifiers(textureSet);
        var channelModel = []

        commonParams.text = "Gunsmith";

        for (var i = 0; i < channels.length; i++) {
            channelModel.push({text: channels[i] + " channel", value: i});
        }

        baseTexSelector.model = channelModel;
        pearlMaskSelector.model = channelModel;
        roughnessTexSelector.model = channelModel;
        normalMapSelector.model = channelModel;
        matMaskSelector.model = channelModel;
        aoSelector.model = channelModel;
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
                    // styleParamsGroup.setFinishStyle(model[index].text)
                }
            }
        }

        AlgGroupWidget {
            id: commonParams
            activeScopeBorder: true

            ColumnLayout {
                RowLayout {
                    Layout.topMargin: 10
                    spacing: 15

                    AlgLabel {
                        Layout.fillHeight: true
                        text: "Base Texture"
                    }

                    AlgComboBox {
                        id: baseTexSelector
                        Layout.fillWidth: true
                        tooltip: "Select a channel which will be used for export"
                        textRole: "text"
                    }
                }

                AlgSlider {
                    value: 1.0
                    minValue: -10.0
                    maxValue: 10.0
                    text: "Texture Scale"
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                }

                AlgCheckBox {
                    text: "Ignore Weapon Size Scale"
                    Layout.fillWidth: true
                    Layout.topMargin: 10

                    onCheckedChanged: {
                        alg.log.warn("checked: " + checked)
                    }
                }
            }

            AlgGroupWidget {
                activeScopeBorder : true
                Layout.topMargin: 10
                text: "Color"

                GridLayout {
                    columns: 2
                    rows: 4
                    columnSpacing: 15
                    Layout.fillWidth: true

                    AlgLabel {
                        Layout.fillHeight: true
                        text: "Base Metal"
                    }
                    AlgColorButton {
                        id: colBaseMetal
                        Layout.fillWidth: true

                        arrayColor: [0.5, 0.5, 0.5]
                    }

                    AlgLabel {
                        Layout.fillHeight: true
                        text: "Patina Tint"
                    }
                    AlgColorButton {
                        id: colPatinaTint
                        Layout.fillWidth: true

                        arrayColor: [0.5, 0.5, 0.5]
                    }

                    AlgLabel {
                        Layout.fillHeight: true
                        text: "Patina Wear"
                    }
                    AlgColorButton {
                        id: colPatinaWear
                        Layout.fillWidth: true

                        arrayColor: [0.5, 0.5, 0.5]
                    }

                    AlgLabel {
                        Layout.fillHeight: true
                        text: "Grime"
                    }
                    AlgColorButton {
                        id: colGrime
                        Layout.fillWidth: true

                        arrayColor: [0.5, 0.5, 0.5]
                    }
                }
            }

            // TODO: change the sliders to double sliders
            AlgGroupWidget {
                activeScopeBorder : true
                Layout.topMargin: 10
                text: "Texture Placement"

                ColumnLayout {
                    Layout.fillWidth: true

                    AlgSlider {
                        id: texRotation
                        Layout.fillWidth: true

                        value: 0
                        minValue: -360.0
                        maxValue: 360.0
                        text: "Texture Rotation"
                    }

                    AlgSlider {
                        id: texOffsetX
                        Layout.fillWidth: true

                        value: 0.0
                        minValue: -1.0
                        maxValue: 1.0
                        text: "Texture Offset X"
                    }

                    AlgSlider {
                        id: texOffsetY
                        Layout.fillWidth: true

                        value: 0.0
                        minValue: -1.0
                        maxValue: 1.0
                        text: "Texture Offset Y"
                    }
                }
            }

            AlgGroupWidget {
                activeScopeBorder : true
                Layout.topMargin: 10
                text: "Effects"

                ColumnLayout {
                    Layout.fillWidth: true

                    AlgSlider {
                        id: wear
                        Layout.fillWidth: true

                        value: 0
                        minValue: 0.0
                        maxValue: 1.0
                        text: "Wear"
                    }

                    AlgSlider {
                        id: pearlScale
                        Layout.fillWidth: true

                        value: 0.0
                        minValue: -6.0
                        maxValue: 6.0
                        text: "Pearlescent Scale"
                    }

                    AlgCheckBox {
                        id: usePearlMask
                        text: "Use Pearlescent Mask"
                        onCheckedChanged: {
                            alg.log.warn("use pearlescent mask: " + checked)
                        }
                    }

                    AlgLabel {
                        text: "Pearlescent Mask:"
                    }

                    AlgComboBox {
                        id: pearlMaskSelector
                        Layout.fillWidth: true
                        tooltip: "Select a channel which will be used for export"
                        textRole: "text"
                    }

                    AlgCheckBox {
                        id: useRoughnessTex
                        text: "Use Pearlescent Mask"
                        onCheckedChanged: {
                            alg.log.warn("use pearlescent mask: " + checked)
                        }
                    }

                    AlgLabel {
                        text: "Roughness Texture:"
                    }

                    AlgComboBox {
                        id: roughnessTexSelector
                        Layout.fillWidth: true
                        tooltip: "Select a channel which will be used for export"
                        textRole: "text"
                    }
                }
            }

            AlgGroupWidget {
                activeScopeBorder : true
                Layout.topMargin: 10
                text: "Advanced"

                ColumnLayout {
                    Layout.fillWidth: true

                    AlgCheckBox {
                        id: useNormalMap
                        text: "Use Custom Normal Map"
                        onCheckedChanged: {
                            alg.log.warn("use: " + checked)
                        }
                    }

                    AlgLabel {
                        text: "Normal Map:"
                    }

                    AlgComboBox {
                        id: normalMapSelector
                        Layout.fillWidth: true
                        tooltip: "Select a channel which will be used for export"
                        textRole: "text"
                    }

                    AlgCheckBox {
                        id: useMaterialTex
                        text: "Use Custom Material Mask"
                        onCheckedChanged: {
                            alg.log.warn("use material mask: " + checked)
                        }
                    }

                    AlgLabel {
                        text: "Material Mask:"
                    }

                    AlgComboBox {
                        id: matMaskSelector
                        Layout.fillWidth: true
                        tooltip: "Select a channel which will be used for export"
                        textRole: "text"
                    }

                    AlgCheckBox {
                        id: useAOTex
                        text: "Use Custom Ambient Occlusion"
                        onCheckedChanged: {
                            alg.log.warn("use ao: " + checked)
                        }
                    }

                    AlgLabel {
                        text: "Ambient Occlusion:"
                    }

                    AlgComboBox {
                        id: aoSelector
                        Layout.fillWidth: true
                        tooltip: "Select a channel which will be used for export"
                        textRole: "text"
                    }
                }
            }
        }
    }
}
