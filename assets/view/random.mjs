const NTAB = 32;
const IA = 16807;
const IM = 2147483647;
const IQ = 127773;
const IR = 2836;
const NDIV = 1 + ((IM - 1) / NTAB) | 0;
const MAX_RANDOM_RANGE = 0x7FFFFFFF;
const AM = 1.0 / IM;
const EPS = 1.2e-7;
const RNMX = 1.0 - EPS;

export class Stream {
    constructor(seed = 1) {
        this.mIdum = 0;
        this.mIy = 0;
        this.mIv = new Array(NTAB).fill(0);

        this.mIdum = seed;
        if (seed >= 0)
            this.mIdum = -seed;
        this.mIy = 0;
    }

    generateRandomNumber() {
        let j, k;
        if (this.mIdum <= 0 || this.mIy === 0) {
            this.mIdum = -this.mIdum < 1 ? 1 : -this.mIdum;

            for (j = NTAB + 7; j >= 0; j--) {
                k = (this.mIdum / IQ) | 0;
                this.mIdum = IA * (this.mIdum - k * IQ) - IR * k;
                if (this.mIdum < 0) 
                    this.mIdum += IM;
                if (j < NTAB) 
                    this.mIv[j] = this.mIdum;
            }
            this.mIy = this.mIv[0];
        }

        k = (this.mIdum / IQ) | 0;
        this.mIdum = IA * (this.mIdum - k * IQ) - IR * k;
        if (this.mIdum < 0) 
            this.mIdum += IM;

        j = (this.mIy / NDIV) | 0;

        this.mIy = this.mIv[j];
        this.mIv[j] = this.mIdum;

        return this.mIy | 0;
    }

    randomFloat(flLow, flHigh) {
        let fl = AM * this.generateRandomNumber();
        if (fl > RNMX) 
            fl = RNMX;
        return fl * (flHigh - flLow) + flLow;
    }

    randomFloatExp(flMinVal, flMaxVal, flExponent) {
        let fl = AM * this.generateRandomNumber();
        if (fl > RNMX) fl = RNMX;
        if (flExponent !== 1.0)
            fl = Math.pow(fl, flExponent);
        return fl * (flMaxVal - flMinVal) + flMinVal;
    }

    randomInt(iLow, iHigh) {
        const x = (iHigh - iLow + 1) | 0;

        if (x <= 1 || MAX_RANDOM_RANGE < x - 1)
            return iLow | 0;

        const maxAcceptable = MAX_RANDOM_RANGE - ((MAX_RANDOM_RANGE + 1) % x);

        let n;
        for (;;) {
            n = this.generateRandomNumber();
            if (n <= maxAcceptable) 
                break;
        }

        return (iLow + (n % x)) | 0;
    }
}
