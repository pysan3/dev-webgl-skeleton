#version 300 es

// credit: takuto
// orchid: Phalaenopsis

#define PI 3.14159265358979323846
#define TAU (2.0*PI)

precision mediump float;
uniform vec2 u_resolution;
uniform float u_time;
out vec4 color_out;

vec3 olive = vec3(0.482, 0.5, 0.29);
vec3 red = vec3(0.952, 0.227, 0.152);
vec3 orange = vec3(1.0, 1.0, 0.2);
vec3 yellow = vec3(0.956, 0.898, 0.247);
vec3 black = vec3(0.0);
vec3 white = vec3(1.0);
vec3 gray = vec3(0.147);
vec3 pink = vec3(1.0, 0.69, 0.66);
vec3 green = vec3(0.20, 0.52, 0.13);

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
  _st =  rotate2dm(_angle) * _st;
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

float cW = 2.0;
float cH = 1.5;

float bool2sign(int x) {
  /* if (x == 0) return 1.0; */
  /* else return -1.0; */
  /* return 1.0; */
  return float(-1 * x + (1 - x));
}

float modfloat(float x, float a) {
  return x - floor(x / a) * a;
}

vec4 drawOrchid(vec3 bg_color) {
  float smoothness = 0.05;

  vec2 st = gl_FragCoord.xy / u_resolution.xy * 2.0 - 1.0;
  st.x *= u_resolution.x / u_resolution.y;

  float x = st.x + 0.5 * u_time;
  float y = st.y + 0.3 * u_time;
  x = bool2sign(int((x + cW / 2.0) / cW) % 2) * (modfloat(x + cW / 2.0, cW) - cW / 2.0);
  y = bool2sign(int((y + cH / 2.0) / cH) % 2) * (modfloat(y + cH / 2.0, cH) - cH / 2.0);
  st.xy = vec2(x, y);

  st = rotate2D(st,TAU*u_time*0.15);
  // Orchid parameters. The orchid is composed by sepals, petals, lip and column

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
  vec3 sepalsColor = mix(yellow, white, rand(st));
  vec3 orcColor = mix(sepalsColor, bg_color, sepals);

  // Lip color:
  // 1) create the space coord for the dots
  vec2 lipSt = st;
  lipSt = fract(lipSt *= 20.0);
  lipSt -= vec2(0.5,0.5);
  // 2 create the color dots
  float dots = circleDist(lipSt, 0.1);
  dots = smoothstep(dots, dots+0.05, 0.2);
  vec3 colorPoints = mix(green, white, dots);
  // 3 mix the color with the orchid
  lip = fillSmooth(lip,0.09,smoothness+0.005);
  orcColor = mix(colorPoints, orcColor, lip);

  // Petals color
  latPetals = fillSmooth(latPetals,0.09,smoothness+0.005);
  vec3 latPetalsColor = mix(yellow, red, sin(angle * 40.0));
  latPetalsColor = mix(latPetalsColor, red, abs(st.x)*2.7);
  orcColor = mix(latPetalsColor,orcColor,latPetals);

  // column color
  column = fillSmooth(column,0.01,0.02);
  vec3 columnColor = orange - red * (st.y *2.0);
  orcColor = mix(columnColor, orcColor, column);

  return vec4(vec3(orcColor),1.0);
}

#define fs(i) (fract(sin((i)*114.514)*1919.810))
#define lofi(i,j) (floor((i)/(j))*(j))

float seed;

mat2 r2d(float t) {
  return mat2(cos(t),sin(t),-sin(t),cos(t));
}

mat3 orthBas(vec3 z) {
  z = normalize(z);
  vec3 up = abs(z.y)>0.999?vec3(0,0,1):vec3(0,1,0);
  vec3 x = normalize(cross(up,z));
  return mat3(x,cross(z,x),z);
}

float random() {
  seed++;
  return fs(seed);
}

vec3 uniformLambert(vec3 n) {
  float p = TAU*random();
  float cost = sqrt(random());
  float sint = sqrt(1.0-cost*cost);
  return orthBas(n)*vec3(cos(p)*sint,sin(p)*sint,cost);
}

vec4 tbox(vec3 ro,vec3 rd,vec3 s) {
  vec3 or = ro/rd;
  vec3 pl = abs(s/rd);
  vec3 f = -or-pl;
  vec3 b = -or+pl;
  float fl = max(f.x,max(f.y,f.z));
  float bl = min(b.x,min(b.y,b.z));
  if (bl<fl||fl<0.0) return vec4(1E2);
  vec3 n = -sign(rd)*step(f.yzx,f.xyz)*step(f.zxy,f.xyz);
  return vec4(n,fl);
}

struct QTR {
  vec3 cell;
  vec3 pos;
  float len;
  float size;
  bool hole;
};

