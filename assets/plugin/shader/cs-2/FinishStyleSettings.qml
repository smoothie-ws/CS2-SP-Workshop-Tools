import QtQuick 2.7
import QtQuick.Layouts 1.3
import Painter 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0


// finish style settings
AlgGroupWidget {
    text: "Gunsmith"
    activeScopeBorder : true

    AlgGroupWidget {
        id: fstyle_settings_color_group
        text: "Color"
    }

    AlgGroupWidget {
        id: fstyle_settings_texplace_group
        text: "Texture Placement"
    }

    AlgGroupWidget {
        id: fstyle_settings_effects_group
        text: "Effects"
    }

    AlgGroupWidget {
        id: fstyle_settings_advanced_group
        text: "Advanced"
    }
}
