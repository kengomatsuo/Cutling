// "Three names": one saved reply, three times. Three of Cutling's tags lie one on the next like shingles,
// the same line of text on each, and the pill in it carries a different name. The tag's parts are in
// tag.glsl.js; this scene lays its own lines, with a larger pill so the names read at card size.
window.SCENE_EXPO = 1.0;
const W3 = window.tagInk(["Maya", "Jonas", "Aiko"]);
window.SCENE_GLSL = `
#define NEPS .003
#define STEP .8
#define FAR 700.
#define THICK .1
#define EMIT
float gT;
` + window.TAG_GLSL + `
const float S = 1.3;                    // pills and names are this much larger than on the other scenes' tag
const float ZA = -4.0;                  // the name's line
const float XP = -3.1;                  // where every name pill starts
const float DZ = 4.4;                   // each tag lies this far down the one before it
const float LEAN = .1132;               // and leans on it, near edge on the ground: atan(.5 / DZ)
const vec3 LEN = vec3(${W3.map((w) => (w * 1.3 + 2.5).toFixed(3)).join(", ")});   // each pill's length, from its name
#define YAW mix(.1, .34, TALL)
#define DX mix(2.4, .9, TALL)

Cam camera(){
  Cam c;
  c.at = mix(vec3(.9, 0, -2.3), vec3(-.2, 0, -.6), TALL);
  c.pos = c.at + mix(vec3(-2, 21.6, 27.9), vec3(-2, 30, 26), TALL);
  c.fov = mix(21., 31., TALL);
  c.lens = mix(.14, .2, TALL);
  c.focus = dot(vec3(0, 1, -3.5) - c.pos, normalize(c.at - c.pos));
  return c; }

// world to tag k's space; every tag leans alike, as shingles do (the first on one out of frame)
vec3 tagK(vec3 p, int k){
  float f = float(k) - 1.;
  p.xz *= rot(YAW); p.x -= f * DX + .25 * sin(f * 7.); p.z -= f * DZ;
  { float z = p.z - HS.y, c = cos(LEAN), s = sin(LEAN); p = vec3(p.x, p.y * c + z * s, -p.y * s + z * c + HS.y); }
  p.y -= .5;
  return p; }
float len(int k){ return k == 0 ? LEN.x : k == 1 ? LEN.y : LEN.z; }
float pillS2(vec2 p, float x0, float x1, float z){ float r = PR * S; return lozenge(p - vec2(.5 * (x0 + x1), z), .5 * (x1 - x0) - r) - r; }
float nameP(vec3 p, int k){ return ext(pillS2(p.xz, XP, XP + len(k), ZA), p.y - .24, .5, .46); }
// one line of text on each tag, the name in it; the rest of the tag is left bare for the App Store's own words
float lines(vec3 p, int k){
  float x = XP + len(k) + .8;
  return min(bar(p, -5.9, -3.9, ZA), bar(p, x, min(x + 4.6, 8.1), ZA)); }
float slab(vec3 p, int k){
  float d = ext(tagOutline(p.xz), p.y + .25, .25, .07);
  d = max(d, -(length(p.xz - PIV) - .62));
  return max(d, -ext(pillS2(p.xz, XP, XP + len(k), ZA) - .07, p.y, .14, .02)); }
float sweep(vec3 p){
  vec2 q = vec2(p.y, p.z + 150.); const float r = 80.;
  return (q.x < r && q.y < r) ? r - length(r - q) : min(q.x, q.y); }
float map(vec3 p, out int id){
  float d = sweep(p); id = 0;
  if(length(p - vec3(0, 1, 0)) - 21. < d) for(int k = 0; k < 3; k++){
    vec3 s = tagK(p, k);
    float e = slab(s, k); if(e < d){ d = e; id = 1; }
    e = lines(s, k); if(e < d){ d = e; id = 3; }
    e = nameP(s, k); if(e < d){ d = e; id = 10 + k; }
    e = tagEyelet(s); if(e < d){ d = e; id = 5; }
  }
  return d; }
float name(vec3 p, int k){ vec3 q = tagK(p, k); return q.y > .3 ? inkAt((q.xz - vec2(XP + .5 * len(k), ZA)) / S, float(k), 3.) : 0.; }
Mat mat(int id, vec3 p, vec3 n){
  if(id == 0) return Mat(GROUND, .85, .03, 0.);
  if(id >= 10){ Mat m = tagMat(4); m.alb = mix(m.alb, INK, name(p, id - 10)); return m; }
  return tagMat(id); }
vec3 emit(int id, vec3 p){ return id >= 10 ? tagEmit(4) * (1. - name(p, id - 10)) : tagEmit(id); }
const int NL = 2;
void lightDef(int i, out vec3 c, out vec3 at, out vec2 hs, out vec3 Le){
  if(i == 0){ c = vec3(-58, 78, -18); at = vec3(0, 4, 0); hs = vec2(30, 24); Le = vec3(30., 28.8, 27.); }
  else { c = vec3(70, 80, 120); at = vec3(10, 16, -20); hs = vec2(60, 50); Le = vec3(2.6, 2.8, 3.0); } }
vec3 sky(vec3 d){ return vec3(.026, .03, .029); }
`;
