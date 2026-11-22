// "Close-up": the same tag as Drop-in, shot from a hand's width away. The frame is the pill in the air and
// the lit pocket it is about to fill; the rest of the tag goes soft behind it. The tag is turned half
// round so the pill's line is nearest the lens. The tag's face is in tag.glsl.js.
window.SCENE_EXPO = 1.0;
window.tagInk(["Maya"]);
window.SCENE_GLSL = `
#define NEPS .003
#define STEP .8
#define FAR 700.
#define THICK .1
#define EMIT
float gT;
` + window.TAG_GLSL + `
const float TOP = 1.4;
#define YAW mix(-.16, -.5, TALL)

Cam camera(){
  Cam c;
  c.at = mix(vec3(-4.0, TOP, 2.7), vec3(-2.6, TOP, 5.4), TALL);
  c.pos = c.at + mix(vec3(-3, 19, 23), vec3(-3, 26, 25), TALL);
  c.fov = mix(21., 31., TALL);
  c.lens = mix(.2, .24, TALL);
  c.focus = dot(vec3(0, TOP + 1., 1.) - c.pos, normalize(c.at - c.pos));
  return c; }

vec2 fan(vec2 p, float a){ return (p - PIV) * rot(a) + PIV; }
// the pill for the first line, 2 cm above its pocket, its face turned to the lens so the name reads; the
// shutter is fast, since a blurred name reads as a smear
vec3 dropP(vec3 p){
  p -= vec3(.5 * (SLOT.x + SLOT.y) + .4, 2.0, Z1 - .2) + vec3(.01, -.09, 0.) * (gT - .5);
  p.xy *= rot(-.2); p.xz *= rot(-.06); p.yz *= rot(.46);
  return p; }
float dropping(vec3 p){ p = dropP(p); return ext(lozenge(p.xz, .5 * (SLOT.y - SLOT.x) - PR) - PR, p.y, .42, .4); }
vec3 tagSpace(vec3 p){ p.xz *= rot(YAW); p.xz = -p.xz; p.y -= TOP; return p; }
// the name on the pill in the air; the tag is turned half round, so the ink is too
float name(vec3 p){ vec3 q = dropP(tagSpace(p)); return q.y > .2 && abs(q.z) < .8 ? inkAt(-q.xz, 0., 1.) : 0.; }
float tagsUnder(vec3 p){
  float d = 1e9;
  for(int i = 1; i <= 3; i++){
    float f = float(i); vec2 q = fan(p.xz, -(.085 * f + .012 * f * f));
    float e = ext(tagOutline(q), p.y + .35 + .3 * f, .15, .05);
    d = min(d, max(e, -(length(p.xz - PIV) - .62)));
  }
  return d; }
float sweep(vec3 p){
  vec2 q = vec2(p.y, p.z + 150.); const float r = 80.;
  return (q.x < r && q.y < r) ? r - length(r - q) : min(q.x, q.y); }
float map(vec3 p, out int id){
  float d = sweep(p); id = 0;
  vec3 s = tagSpace(p);
  float b = length(s) - 19.;
  if(b < d){
    float e = tagsUnder(s); if(e < d){ d = e; id = 2; }
    e = tagSlab(s); if(e < d){ d = e; id = 1; }
    e = tagBars(s); if(e < d){ d = e; id = 3; }
    e = min(tagPills(s), dropping(s)); if(e < d){ d = e; id = 4; }
    e = tagSlotRim(s); if(e < d){ d = e; id = 6; }
    e = tagEyelet(s); if(e < d){ d = e; id = 5; }
  }
  return d; }
Mat mat(int id, vec3 p, vec3 n){
  if(id == 0) return Mat(GROUND, .85, .03, 0.);
  if(id == 2){
    float lvl = clamp((TOP - .5 - p.y) / .9, 0., 1.);
    vec3 paper = mix(vec3(.86, .87, .85), vec3(.52, .82, .72), lvl * lvl) * (.985 + .03 * vnoise(p.xz * 40.));
    return Mat(paper, .8, .03, 0.); }
  Mat m = tagMat(id);
  if(id == 4) m.alb = mix(m.alb, INK, name(p));
  return m; }
vec3 emit(int id, vec3 p){ return tagEmit(id) * (id == 4 ? 1. - name(p) : 1.); }
const int NL = 2;
void lightDef(int i, out vec3 c, out vec3 at, out vec2 hs, out vec3 Le){
  if(i == 0){ c = vec3(-58, 78, -18); at = vec3(0, 4, 0); hs = vec2(30, 24); Le = vec3(30., 28.8, 27.); }
  else { c = vec3(70, 80, 120); at = vec3(10, 16, -20); hs = vec2(60, 50); Le = vec3(2.6, 2.8, 3.0); } }
vec3 sky(vec3 d){ return vec3(.026, .03, .029); }
`;
