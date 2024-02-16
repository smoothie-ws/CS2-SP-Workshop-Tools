import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

ColumnLayout {
    property string label
    property int minValue
    property int maxValue
    property int firstValue
    property int secondValue

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
            id: minValueText
            text: firstValue
            // TODO
        }

        AlgTextInput {
            id: maxValueText
            text: secondValue
            // TODO
        }
    }

    RangeSlider {
        Layout.fillWidth: true
        id: slider
        from: minValue
        to: maxValue
        first.value: firstValue
        second.value: secondValue

        first.onValueChanged: {
            minValueText.text = parseFloat(second.value).toFixed(2);
        }
        
        second.onValueChanged: {
            maxValueText.text = parseFloat(second.value).toFixed(2);
        }
    }
}
