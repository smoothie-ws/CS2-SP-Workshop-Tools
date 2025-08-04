import QtQuick 2.15

Rectangle {
    id: root

    default property alias stops: gradient.stops
    property alias orientation: gradient.orientation
    
    gradient: Gradient {
        id: gradient
        orientation: Gradient.Horizontal
    }
}
