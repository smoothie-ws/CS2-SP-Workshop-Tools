import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

ColumnLayout {
    property string label
    property real minValue
    property real maxValue
    property real firstValue
    property real secondValue
    property real step

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        AlgLabel {
            text: label
        }

        // kind of a spacer
        Item {
            Layout.fillWidth: true
        }

        AlgTextInput {
            Layout.preferredWidth: 50
            id: minValueText
            text: parseFloat(firstValue).toFixed(2)
            validator: RegExpValidator { regExp: /^-?[0-9]*\.?[0-9]*$/ }

            onActiveFocusChanged: {
                if (focus)
                {
                    selectAll()
                }
                else {
                    deselect()
                }
            }
            onEditingFinished: {
                firstValue = parseFloat(text)

            }
        }

        AlgTextInput {
            Layout.preferredWidth: 50
            id: maxValueText
            text: parseFloat(secondValue).toFixed(2)
            validator: RegExpValidator { regExp: /^-?[0-9]*\.?[0-9]*$/ }

            onActiveFocusChanged: {
                if (focus)
                {
                    selectAll()
                }
                else {
                    deselect()
                }
            }
            onEditingFinished: {
                secondValue = parseFloat(text)
            }
        }
    }

    RangeSlider {
        Layout.fillWidth: true
        id: slider
        from: minValue
        to: maxValue
        snapMode: RangeSlider.SnapAlways
        stepSize: step
        first.value: firstValue
        second.value: secondValue

        first.onValueChanged: {
            firstValue = first.value
        }

        second.onValueChanged: {
            secondValue = second.value
        }
    }
}
