let canvas; // DOM object corresponding to the canvas
let graphics; // 2D graphics context for drawing to the canvas
let cH;
let cW;
const drawFrames = 8;
const drawEverySecond = 0.2;
let mouse_coord = {
  x: 0,
  y: 0,
};
const mouse_list = (mouse) => {
  return [mouse.x, mouse.y];
};
const mouse_queue = Array(drawFrames + 1).fill(mouse_list(mouse_coord));
let frames = 0;

const resizeCanvas = () => {
  const devicePixelRatio = window.devicePixelRatio;
  console.log(devicePixelRatio);
  cW = window.innerWidth / 2.0;
  cH = window.innerHeight / 2.0;
  canvas.width = cW * 2 * devicePixelRatio - 16;
  canvas.height = cH * 2 * devicePixelRatio - 16;
  graphics.scale(devicePixelRatio, devicePixelRatio);
};

const addClickListeners = () => {
  document.onmousemove = handleEvent;
};

const handleEvent = (e) => {
  mouse_coord.x = e.pageX - cW;
  mouse_coord.y = e.pageY - cH;
};

const drawShape = (center, coords, fill, stroke, lineWidth) => {
  if (coords.length < 2) return;
  graphics.save();
  if (fill) graphics.fillStyle = fill;
  if (stroke) graphics.strokeStyle = stroke;
  if (lineWidth) graphics.lineWidth = lineWidth;

  const c0 = center[0];
  const c1 = center[1];
  const start = coords[0];

  graphics.beginPath();
  graphics.moveTo(start[0] + c0 + cW, start[1] + c1 + cH);
  coords.forEach((coord, i) => {
    if (i == 0) return;
    graphics.lineTo(coord[0] + c0 + cW, coord[1] + c1 + cH);
  });
  graphics.closePath();
  graphics.fill();
  graphics.stroke();

  graphics.restore();
};

const roofColor = "#e34b4b";
const roof = [
  [0, -240],
  [-183, -88],
  [183, -88],
];
const wallColor = "#f1ebc9";
const wall = [
  [-140, -88],
  [-140, 88],
  [140, 88],
  [140, -88],
];
const doorColor = "#e34b4b";
const door = [
  [40, -45],
  [40, 88],
  [105, 88],
  [105, -45],
];
const windowsColor = "#daffff";
const windows = [
  [0, 0],
  [0, 53],
  [49, 53],
  [49, 0],
];
const doorKnobColor = "#ffff00";
const drawFront = (cx, cy) => {
  graphics.save();
  graphics.strokeStyle = "black";
  graphics.lineWidth = "5";

  drawShape([cx, cy], wall, wallColor, null, null);
  drawShape([cx, cy], roof, roofColor, null, null);
  drawShape([cx, cy], door, doorColor, null, null);
  drawShape([cx - 111, cy - 39], windows, windowsColor, null, null);
  drawShape([cx - 62, cy - 39], windows, windowsColor, null, null);

  graphics.save();
  graphics.fillStyle = "#ffff00";
  graphics.beginPath();
  graphics.arc(cx + 90 + cW, cy + 20 + cH, 6, 0, 2 * Math.PI);
  graphics.fill();
  graphics.stroke();
  graphics.restore();

  graphics.restore();
};

const drawShiftRect = (coords, fill, strokeOn, strokeSet) => {
  graphics.save();
  drawShape([0, 0], coords, fill, fill, "1");

  graphics.strokeStyle = strokeOn;
  graphics.lineWidth = "5";
  strokeSet.forEach((e, i) => {
    if (!e) return;
    const f = coords[i];
    const s = coords[(i + 1) % 4];
    graphics.beginPath();
    graphics.setLineDash([]);
    graphics.moveTo(f[0] + cW, f[1] + cH);
    graphics.lineTo(s[0] + cW, s[1] + cH);
    graphics.stroke();
  });

  graphics.restore();
};

