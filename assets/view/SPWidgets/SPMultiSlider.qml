import QtQuick 2.15
import QtQuick.Layouts 1.3

ColumnLayout {
    id: root
    
    required property string paramId
    required property string paramName
    
    property alias model: rep.model
    property alias array: internal.array
    
    SPLock { 
        id: internal

        property var array: []
        property var sliders: []
        
        onArrayChanged: update(() => {
            for (const slider of sliders)
                slider.value = array[sliders.indexOf(slider)];
        })
    }
    
    Repeater {
        id: rep
        model: []

        delegate: SPParameter {
            Layout.fillWidth: true

            SPSlider {
                id: slider
                text: `${root.paramName} - ${modelData}`
                from: 0.0
                to: 1.0

                onValueChanged: {
                    internal.update(() => {
                        array[index] = value;
                        root.arrayChanged();
                    })
                }
            }

            Component.onCompleted: {
                internal.sliders.splice(index, 0, slider);
                internal.array.splice(index, 0, slider.value);
            }

            onResetRequested: slider.value = JSON.parse(Plugin.getDefaultWeaponFinishParameter(root.paramId))
        }

        onItemRemoved: (i, _) => {
            sliders.splice(i, 1);
            array.splice(i, 1);
        }
    }
}
