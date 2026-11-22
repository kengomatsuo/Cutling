// "pd7": written by gen.py from its description of the frame; edit that, not this.
window.SCENE_EXPO = 0.8;
window.SCENE_GLSL = `
#define NEPS .004
#define STEP .8
#define FAR 400.
#define THICK .1
float gT;
const vec2 KS = vec2(5.5, 3.75);
const float KH = 2.3, SH = 1.700;
const vec2 AT = vec2(4520., 2752.);
Cam camera(){
  Cam c; c.at = vec3(0, 0, -1.000);
  c.pos = c.at + 100. * vec3(0, sin(radians(64.)), cos(radians(64.)));
  c.fov = 12.9319; c.lens = .22; c.focus = 99.; return c; }
const int NK = 1;
const vec4 KP[NK] = vec4[1](vec4(-1.3000, 9.2000, 0.1000, 0.0000));      // x, z, yaw, height off the floor
const vec3 KA[NK] = vec3[1](vec3(2104.0000, 0.0000, 0.0850));    // its face on the atlas, and its tilt
const int NS = 1;
const vec3 SP[NS] = vec3[1](vec3(6.7000, 8.6000, -0.4000));
const vec2 SA[NS] = vec2[1](vec2(-1.0000, -1.0000));   // a glyph key's face, or -1 for a blank dark key
const int ND = 1;
const vec4 DP[ND] = vec4[1](vec4(-0.2000, 1.2000, -0.0500, 0.0000));     // x, z, yaw, height off the floor
const vec4 DB[ND] = vec4[1](vec4(4.9820, 6.6458, 0.8460, 0.5640));     // half body, corner, thickness
const vec3 DZ[ND] = vec3[1](vec3(0.1128, 0.7520, 0.4700));     // bezel inset, bezel corner, screen corner
const vec2 DS[ND] = vec2[1](vec2(4.6530, 6.2040));     // half screen
const vec4 DR[ND] = vec4[1](vec4(0.0000, 0.0000, 2064.0000, 2752.0000));     // the screen on the atlas
vec3 keyQ(int i, vec3 p){
  vec4 k = KP[i]; p -= vec3(k.x, k.w, k.y); p.xz *= rot(k.z);
  float t = KA[i].z; if(t != 0.){ p.z -= KS.y; p.yz *= rot(-t); p.z += KS.y; }
  return p; }
float top(vec2 x){ return KH - .15 * smoothstep(1., .6, max(abs(x.x) / KS.x, abs(x.y) / KS.y)); }
float sdKey(vec3 q){
  float h = clamp(q.y / KH, 0., 1.);
  vec2 hs = KS - .32 * h, d2 = abs(q.xz) - (hs - .95);
  float dxz = length(max(d2, 0.)) + min(max(d2.x, d2.y), 0.) - .95;
  vec2 w = vec2(dxz, abs(q.y - KH * .5) - KH * .5) + .28;
  float d = min(max(w.x, w.y), 0.) + length(max(w, 0.)) - .28;
  return max(d, (q.y - top(q.xz)) * .9); }
vec3 smallQ(int i, vec3 p){ p -= vec3(SP[i].x, 0, SP[i].y); p.xz *= rot(SP[i].z); return p; }
float sdSmall(vec3 q){
  vec2 d2 = abs(q.xz) - (vec2(SH) - .5);
  float dxz = length(max(d2, 0.)) + min(max(d2.x, d2.y), 0.) - .5;
  vec2 w = vec2(dxz, abs(q.y - .75) - .75) + .2;
  return min(max(w.x, w.y), 0.) + length(max(w, 0.)) - .2; }
vec3 devQ(int i, vec3 p){ p -= vec3(DP[i].x, DP[i].w, DP[i].y); p.xz *= rot(DP[i].z); return p; }
float rrect(vec2 x, vec2 hs, float r){ vec2 d = abs(x) - (hs - r); return length(max(d, 0.)) + min(max(d.x, d.y), 0.) - r; }
float sdDev(int i, vec3 q){
  float th = DB[i].w;
  vec2 w = vec2(rrect(q.xz, DB[i].xy, DB[i].z), abs(q.y - th * .5) - th * .5) + .14;
  return min(max(w.x, w.y), 0.) + length(max(w, 0.)) - .14; }
float map(vec3 p, out int id){
  float d = p.y; id = 0;
  if(p.y > 6.) return p.y - 4.9;      // above everything: the distance down to the tallest key, never the floor's
  for(int i = 0; i < NK; i++){
    vec3 q = keyQ(i, p);
    float b = length(q - vec3(0, KH * .5, 0)) - 7.2;
    if(b < d){ float e = b > 1. ? b : sdKey(q); if(e < d){ d = e; id = 100 + i; } }
  }
  for(int i = 0; i < NS; i++){ float e = sdSmall(smallQ(i, p)); if(e < d){ d = e; id = 200 + i; } }
  for(int i = 0; i < ND; i++){ float e = sdDev(i, devQ(i, p)); if(e < d){ d = e; id = 300 + i; } }
  return d; }
Mat mat(int id, vec3 p, vec3 n){
  if(id == 0){
    float f = .97 + .06 * vnoise(p.xz * 26.) * vnoise(p.xz * 7.);
    return Mat(vec3(.026, .37, .215) * f, .9, .03, 0., vec3(0)); }
  if(id >= 300){
    int i = id - 300; vec3 q = devQ(i, p);
    if(q.y > DB[i].w - .02 && rrect(q.xz, DB[i].xy - DZ[i].x, DZ[i].y) < 0.){
      if(rrect(q.xz, DS[i], DZ[i].z) < 0.){
        vec2 uv = (DR[i].xy + (q.xz / DS[i] * .5 + .5) * DR[i].zw) / AT;
        return Mat(vec3(0), .03, .035, 0., texture(atlas, uv).rgb * 1.16); }
      return Mat(vec3(.004), .03, .04, 0., vec3(0)); }
    return Mat(vec3(.30, .30, .31), .28, .55, 0., vec3(0)); }
  if(id >= 200){
    int i = id - 200; vec3 q = smallQ(i, p);
    if(SA[i].x < 0.) return Mat(vec3(.006, .085, .055), .3, .045, 0., vec3(0));
    vec3 alb = vec3(.88, .88, .87); vec2 f = q.xz / (SH - .25);
    if(q.y > 1.3 && max(abs(f.x), abs(f.y)) < .9) alb *= texture(atlas, (SA[i] + (f / .9 * .5 + .5) * 400.) / AT).rgb;
    return Mat(alb, .34, .045, 0., vec3(0)); }
  int i = id - 100; vec3 q = keyQ(i, p);
  vec3 alb = vec3(.88, .88, .87);
  vec2 f = q.xz / (KS - .32);                            // the printed face is the top, inside the taper
  if(q.y > KH - .4 && max(abs(f.x), abs(f.y)) < .93)
    alb *= texture(atlas, (KA[i].xy + (f / .93 * .5 + .5) * vec2(1208., 824.)) / AT).rgb;
  return Mat(alb, .34, .045, 0., vec3(0)); }
const int NL = 2;
void lightDef(int i, out vec3 c, out vec3 at, out vec2 hs, out vec3 Le){
  if(i == 0){ c = vec3(-92, 76, -28); at = vec3(0, 0, 4); hs = vec2(36, 28); Le = vec3(41., 39.6, 37.5); }
  else { c = vec3(80, 64, 60); at = vec3(0, 0, 4); hs = vec2(52, 40); Le = vec3(3.0, 3.4, 3.8); } }
vec3 sky(vec3 d){ return vec3(.035, .05, .045); }
`;
