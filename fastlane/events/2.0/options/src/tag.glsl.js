// Cutling's tag, shared by every studio scene: the black top tag from the app icon with three lines of
// text as white inlays and the 2.0 pills in their pockets. Tag space: x along the lines, z down the page,
// y = 0 on the tag's face. Lengths are centimetres; the tag is 20 x 13.2.
// Names printed on pills. tagInk(names) draws them, one row each, into the canvas the tracer hands to the
// scene as TEX, and returns each name's width in centimetres so a scene can size its pill to its name.
// A row is 6.4 x 1.6 cm at 320 px a centimetre.
window.tagInk = (names) => {
  const cv = document.createElement("canvas"); cv.width = 2048; cv.height = 512 * names.length;
  const g = cv.getContext("2d"); g.fillStyle = "#000"; g.fillRect(0, 0, cv.width, cv.height);
  g.fillStyle = "#fff"; g.font = '600 344px system-ui, -apple-system, "Helvetica Neue", sans-serif'; g.textAlign = "center"; g.textBaseline = "alphabetic";
  window.SCENE_TEX = cv;
  return names.map((n, i) => { g.fillText(n, 1024, 512 * i + 256 + 124); return g.measureText(n).width / 320; });
};
window.TAG_GLSL = `
const vec2 HS = vec2(10., 6.6);      // half the tag
const vec2 PIV = vec2(-7.7, -4.3);   // the eyelet, from the tag's middle
const float PR = .82;                // a pill's half height on the page
const float Z1 = -1.0, Z2 = 1.8, Z3 = 4.55;   // the three lines
const vec2 SLOT = vec2(.9, 6.7);     // the pill on the first line, from x to x

float sdRR(vec2 p, vec2 b, float r){ vec2 q = abs(p) - b + r; return length(max(q, 0.)) + min(max(q.x, q.y), 0.) - r; }
// a flat shape d2 made h thick each way from y = 0, its edges rounded by r
float ext(float d2, float y, float h, float r){ vec2 w = vec2(d2 + r, abs(y) - h + r); return min(max(w.x, w.y), 0.) + length(max(w, 0.)) - r; }
float lozenge(vec2 p, float l){ p.x -= clamp(p.x, -l, l); return length(p); }   // a line with round ends; the caller takes the radius off
float tagOutline(vec2 q){ return sdRR(q, HS, 1.9); }

float bar(vec3 p, float x0, float x1, float z){
  return ext(sdRR(p.xz - vec2(.5 * (x0 + x1), z), vec2(.5 * (x1 - x0), .42), .42), p.y, .07, .05); }
float pill2(vec2 p, float x0, float x1, float z){ return lozenge(p - vec2(.5 * (x0 + x1), z), .5 * (x1 - x0) - PR) - PR; }
float pill(vec3 p, float x0, float x1, float z){ return ext(pill2(p.xz, x0, x1, z), p.y - .2, .42, .4); }
float tagBars(vec3 p){
  // the second line stops short, as a paragraph's last line does, so nothing lies behind the first line's pill
  float d = bar(p, -8.1, -5.2, Z1);
  d = min(d, bar(p, -4.3, -.1, Z1));
  d = min(d, bar(p, -2.9, .1, Z2));
  d = min(d, bar(p, -8.1, -2.4, Z3));
  d = min(d, bar(p, 3.5, 5.6, Z3));
  return d; }
// the two pills that are always in; the first line's pill is the caller's (seated, or still in the air)
float tagPills(vec3 p){ return min(pill(p, -8.1, -3.9, Z2), pill(p, -1.4, 2.5, Z3)); }
float tagSlotPill(vec3 p){ return pill(p, SLOT.x, SLOT.y, Z1); }
float tagSlab(vec3 p){
  float d = ext(tagOutline(p.xz), p.y + .25, .25, .07);
  d = max(d, -(length(p.xz - PIV) - .62));
  float k = min(pill2(p.xz, SLOT.x, SLOT.y, Z1), min(pill2(p.xz, -8.1, -3.9, Z2), pill2(p.xz, -1.4, 2.5, Z3))) - .07;
  return max(d, -ext(k, p.y, .14, .02)); }
float tagSlotRim(vec3 p){ return ext(abs(pill2(p.xz, SLOT.x, SLOT.y, Z1) - .1) - .055, p.y, .03, .02); }
float tagEyelet(vec3 p){ return length(vec2(length(p.xz - PIV) - .7, p.y)) - .13; }
// how much ink is at q on a pill's face (q from the pill's middle, x along it, in the reading direction)
float inkAt(vec2 q, float row, float rows){
  vec2 uv = vec2(q.x / 6.4 + .5, (row + .5 + q.y / 1.6) / rows);
  return abs(q.x) < 3.2 && abs(q.y) < .8 ? textureLod(TEX, uv, 0.).r : 0.; }   // level 0: a path tracer has no screen derivatives, and its samples do the smoothing
const vec3 INK = vec3(.004, .05, .034);
const vec3 MINT = vec3(.030, .46, .30);
const vec3 GROUND = vec3(.0137, .274, .179);   // the sweep: lit, it lands near the icon's own mint, deep enough for white text
Mat tagMat(int part){   // 1 the black slab, 3 the text inlays, 4 a pill, 5 the eyelet, 6 the rim of an empty pocket
  if(part == 1) return Mat(vec3(.011, .012, .013), .07, .06, 0.);
  if(part == 3) return Mat(vec3(.86, .87, .86), .7, .03, 0.);
  if(part == 4) return Mat(MINT * 1.5, .1, .06, 0.);
  if(part == 6) return Mat(MINT * 1.5, .5, .04, 0.);
  return Mat(vec3(.9), .18, .9, 0.); }
vec3 tagEmit(int part){ return part == 4 ? MINT * .35 : part == 6 ? MINT * 1.6 : vec3(0); }
`;
