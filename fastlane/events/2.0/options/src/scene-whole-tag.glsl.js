// "Drop-in": Cutling's tag as a real object. The black tag carries three lines of text, two mint pills
// sit in their pockets, and the third is caught in the air above the one pocket still empty: a blank
// being filled. The tag's face is in tag.glsl.js.
window.SCENE_EXPO = 1.0;
window.SCENE_GLSL = `
#define NEPS .004
#define STEP .8
#define FAR 700.
#define THICK .1
#define EMIT
float gT;
` + window.TAG_GLSL + `
const float TOP = 1.4;               // height of the top tag's face
#define YAW mix(.13, .5, TALL)

Cam camera(){
  Cam c;
  c.at = mix(vec3(-.9, 0, 6.3), vec3(.2, 0, 7.6), TALL);
  c.pos = c.at + mix(vec3(-5, 44, 49), vec3(-4, 61, 53), TALL);
  c.fov = mix(21., 31., TALL);
  c.lens = .32;
  c.focus = dot(vec3(0, 2, -1) - c.pos, normalize(c.at - c.pos));
  return c; }

vec2 fan(vec2 p, float a){ return (p - PIV) * rot(a) + PIV; }
// the pill for the first line, 2.5 cm above its pocket and falling while the shutter is open
float dropping(vec3 p){
  p -= vec3(.5 * (SLOT.x + SLOT.y) + .4, 2.5, Z1 - .1) + vec3(.04, -.5, 0.) * (gT - .5);
  p.xy *= rot(-.36); p.xz *= rot(.1); p.yz *= rot(.16);
  return ext(lozenge(p.xz, .5 * (SLOT.y - SLOT.x) - PR) - PR, p.y, .42, .4); }
// the white tags under the top one, fanned round the eyelet as on the icon
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
  vec3 s = p; s.xz *= rot(YAW); s.y -= TOP;
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
  return tagMat(id); }
vec3 emit(int id, vec3 p){ return tagEmit(id); }
// the key, the fill, and a dim strip behind the set whose reflection is the sheen on the black tag
const int NL = 3;
void lightDef(int i, out vec3 c, out vec3 at, out vec2 hs, out vec3 Le){
  if(i == 0){ c = vec3(-58, 78, -18); at = vec3(0, 4, 0); hs = vec2(30, 24); Le = vec3(30., 28.8, 27.); }
  else if(i == 2){ c = mix(vec3(8, 47, -66), vec3(8, 60, -66), TALL); at = vec3(0, 2, 0); hs = vec2(34, 8); Le = vec3(.36, .4, .39); }
  else { c = vec3(70, 80, 120); at = vec3(10, 16, -20); hs = vec2(60, 50); Le = vec3(2.6, 2.8, 3.0); } }
vec3 sky(vec3 d){ return vec3(.026, .03, .029); }
`;
