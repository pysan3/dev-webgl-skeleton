import vertexShaderSource from './shader/vert.glsl'
import fragmentShaderSource from './shader/flag.glsl'

const cSize = {
    width: 400,
    height: 400,
} as const;
type cSize = typeof cSize[keyof typeof cSize];

const VERTEX_SIZE = 3;

const octa0Array = new Float32Array([
    0, 1, 0,
    0, 0, 1,
    1, 0, 0,
    0, -1, 0,
    0, 0, -1,
    -1, 0, 0,
])
const OCTA0_ARRAY_LENGTH = octa0Array.length
const octa1Array = new Float32Array([
    0, -1, 0,
    0, 0, 1,
    -1, 0, 0,
    0, 1, 0,
    0, 0, -1,
    1, 0, 0,
])
const OCTA1_ARRAY_LENGTH = octa1Array.length
const floorArray = new Float32Array([
    -0.8, 0, -0.8,
    -0.8, 0, 0.8,
    0.8, 0, -0.8,
    0.8, 0, 0.8
])
const FLOOR_ARRAY_LENGTH = floorArray.length

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

    const floorBuffer = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, floorBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, floorArray, gl.STATIC_DRAW)
    const octahedron0 = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, octahedron0)
    gl.bufferData(gl.ARRAY_BUFFER, octa0Array, gl.STATIC_DRAW)
    const octahedron1 = gl.createBuffer()
    gl.bindBuffer(gl.ARRAY_BUFFER, octahedron1)
    gl.bufferData(gl.ARRAY_BUFFER, octa1Array, gl.STATIC_DRAW)

    // Get and set vertex attribute
    const positionLocation = getAttribLocation(program, "a_position");
    gl.enableVertexAttribArray(positionLocation)
    const resLocation = getUniformLocation(program, 'u_resolution');
    gl.uniform2f(resLocation, cSize.width, cSize.height);
    const timeLocation = getUniformLocation(program, 'u_time');
    const drawIdLocation = getUniformLocation(program, 'u_drawid');


    const draw = (time: number) => {
        // Clear screen
        gl.clearColor(1,1,1,1);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
        gl.enable(gl.CULL_FACE)
        gl.enable(gl.DEPTH_TEST)

        gl.uniform1f(timeLocation, time * 0.001)

        // draw floor
        gl.uniform1i(drawIdLocation, 1)
        gl.bindBuffer(gl.ARRAY_BUFFER, floorBuffer)
        gl.vertexAttribPointer(positionLocation, VERTEX_SIZE, gl.FLOAT, false, 0, 0)
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, FLOOR_ARRAY_LENGTH / VERTEX_SIZE);

        // draw first half of octahedron
        gl.uniform1i(drawIdLocation, 0)
        gl.bindBuffer(gl.ARRAY_BUFFER, octahedron0)
        gl.vertexAttribPointer(positionLocation, VERTEX_SIZE, gl.FLOAT, false, 0, 0)
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, OCTA0_ARRAY_LENGTH / VERTEX_SIZE)

        // draw second half of octahedron
        gl.uniform1i(drawIdLocation, 0)
        gl.bindBuffer(gl.ARRAY_BUFFER, octahedron1)
        gl.vertexAttribPointer(positionLocation, VERTEX_SIZE, gl.FLOAT, false, 0, 0)
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, OCTA1_ARRAY_LENGTH / VERTEX_SIZE)

        gl.flush();
        requestAnimationFrame(draw)
    }

    draw(0)
}

window.onload = main;
