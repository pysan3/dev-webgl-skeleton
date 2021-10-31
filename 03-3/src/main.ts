import vertexShaderSource from './shader/vert.glsl'
import fragmentShaderSource from './shader/flag.glsl'

const cSize = {
    width: 400,
    height: 400,
} as const;
type cSize = typeof cSize[keyof typeof cSize];

const VERTEX_SIZE = 2;

const main = () => {
    const canvas = document.createElement('canvas');
    canvas.width = cSize.width;
    canvas.height = cSize.height;
    document.body.appendChild(canvas);

    const mayBeContext = canvas.getContext('webgl2') as WebGL2RenderingContext;
    if (mayBeContext === null) {
        console.warn('could not get context');
        return
    }
    const gl: WebGL2RenderingContext = mayBeContext;
    const vertexShader = gl.createShader(gl.VERTEX_SHADER);
    gl.shaderSource(vertexShader, vertexShaderSource);
    gl.compileShader(vertexShader);

    const vertexShaderCompileStatus = gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS);
    if (!vertexShaderCompileStatus) {
        const info = gl.getShaderInfoLog(vertexShader);
        console.warn(info);
        return
    }

    const fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
    gl.shaderSource(fragmentShader, fragmentShaderSource);
    gl.compileShader(fragmentShader);

    const fragmentShaderCompileStatus = gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS);
    if (!fragmentShaderCompileStatus) {
        const info = gl.getShaderInfoLog(fragmentShader);
        console.warn(info);
        return
    }

    const getAttribLocation = (program: WebGLProgram, name:string) => {
        var attributeLocation = gl.getAttribLocation(program, name);
        if (attributeLocation === -1) {
            throw "Cannot find attribute " + name + ".";
        }
        return attributeLocation;
    }

    const getUniformLocation = (program:WebGLProgram, name:string)  => {
        var attributeLocation = gl.getUniformLocation(program, name);
        if (attributeLocation === -1) {
            throw "Cannot find uniform " + name + ".";
        }
        return attributeLocation;
    }

    const program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);

    const linkStatus = gl.getProgramParameter(program, gl.LINK_STATUS);
    if (!linkStatus) {
        const info = gl.getProgramInfoLog(program);
        console.warn(info);
        return
    }
    gl.useProgram(program);

    // Clear screen
    gl.clearColor(0, 0, 0, 0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    /*
    2___3
    |\  |
    | \ |
    |__\|
    0   1
   */
    const vertexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
    const VERTEX_NUMS = 4;
    const vertices = new Float32Array([
        -1, -1,
        1, -1,
        -1, 1,
        1,  1
    ]);
    gl.bufferData(gl.ARRAY_BUFFER, vertices, gl.STATIC_DRAW);

    // Get and set vertex attribute
    const vertexAttribLocation = getAttribLocation(program, 'pos');
    gl.enableVertexAttribArray(vertexAttribLocation);
    gl.vertexAttribPointer(vertexAttribLocation, VERTEX_SIZE, gl.FLOAT, false, 0, 0);
    const resHandle = getUniformLocation(program, 'u_resolution');
    gl.uniform2f(resHandle, cSize.width, cSize.height);
    const timeHandle = getUniformLocation(program, 'u_time');

    const draw = (time: number) => {
        gl.uniform1f(timeHandle, time * 0.001)
        // Draw triangles
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, VERTEX_NUMS);

        gl.flush();
        requestAnimationFrame(draw)
    }

    draw(0)
}

window.onload = main;
