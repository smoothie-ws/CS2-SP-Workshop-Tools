import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0
import "shaderconnect.js" as Shader

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

    property int shader: 0

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

            Shader.connect(textureScale, "value", alg.shaders.parameter(shader, "u_tex_scale"));
        }

        ColumnLayout {
            id: mainLayout
            width: parent.width
            spacing: 15
            GridLayout {
                columns: 2
                columnSpacing: 15
                Layout.fillWidth: true

                AlgLabel {
                    text: "Finish style"
                }

                AlgComboBox {
                    id: styleBox
                    Layout.fillWidth: true
                    tooltip: "Select a finish style"
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

                AlgLabel {
                    text: "Weapon"
                }

                AlgComboBox {
                    id: weaponBox
                    Layout.fillWidth: true
                    tooltip: "Select a weapon"
                    model: [
                    { text: "AK-47", value: "ak47" },
                    { text: "AUG", value: "aug" },
                    { text: "AWP", value: "awp" },
                    { text: "CZ75-Auto", value: "cz75" },
                    { text: "Desert Eagle", value: "deagle" },
                    { text: "Dual Berettas", value: "duals" },
                    { text: "FAMAS", value: "famas" },
                    { text: "Five-SeveN", value: "fiveseven" },
                    { text: "G3SG1", value: "g3sg1" },
                    { text: "Galil AR", value: "galil" },
                    { text: "Glock-18", value: "g18" },
                    { text: "MAC-10", value: "mac10" },
                    { text: "MAG-7", value: "mag7" },
                    { text: "M4A1-S", value: "m4a1s" },
                    { text: "M4A4", value: "m4a4" },
                    { text: "MP5-SD", value: "mp5sd" },
                    { text: "MP7", value: "mp7" },
                    { text: "MP9", value: "mp9" },
                    { text: "Negev", value: "negev" },
                    { text: "Nova", value: "nova" },
                    { text: "P2000", value: "p2000" },
                    { text: "P250", value: "p250" },
                    { text: "P90", value: "p90" },
                    { text: "PP-Bizon", value: "bizon" },
                    { text: "R8 Revolver", value: "r8" },
                    { text: "SCAR-20", value: "scar20" },
                    { text: "SG 553", value: "sg553" },
                    { text: "SSG 08", value: "ssg08" },
                    { text: "Sawed-Off", value: "sawedoff" },
                    { text: "Tec-9", value: "tec9" },
                    { text: "UMP-45", value: "ump45" },
                    { text: "USP-S", value: "usps" },
                    { text: "XM1014", value: "xm1014" },
                    { text: "Zeus x27", value: "zeus" }
                    ]
                    textRole: "text"
                    currentIndex: 0
                    spacing: 15
                    onActivated: {
                        // TODO
                    }
                }

                AlgLabel {
                    text: "Map"
                }

                AlgResourceWidget {
                    Layout.fillWidth: true

                    filters: AlgResourcePicker.ENVIRONMENT
                    refineQuery: "u:cs2map "
                    defaultLabel: "Select a CS2 map"

                }
            }

            AlgSlider {
                id: uWear
                Layout.fillWidth: true
                Layout.fillHeight: true

                value: 0.0
                minValue: 0.0
                maxValue: 1.0
                text: "Wear"
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
                        id: textureScale
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

                        SPRangeSlider {
                            id: texRotation
                            Layout.fillWidth: true
                            label: "Texture Rotation"

                            minValue: -360.0
                            maxValue: 360.0
                            firstValue: 0.0
                            secondValue: 0.0
                            step: 1.0
                        }

                        SPRangeSlider {
                            id: texOffsetX
                            Layout.fillWidth: true
                            label: "Texture Offset X"

                            minValue: -1.0
                            maxValue: 1.0
                            firstValue: 0.0
                            secondValue: 0.0
                            step: 0.1
                        }

                        SPRangeSlider {
                            id: texOffsetY
                            Layout.fillWidth: true
                            label: "Texture Offset Y"

                            minValue: -1.0
                            maxValue: 1.0
                            firstValue: 0.0
                            secondValue: 0.0
                            step: 0.1
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
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10
                            Layout.alignment: Qt.AlignJustify
                            AlgLabel {
                                text: "Pearlescent Mask"
                            }

                            AlgComboBox {
                                id: pearlMaskSelector
                                Layout.fillWidth: true
                                tooltip: "Select a channel which will be used for export"
                                textRole: "text"
                            }
                        }

                        AlgCheckBox {
                            id: useRoughnessTex
                            text: "Use Roughness Texture"
                            onCheckedChanged: {
                                alg.log.warn("use roughness texture: " + checked)
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10
                            Layout.alignment: Qt.AlignJustify

                            AlgLabel {
                                text: "Roughness Texture"
                            }

                            AlgComboBox {
                                id: roughnessTexSelector
                                Layout.fillWidth: true
                                tooltip: "Select a channel which will be used for export"
                                textRole: "text"
                            }
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

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10
                            Layout.alignment: Qt.AlignJustify

                            AlgLabel {
                                text: "Normal Map"
                            }

                            AlgComboBox {
                                id: normalMapSelector
                                Layout.fillWidth: true
                                tooltip: "Select a channel which will be used for export"
                                textRole: "text"
                            }
                        }

                        AlgCheckBox {
                            id: useMaterialTex
                            text: "Use Custom Material Mask"
                            Layout.topMargin: 10

                            onCheckedChanged: {
                                alg.log.warn("use material mask: " + checked)
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10
                            Layout.alignment: Qt.AlignJustify

                            AlgLabel {
                                text: "Material Mask"
                            }

                            AlgComboBox {
                                id: matMaskSelector
                                Layout.fillWidth: true
                                tooltip: "Select a channel which will be used for export"
                                textRole: "text"
                            }
                        }

                        AlgCheckBox {
                            id: useAOTex
                            text: "Use Custom Ambient Occlusion"
                            Layout.topMargin: 10

                            onCheckedChanged: {
                                alg.log.warn("use ao: " + checked)
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 10
                            Layout.alignment: Qt.AlignJustify

                            AlgLabel {
                                text: "Ambient Occlusion"
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
    }
