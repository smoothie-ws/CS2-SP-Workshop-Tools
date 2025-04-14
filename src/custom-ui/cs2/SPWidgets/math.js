function norm(x, xmin, xmax) {
    return (x - xmin) / (xmax - xmin);
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
