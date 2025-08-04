#if QT_VERSION == 5
import QtQuick 2.15
RegExpValidator { 
    id: root
    property alias expr: root.regExpr
}
#else
import QtQuick
RegularExpressionValidator {
    id: root
    property alias expr: root.regularExpression
}
#endif
