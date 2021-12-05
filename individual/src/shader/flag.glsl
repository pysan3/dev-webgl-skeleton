#version 300 es
precision mediump float;
uniform vec2 u_resolution;
uniform float u_time;
out vec4 color_out;

float sdfTrapezoid(in vec2 p, in float r1, in float r2, float h) {
    vec2 a = vec2(r2, h);
    vec2 b = vec2(r2 - r1, 2.0 * h);
    p.x = abs(p.x);
    vec2 c = vec2(
        p.x - min(p.x, (p.y < 0.0) ? r1 : r2),
        abs(p.y) - h
    );
    vec2 d = p - a + b * clamp(dot(a - p, b) / dot(b, b), 0.0, 1.0);
    float s = (d.x < 0.0 && c.y < 0.0) ? -1.0 : 1.0;
    return s * sqrt(min(dot(c, c), dot(d, d)));
}

float sdf(vec2 p, float a, float b, float c) {
    return sdfTrapezoid(p, a, b, c);
}

float sdf_union(in float a, in float b) {
    return min(a, b);
}

float sdf_not(in float a, in float b) {
    return -min(-a, b);
}

float sdf_xor(in float a, in float b) {
    return max(a, b);
}

void main(){
    vec4 red = vec4(1.0, 0.0, 0.0, 1.0);
    vec4 black = vec4(vec3(0.0), 1.0);
    vec2 result = gl_FragCoord.xy / u_resolution.xy;

    if (result.x <= 0.0) color_out = red;
    else color_out = black;
    /* color_out = vec4(result, 0.0, 1.0); */
    color_out = red;
}