bool isHole(vec3 p) {
  if (abs(p.x)<0.5&&abs(p.y)<0.5) return true;
  float dice = fs(dot(p,vec3(-2.0,-5.0,7.0)));
  if (dice<0.3) return true;
  return false;
}

QTR qt(vec3 ro,vec3 rd){
  vec3 haha = lofi(ro+rd*1E-2,0.5);
  float ha = fs(dot(haha,vec3(6.0,2.0,0.0)));
  ha = smoothstep(-0.2,0.2,sin(0.5*u_time+TAU*(ha-0.5)));

  ro.z += ha;

  QTR r;
  r.size = 1.0;
  for (int i= 0; i<4; i++) {
    r.size /= 2.0;
    r.cell = lofi(ro+rd*1E-2*r.size,r.size)+r.size/2.0;
    if(isHole(r.cell)) break;
    float dice = fs(dot(r.cell,vec3(5.0,6.0,7.0)));
    if(dice>r.size) break;
  }

  vec3 or = (ro-r.cell)/rd;
  vec3 pl = abs(r.size/2./rd);
  vec3 b = -or+pl;
  r.len = min(b.x,min(b.y,b.z));

  r.pos = r.cell-vec3(0.0,0.0,ha);
  r.hole = isHole(r.cell);

  return r;
}

vec4 drawBackground() {
  vec2 uv = gl_FragCoord.xy/u_resolution.xy;
  vec2 p = uv*2.0-1.0;
  p.x *= u_resolution.x/u_resolution.y;

  /* seed = texture(iChannel0,p).x; */
  seed = fract(u_time);

  float haha = u_time*62.0/60.0;
  float haha2 = floor(haha)-.2*exp(-fract(haha));

  p = r2d(u_time*0.2+0.2*floor(haha))*p;

  vec3 ro0 = vec3(0.0,0.0,1.0);
  ro0.z -= haha2;
  ro0 += 0.02*vec3(sin(u_time*1.36),sin(u_time*1.78),0.0);

  vec3 rd0 = normalize(vec3(p,-1.0));

  vec3 ro = ro0;
  vec3 rd = rd0;
  vec3 fp = ro+rd*2.0;
  ro += vec3(0.04*vec2(random(),random())*mat2(1.0,1.0,-1.0,1.0),0.0);
  rd = normalize(fp-ro);

  float rl = 0.01;
  vec3 rp = ro+rd*rl;

  vec3 col = vec3(0.0);
  vec3 colRem = vec3(1.0);
  float samples = 1.0;

  for (int i= 0; i<200; i++) {
    QTR qtr = qt(rp,rd);

    vec4 isect;
    if (qtr.hole) {
      isect = vec4(1E2);
    } else {
      float size = qtr.size*0.5;
      size -= 0.01;
      size -= 0.02*(0.5+0.5*sin(5.0*u_time+15.0*qtr.cell.z));
      isect = tbox(rp-qtr.pos,rd,vec3(size));
    }

    if (isect.w<1E2) {
      float fog = exp(-.2*rl);
      colRem *= fog;

      rl += isect.w;
      rp = ro+rd*rl;

      vec3 mtl = fs(cross(qtr.cell,vec3(4.0,8.0,1.0)));

      vec3 n = isect.xyz;

      if (mtl.x<0.1) {
        col += colRem*vec3(10.0,1.0,1.0);
        colRem *= 0.0;
      } else if (mtl.x<0.2) {
        col += colRem*vec3(6.0,8.0,11.0);
        colRem *= 0.0;
      } else {
        colRem *= 0.3;
      }

      ro = ro+rd*rl;
      rd = mix(uniformLambert(n),reflect(rd,n),pow(random(),0.3));
      rl = 0.01;
    } else {
      rl += qtr.len;
      rp = ro+rd*rl;
    }

    if (colRem.x<0.01) {
      ro = ro0;
      rd = rd0;
      vec3 fp = ro+rd*2.0;
      ro += vec3(0.04*vec2(random(),random())*mat2(1.0,1.0,-1.0,1.0),0.0);
      rd = normalize(fp-ro);
      rl = 0.01;
      rp = ro+rd*rl;
      colRem = vec3(1.0);
      samples++;
    }
  }

  col = pow(col/samples,vec3(0.4545));
  col *= 1.0-0.4*length(p);
  col = vec3(
      smoothstep(0.1,0.9,col.x),
      smoothstep(0.0,1.0,col.y),
      smoothstep(-0.1,1.1,col.z)
      );

  vec4 prev = vec4(0.0);
  return mix(vec4(col,1.0),prev,0.5*prev.w);
}

void main() {
  vec4 bg_color = drawBackground();
  /* vec4 bg_color = vec4(black, 1.0); */
  color_out = drawOrchid(bg_color.xyz);
}

