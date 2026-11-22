// "Keys": Cutling's tiles as chunky physical keys, lying on a mint sweep around a phone that shows the real
// capture. A flat lay shot from 64 degrees up, so every key's face reads. Lengths are centimetres.
// One picture 3960 x 2868 is cut into the three store frames, so x runs -20.6..20.6 and each frame is 13.7 wide.
window.SCENE_EXPO = 0.8;
window.SCENE_GLSL = `
#define NEPS .004
#define STEP .8
#define FAR 400.
#define THICK .1
float gT;
const vec2 KS = vec2(5.5, 3.75);    // half a key: the grid tile's 604 x 412
const float KH = 2.3;               // how tall a key stands
const float PK = 1.2;               // the phone is a fifth larger than life beside the keys
const vec2 PS = vec2(3.85, 8.15) * PK;   // half the phone
const float PH = .8 * PK;
const vec2 SS = vec2(3.69, 8.015) * PK;  // half its screen, 1320 x 2868
const vec3 PC = vec3(.8, 0, 6.0);    // where the phone lies
const float PYAW = -.2;
const vec2 AT = vec2(3840., 3296.); // the atlas, pixels

Cam camera(){
  Cam c;
  c.at = vec3(0, 0, 1.7);
  c.pos = c.at + 100. * vec3(0, sin(radians(64.)), cos(radians(64.)));
  c.fov = 17.;
  c.lens = .22;
  c.focus = 99.;
  return c; }

const int NK = 8;
// x, z, yaw, height off the floor; and the tilt about the long edge nearest the camera
const vec4 KP[NK] = vec4[NK](
  vec4(-10.6, -1.5, -.07, 0.),    // 0 Home Address: its blank right end runs over the first seam
  vec4( 13.9, -0.9,  .12, KH),    // 1 Email Signature, lying on Booking Ref
  vec4(-13.6, 10.6,  .15, 0.),    // 2 Work Email, its far edge propped on a small blank key
  vec4( 12.9, 11.0,  .2, 0.),     // 3 Wi-Fi Password: one corner over the second seam
  vec4( 40.0, 60.0,  0., 0.),     // 4 Phone Number, out of the picture
  vec4(-40.0, 60.0,  0., 0.),     // 5 Meeting Link, out of the picture
  vec4(  0.0, 60.0,  0., 0.),     // 6 Social Bio, out of the picture
  vec4( 17.6, -2.9, -.1, 0.));    // 7 Booking Ref, under Email Signature, only its blank end showing
const float KT[NK] = float[NK](0., 0., .2, 0., 0., 0., 0., 0.);

vec3 keyQ(int i, vec3 p){
  vec4 k = KP[i];
  p -= vec3(k.x, k.w, k.y); p.xz *= rot(k.z);
  if(KT[i] != 0.){ p.z -= KS.y; p.yz *= rot(-KT[i]); p.z += KS.y; }
  return p; }
float top(vec2 x){ return KH - .15 * smoothstep(1., .6, max(abs(x.x) / KS.x, abs(x.y) / KS.y)); }
float sdKey(vec3 q){
  float h = clamp(q.y / KH, 0., 1.);
  vec2 hs = KS - .32 * h, d2 = abs(q.xz) - (hs - .95);
  float dxz = length(max(d2, 0.)) + min(max(d2.x, d2.y), 0.) - .95;
  vec2 w = vec2(dxz, abs(q.y - KH * .5) - KH * .5) + .28;
  float d = min(max(w.x, w.y), 0.) + length(max(w, 0.)) - .28;
  return max(d, (q.y - top(q.xz)) * .9); }
// two small blank keys: one holds Work Email up, one lies on the second seam
vec3 propQ(int i, vec3 p){ p -= i == 0 ? vec3(-12.4, 0, 5.3) : vec3(7.0, 0, 16.3); p.xz *= rot(i == 0 ? .5 : -.3); return p; }
float sdProp(vec3 q){
  vec2 d2 = abs(q.xz) - (vec2(1.7) - .5);
  float dxz = length(max(d2, 0.)) + min(max(d2.x, d2.y), 0.) - .5;
  vec2 w = vec2(dxz, abs(q.y - .75) - .75) + .2;
  return min(max(w.x, w.y), 0.) + length(max(w, 0.)) - .2; }
vec3 phoneQ(vec3 p){ p -= PC; p.xz *= rot(PYAW); return p; }
float rrect(vec2 x, vec2 hs, float r){ vec2 d = abs(x) - (hs - r); return length(max(d, 0.)) + min(max(d.x, d.y), 0.) - r; }
float sdPhone(vec3 q){
  vec2 w = vec2(rrect(q.xz, PS, 1.32 * PK), abs(q.y - PH * .5) - PH * .5) + .14;
  return min(max(w.x, w.y), 0.) + length(max(w, 0.)) - .14; }
float map(vec3 p, out int id){
  float d = p.y; id = 0;
  if(p.y > 6.) return p.y - 4.9;      // above everything: the distance down to the tallest key, never the floor's
  for(int i = 0; i < NK; i++){
    vec3 q = keyQ(i, p);
    float b = length(q - vec3(0, KH * .5, 0)) - 7.2;
    if(b < d){ float e = b > 1. ? b : sdKey(q); if(e < d){ d = e; id = 10 + i; } }
  }
  float e = min(sdProp(propQ(0, p)), sdProp(propQ(1, p))); if(e < d){ d = e; id = 4; }
  e = sdPhone(phoneQ(p)); if(e < d){ d = e; id = 2; }
  return d; }
Mat mat(int id, vec3 p, vec3 n){
  if(id == 0){
    float f = .97 + .06 * vnoise(p.xz * 26.) * vnoise(p.xz * 7.);
    return Mat(vec3(.026, .37, .215) * f, .9, .03, 0., vec3(0)); }
  if(id == 4) return Mat(vec3(.006, .085, .055), .3, .045, 0., vec3(0));
  if(id == 2){
    vec3 q = phoneQ(p);
    if(q.y > PH - .02 && rrect(q.xz, PS - .1 * PK, 1.24 * PK) < 0.){
      if(rrect(q.xz, SS, 1.16 * PK) < 0.){
        vec2 uv = (q.xz / SS * .5 + .5) * vec2(1320., 2868.) / AT;
        return Mat(vec3(0), .03, .035, 0., texture(atlas, uv).rgb * 1.16); }
      return Mat(vec3(.004), .03, .04, 0., vec3(0)); }
    return Mat(vec3(.30, .30, .31), .28, .55, 0., vec3(0)); }
  int i = id - 10; vec3 q = keyQ(i, p);
  vec3 alb = vec3(.88, .88, .87);
  vec2 f = q.xz / (KS - .32);                            // the printed face is the top, inside the taper
  if(q.y > KH - .4 && max(abs(f.x), abs(f.y)) < .93){
    vec2 uv = (vec2(1400. + float(i % 2) * 1208., float(i / 2) * 824.) + (f / .93 * .5 + .5) * vec2(1208., 824.)) / AT;
    alb *= texture(atlas, uv).rgb; }
  return Mat(alb, .34, .045, 0., vec3(0)); }
const int NL = 2;
void lightDef(int i, out vec3 c, out vec3 at, out vec2 hs, out vec3 Le){
  if(i == 0){ c = vec3(-92, 76, -28); at = vec3(0, 0, 4); hs = vec2(36, 28); Le = vec3(41., 39.6, 37.5); }
  else { c = vec3(80, 64, 60); at = vec3(0, 0, 4); hs = vec2(52, 40); Le = vec3(3.0, 3.4, 3.8); } }
vec3 sky(vec3 d){ return vec3(.035, .05, .045); }
`;
