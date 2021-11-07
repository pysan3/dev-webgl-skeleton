#version 300 es
precision mediump float;
precision mediump int;
uniform float u_time;
uniform vec2 u_resolution;
uniform int u_drawid;

in vec4 a_position;
out float depth;

// Based on 'WebGL - A Beginners Guide'
mat4 xRotMat( in float deg ) {
	return mat4(	1.0,		0,			0,			0,
			 		0, 	cos(deg),	-sin(deg),		0,
					0, 	sin(deg),	 cos(deg),		0,
					0, 			0,			  0, 		1);
}
mat4 yRotMat( in float deg ) {
	return mat4(	cos(deg),		0,		sin(deg),	0,
			 				0,		1.0,			 0,	0,
					-sin(deg),	0,		cos(deg),	0,
							0, 		0,				0,	1);
}
mat4 zRotMat( in float deg ) {
	return mat4(	cos(deg),		-sin(deg),	0,	0,
			 		sin(deg),		cos(deg),		0,	0,
							0,				0,		1,	0,
							0,				0,		0,	1);
}

mat4 scaleMat(in float x, in float y, in float z) {
    mat4 diag = mat4(1.0);
    diag[0][0] = x; diag[1][1] = y; diag[2][2] = z;
    return diag;
}

mat4 translate(in vec3 t) {
    return mat4( 1.0, 0.0, 0.0, 0,
                  0.0, 1.0, 0.0, 0,
                  0.0, 0.0, 1.0, 0,
                  t.xyz, 1.0 );
}

mat4 projection(float l, float r, float b, float t, float n, float f) {
    mat4 m = mat4(
        2.0 / (r - l), 0.0, 0.0, -(r + l) / (r - l),
        0.0, 2.0 / (t - b), 0.0, -(t + b) / (t - b),
        0.0, 0.0, 2.0 / (f - n), -(f + n) / (f - n),
        0.0, 0.0, 0.0, 1.0
    );
    return m;
}


void main(){
    vec4 position = a_position;
    if (u_drawid == 0) { // ramiel
        // use some prime numbers to generate rotation that looks quite random. (yah, 57 is definitely a prime number)
        position = translate(vec3(0.1, 0.2, -1.0))
            * xRotMat(radians(u_time * 83.0))
            * yRotMat(radians(u_time * 107.0))
            * zRotMat(radians(u_time * 57.0))
            * position;
    } else { // floor
        position = translate(vec3(0.0, -1.0, -1.0))
            * position;
    }

    gl_Position = projection(-1.0, 1.0, -1.0, 1.0, -0.01, -10.0) * position;

    depth = gl_Position.z;
}

