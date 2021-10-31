#version 300 es
uniform float u_time;
in vec4 pos;
out vec2 coord;
void main(){
    gl_Position = pos * 0.5;

    float c = cos(u_time); float s = sin(u_time);
    mat2 R = mat2( c, s, -s, c );
    coord = R * (pos.xy + s * vec2(0.4) + vec2(0.2 * cos(u_time), 0.3 * sin(u_time)));
}
