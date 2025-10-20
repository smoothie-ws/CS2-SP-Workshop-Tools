import QtQuick 2.12
import "./SPWidgets"

SPLock {
    property real scale
    property real rotation
    property real translationX
    property real translationY

    property var matrixForm0: [1.0, 0.0, 0.0, 0.0]
    property var matrixForm1: [0.0, 1.0, 0.0, 0.0]

    onScaleChanged: build()
    onRotationChanged: build()
    onTranslationXChanged: build()
    onTranslationYChanged: build()

    onMatrixForm0Changed: decompose()
    onMatrixForm1Changed: decompose()

    function build() {
        update(() => {
            const s = Math.floor((scale + 0.005) * 100) / 100;
            const r = (Math.floor((rotation + 0.005) * 100) / 100 * 3.1415927) / 180;
            const tx = Math.floor((translationX + 0.005) * 100) / 100;
            const ty = Math.floor((translationY + 0.005) * 100) / 100;

            const cos = Math.cos(r);
            const sin = Math.sin(r);

            const m = 0.5 / (s != 0.0 ? s : 1.0);
            const m0 = m  *  cos - m * -sin;
            const m1 = m0 * -sin + m *  cos;

            matrixForm0 = [cos * s, -sin * s, 0.0, s * cos * m0 + s * -sin * m1 + tx - 0.5];
            matrixForm1 = [sin * s,  cos * s, 0.0, s * sin * m0 + s *  cos * m1 + ty - 0.5];
        });
    }

    function decompose() {
        update(() => {
            const [m00, m01, , tx] = matrixForm0;
            const [m10, m11, , ty] = matrixForm1;

            const thA = Math.atan2(-m01, m00);
            const thB = Math.atan2( m10, m11);
            let d = thB - thA;
            while (d > 3.1415927) d -= 2 * 3.1415927;
            while (d < -3.1415927) d += 2 * 3.1415927;
            const t = thA + d * 0.5;

            const sU = Math.hypot(m00, m01);
            const sV = Math.hypot(m10, m11);
            const s = (sU + sV) * 0.5;

            const cos = Math.cos(t);
            const sin = Math.sin(t);
            const m = 0.5 / (s !== 0 ? s : 1);
            const m0 = m * cos - m * -sin;
            const m1 = m0 * -sin + m * cos;

            scale = Math.floor((s + 0.005) * 100) / 100;
            rotation = Math.floor(((t * 180) / 3.1415927 + 0.005) * 100) / 100;
            translationX = Math.floor((tx - s * cos * m0 + s * -sin * m1 + 0.5 + 0.005) * 100) / 100;
            translationY = Math.floor((ty - s * sin * m0 + s *  cos * m1 + 0.5 + 0.005) * 100) / 100;
        });
    }
}
