function norm(x, xmin, xmax) {
    const d = xmax - xmin;
    return d != 0.0 ? (x - xmin) / d : d;
}

function clamp(x, xmin, xmax) {
    return Math.max(xmin, Math.min(x, xmax));
}

function mapNorm(value, xmin, xmax) {
    return value * (xmax - xmin) + xmin;
}

function map(value, x0min, x0max, x1min, x1max) {
    return mapNorm(norm(value, x0min, x0max), x1min, x1max);
}

function random(seed) {
    const x = Math.sin(seed) * 10000;
    return x - Math.floor(x);
}
