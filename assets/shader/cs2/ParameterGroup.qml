import AlgWidgets 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
import "SPWidgets"

AlgGroupWidget {
    property var parameters: []
    property int columnAmount: 2

    GridLayout {
        id: grid
        columns: columnAmount
        columnSpacing: 15
        rowSpacing: 10
        Layout.fillWidth: true

        Repeater {
            model: parameters

            Item {
                Loader {
                    parent: grid     
                    Layout.fillWidth: true

                    property string uniform: modelData.uniform
                    property var defaults: modelData.defaults
                    property var range: modelData.range
                    property var comboBoxModel: modelData.model

                    sourceComponent: {
                        switch(modelData.widget)
                        {
                            case "colorButton": return colorButton;
                            case "checkBox": return checkBox;
                            case "rangeSlider": return rangeSlider;
                            case "slider": return slider;
                            case "comboBox": return comboBox;
                            default: return checkBox;
                        } 
                    }
                }

                AlgLabel {
                    parent: grid
                    text: modelData.label
                }
            }
        }

        Component {
            id: checkBox
        
            RowLayout {
                AlgCheckBox {
                    id: control
                    Layout.fillWidth: true
                    checked: defaults
                    onCheckedChanged: {
                        shader_bridge.set_parameter_value(uniform, checked);
                    }
                }

                SPButton {
                    text: "Reset"
                    onClicked: {
                        control.checked = defaults;
                    }
                }
            }
        }

        Component {
            id: comboBox

            RowLayout {
                AlgComboBox {
                    id: control
                    Layout.fillWidth: true
                    textRole: "text"
                    spacing: 5
                    model: comboBoxModel

                    onCurrentIndexChanged: {
                        shader_bridge.set_parameter_value(uniform, currentIndex);
                    }
                }

                SPButton {
                    text: "Reset"
                    onClicked: {
                        control.currentIndex = defaults;
                    }
                }
            }
        }

        Component {
            id: colorButton

            RowLayout {
                SPColorButton {
                    id: control
                    Layout.fillWidth: true
                    color: defaults
                    onArrayColorChanged: {
                        shader_bridge.set_parameter_value(uniform, "[" + arrayColor + "]");
                    }
                }

                SPButton {
                    text: "Reset"
                    onClicked: {
                        control.color = defaults;
                    }
                }
            }
        }

        Component {
            id: rangeSlider

            RowLayout {
                SPRangeSlider {
                    id: control
                    Layout.fillWidth: true

                    minValue: range[0]
                    maxValue: range[1]
                    firstValue: defaults[0]
                    secondValue: defaults[1]
                    step: (maxValue - minValue) / 20
                }

                SPButton {
                    text: "Reset"
                    onClicked: {
                        control.firstValue = defaults[0];
                        control.secondValue = defaults[1];
                    }
                }
            }
        }

        Component {
            id: slider

            RowLayout {
                SPSlider {
                    id: control
                    Layout.fillWidth: true

                    minValue: range[0]
                    maxValue: range[1]
                    controlValue: defaults
                    step: (maxValue - minValue) / 20

                    onControlValueChanged: {
                        shader_bridge.set_parameter_value(uniform, controlValue);
                    }
                }

                SPButton {
                    text: "Reset"
                    onClicked: {
                        control.controlValue = defaults;
                    }
                }
            }
        }
    }   
}
