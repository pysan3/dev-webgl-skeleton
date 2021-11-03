#version 300 es
in vec4 pos;
out vec2 coord;

void main(){
    coord=pos.xy*.5+.5;
    gl_Position=pos;
}
