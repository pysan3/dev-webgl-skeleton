#version 300 es
precision mediump float;
precision mediump int;
uniform float u_time;
uniform int u_drawid;

in float depth;
out vec4 color_out;

void main(){
    if (u_drawid == 0) color_out = vec4(0.1, 0.1, 1.0 - depth * 3.0, 1.0);
    else color_out = vec4(vec3(1.0 - depth), 1.0);
}
