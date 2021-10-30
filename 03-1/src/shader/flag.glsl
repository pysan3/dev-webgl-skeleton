#version 300 es
precision mediump float;
uniform vec2 u_resolution;
uniform float u_time;
in vec2 coord;
out vec4 color_out;
void main(){
    vec2 p = (2.0 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y;

    color_out = mix(
        vec4(vec3(0.0), 1.0),
        vec4(1.0, 0.0, 0.0, 1.0),
        exp(-length(p)*3.2)
    );
    color_out.rgb = mix( 1.055*pow(color_out.rgb,vec3(1.0/2.4))-0.055,
            color_out.rgb*12.92, step(color_out.rgb, vec3(0.0031308)));
}
