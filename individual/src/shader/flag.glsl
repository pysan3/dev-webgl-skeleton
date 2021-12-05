#version 300 es

#define PI 3.14159265358979323846
#define TAU 6.28318530718

precision mediump float;
uniform vec2 u_resolution;
uniform float u_time;
out vec4 color_out;

float merge(float d1, float d2){
  return min(d1, d2);
}

float smoothMerge(float d1, float d2, float k){
  float h = clamp(0.5 + 0.5*(d2 - d1)/k, 0.0, 1.0);
  return mix(d2, d1, h) - k * h * (1.0-h);
}

float substract(float d1, float d2){
  return max(-d1, d2);
}

float ellipseDist(vec2 p, float radius, vec2 dim){
  vec2 pos = p;
  pos.x = p.x / dim.x;
  pos.y = p.y / dim.y;
  return length(pos) - radius;
}

float circleDist(vec2 p, float radius){
  return length(p) - radius;
}

mat2 rotate2dm(float _angle){
  return mat2(cos(_angle),-sin(_angle), sin(_angle),cos(_angle));
}


vec2 rotate2D (vec2 _st, float _angle) {
  _st -= 0.5;
  _st =  rotate2dm(_angle) * _st;
  _st += 0.5;
  return _st;
}

float when_eq(float x, float y) {
  return 1.0 - abs(sign(x - y));
}

float orcSepals(vec2 toCenter, float resize, float defX, float defY, float grow, float nPetals, float smoothness){
  float angle = atan(toCenter.y,toCenter.x) + 0.5;
  float deformOnY = toCenter.y * defY;
  float deformOnX = abs(toCenter.x) * defX;
  float radius = length(toCenter)*resize * (grow+deformOnY+deformOnX);

  float f = cos(angle*nPetals);
  return smoothstep(f, f+smoothness,radius);
}

float lip(vec2 pos, vec2 oval, vec2 ovalSub,float radius, float offset){
  float A = ellipseDist(pos, radius, oval);
  vec2 posB = pos;
  posB.y += offset;
  float B = ellipseDist(posB, radius, ovalSub);
  float p = smoothMerge(B, A, 0.5);
  return p;
}

float orcColumn(vec2 pos, vec2 oval, vec2 ovalSub,float radius, float offset){
  float A = ellipseDist(pos, radius, ovalSub);
  vec2 posB = pos;
  posB.y -= offset;
  float B = ellipseDist(posB, radius, oval);
  float p = substract(B,A);
  posB.y += 0.035;
  float cone = ellipseDist(posB, radius, vec2(0.055, 0.30));
  p = smoothMerge(cone,p, 0.4);
  float s = ellipseDist(posB, radius, vec2(0.2, 0.20));
  return p;
}

float fillSmooth(float sdfVal, float size, float smoothness){
  return smoothstep(size, size+smoothness,sdfVal);
}

float rand(vec2 uv){
  return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 drawOrchid() {
  // General parameters
  float smoothness = 0.03;
  vec3 olive = vec3(0.482, 0.5, 0.29);
  vec3 red = vec3(0.952, 0.227, 0.152);
  vec3 orange = vec3(0.843, 0.615, 0.184);
  vec3 yellow = vec3(0.956, 0.898, 0.247);
  vec3 black = vec3(0.0);

  // Tiling
  vec2 st = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
  st.x *= u_resolution.x / u_resolution.y;

  /* st = rotate2D(st,-PI*u_time*0.15); */

  // Background
  vec3 bgCol = black;

  // Orchid parameters. The orchid is composed by sepals, petals, lip and column
  /* st += vec2(-0.5, -0.5); */
  //column parameters
  float colResize = 0.45;
  vec2 posCol = st;
  posCol.y += 0.035;
  float colYoffset = -0.051;
  float powerCol = 2.0;
  vec2 colRatio = vec2(0.7*colResize, 0.7*colResize);
  vec2 colSubRatio = vec2(0.9*colResize, 0.9*colResize);
  float colRadius = 0.52*colResize;
  // sepals parameters
  float addSmoothnessToSetals = 2.9;
  float deformX = 0.0;
  float deformY = 0.0;
  float resizePetals = 11.9;
  float powerSepals = 2.0;
  float nPetals = 3.0;
  float growSepals = exp2(length(st)) * 0.19;
  float nPetalsLat = 2.0;
  float deformXLat = 0.0;
  float deformYLat = -0.0;
  float resizePetalsLat = 21.9;
  float powerLat = 2.3;
  vec2 latPos = st*rotate2dm(TAU/2.4);
  float growLaterals = pow(length(st), powerLat);
  // lip parameter
  vec2 posLip = st;
  posLip.y += 0.18;
  float lipResize = 0.6;
  float lipYoffset = 0.05;
  vec2 lipRatio = vec2(0.19*lipResize, 0.45*lipResize);
  vec2 smallLipRatio = vec2(0.3*lipResize, 0.15*lipResize);
  float lipRadius = 1.0*lipResize;

  float column = orcColumn(posCol*rotate2dm(TAU/2.0),
      colRatio,
      colSubRatio,
      colRadius, colYoffset);
  float sepals = orcSepals(st,
      resizePetals,
      deformX,
      deformY, growSepals, nPetals,
      smoothness+addSmoothnessToSetals);
  float latPetals = orcSepals(latPos,
      resizePetalsLat,
      deformXLat,
      deformYLat, growLaterals, nPetalsLat,
      smoothness+addSmoothnessToSetals);
  float lip = lip(posLip,
      lipRatio,
      smallLipRatio,
      lipRadius, lipYoffset);

  float orchids = merge(latPetals, sepals);
  orchids = merge(orchids, lip);
  orchids = substract(column, orchids);
  // this angle is using while creating the colors
  float angle = atan(st.y,st.x) + 0.5;

  // Sepals color:
  sepals = fillSmooth(sepals,0.09,smoothness+0.005);
  vec3 sepalsColor = mix(yellow, olive, rand(st));
  vec3 orcColor = mix(sepalsColor, bgCol, sepals);

  // Lip color:
  // 1) create the space coord for the points
  vec2 lipSt = st;
  lipSt = fract(lipSt *= 20.0);
  lipSt -= vec2(0.5,0.5);
  // 2 create the color points
  float points = circleDist(lipSt, 0.1);
  points = smoothstep(points, points+0.05, 0.2);
  vec3 colorPoints = mix(orange, olive, points);
  // 3 mix the color with the orchid
  lip = fillSmooth(lip,0.09,smoothness+0.005);
  orcColor = mix(colorPoints, orcColor, lip);

  // Petals color
  latPetals = fillSmooth(latPetals,0.09,smoothness+0.005);
  vec3 latPetalsColor = mix(yellow,red, sin(angle * 40.0));
  latPetalsColor = mix(latPetalsColor, red, abs(st.x)*2.7);
  orcColor = mix(latPetalsColor,orcColor,latPetals);

  //column color
  column = fillSmooth(column,0.01,0.02);
  vec3 columnColor = orange - red * (st.y *2.0);
  orcColor = mix(columnColor, orcColor, column);

  return vec4(vec3(orcColor),1.0);
}

void main(){
  color_out = drawOrchid();
}
