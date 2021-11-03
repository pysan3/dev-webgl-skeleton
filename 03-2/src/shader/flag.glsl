#version 300 es
precision mediump float;
uniform vec2 u_resolution;
in vec2 coord;
out vec4 color_out;
void main(){
    vec4 red = vec4(1.0, 0.0, 0.0, 1.0);
    vec4 black = vec4(vec3(0.0), 1.0);

    if (abs(coord.x) < 0.5 && abs(coord.y) < 0.5) color_out = red;
    else color_out = black;
}