const drawSideWall = (line, c1, c2, index, fillColor) => {
  const scale = 1.0 / (drawFrames + 2);
  const front = index + 3;
  const back = index + 2;
  const coords = [];
  coords.push(
    ...line.map((e) => [
      (e[0] + c1[0]) * scale * front,
      (e[1] + c1[1]) * scale * front,
    ])
  );
  coords.push(
    ...line
      .reverse()
      .map((e) => [
        (e[0] + c2[0]) * scale * back,
        (e[1] + c2[1]) * scale * back,
      ])
  );
  drawShiftRect(coords, fillColor, "black", [0, 1, index === 0, 1]);
};

const sideLineWall = [
  {
    coords: [
      [-140, -88],
      [-140, 88],
    ],
    color: wallColor,
  },
  {
    coords: [
      [140, -88],
      [140, 88],
    ],
    color: wallColor,
  },
];

const sideLineRoofUnder = {
  coords: [
    [-183, -88],
    [183, -88],
  ],
  color: roofColor,
};

const sideLineFloor = {
  coords: [
    [-140, 88],
    [140, 88],
  ],
  color: wallColor,
};

const sideLineRoof = [
  {
    coords: [
      [0, -240],
      [-183, -88],
    ],
    color: roofColor,
  },
  {
    coords: [
      [0, -240],
      [183, -88],
    ],
    color: roofColor,
  },
];

const lineOrderList = Array(4)
  .fill(0)
  .map((_, i) => {
    const x = i % 2;
    const y = (i >= 2) + 0;
    const array = y
      ? [
          sideLineRoof[!x + 0],
          sideLineRoof[x + 0],
          sideLineRoofUnder,
          sideLineWall[!x + 0],
          sideLineWall[x + 0],
        ]
      : [
          sideLineWall[!x + 0],
          sideLineWall[x + 0],
          sideLineRoofUnder,
          sideLineRoof[!x + 0],
          sideLineRoof[x + 0],
        ];
    return array;
  });
const lineOrder = (x, y, check) => {
  lines = lineOrderList[(x < 0) + 2 * (y < 88)];
  if (check || y < -88) lines.push(sideLineFloor);
  return lines;
};
const drawSide = (centers) => {
  graphics.save();

  const movedUp = centers.some(
    (_, i) => i !== centers.length - 1 && centers[i + 1][1] - centers[i][1] < 0
  );
  console.log(movedUp);
  for (let i = 0; i < drawFrames; i++) {
    const sideLines = lineOrder(...centers[i], movedUp);
    sideLines.forEach((sideLine) => {
      drawSideWall(
        sideLine.coords,
        centers[i + 1],
        centers[i],
        i,
        sideLine.color
      );
    });
  }
  graphics.restore();
};

// Drawing function
function draw() {
  mouse_queue.shift();
  mouse_queue.push(mouse_list(mouse_coord));

  graphics.clearRect(0, 0, canvas.width, canvas.height);
  graphics.fillStyle = "#000";
  graphics.strokeStyle = "black";
  graphics.lineWidth = "3";
  graphics.save();

  drawSide(mouse_queue);
  drawFront(mouse_coord.x, mouse_coord.y);

  graphics.restore();

  graphics.save();
  graphics.fillStyle = "#fff";
  graphics.strokeStyle = "black";
  graphics.lineWidth = "3";
  graphics.strokeRect(40, 75, cW * 2 - 90, 140);
  graphics.font = "20px serif";
  graphics.fillStyle = "#000";
  graphics.fillText("Gently move the mouse around.", 50, 100);
  graphics.fillText("If the screen glitches (due to PC spec), please", 50, 125);
  graphics.fillText("change `drawFrames` or `drawEverySecond`", 50, 150);
  graphics.fillText("in script to a lower value.", 50, 175);
  graphics.fillText(`cursor: ${mouse_coord.x}, ${mouse_coord.y}`, 50, 200);
  graphics.restore();
}

// Initialization function
function init() {
  canvas = document.getElementById("myCanvas");
  graphics = canvas.getContext("2d");
  resizeCanvas();
  window.addEventListener("resize", resizeCanvas);
  addClickListeners();
  draw(); // Draw onto the canvas
  const interval = setInterval(draw, drawEverySecond * 1000);
}
window.onload = init; // Runs when window is loaded
