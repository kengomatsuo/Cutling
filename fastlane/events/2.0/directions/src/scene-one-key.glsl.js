// "One key": a single key on its base, and the whole email it types running out behind it as one long
// printed tape, on a blue sweep. Lengths are centimetres; the key is about eight across.
//   bun ~/.claude/skills/studio-render/scripts/render.mjs "$HOME/.claude/skills/studio-render/scripts/pt.html?scene=$PWD/scene-one-key.glsl.js&spp=700" ../one-key/card.png 2880 1620
//   (and 1620 2880 for details.png; src/build.sh runs both)
window.SCENE_EXPO = 1.0;
window.SCENE_GLSL = `
#define NEPS .006
#define STEP .55
#define FAR 900.
#define THICK .08
float gT;
const float YAW = -.86;            // the tape runs back and to the right
const float TW = 3.5;              // half the tape's width
const float S0 = 3.6;              // where the tape leaves the base
const float ARC = 30.;             // length of the standing loop
const float AH = 11.5;             // its height

Cam camera(){
  Cam c;
  c.pos = mix(vec3(-14, 25, 74), vec3(-52, 47, 60), TALL);
  c.at = mix(vec3(13.5, -2.6, -8), vec3(9, -7.5, -9), TALL);
  c.fov = mix(20., 24., TALL);
  c.lens = .42;
  c.focus = dot(vec3(0, 4, 2) - c.pos, normalize(c.at - c.pos));
  return c; }

vec3 loc(vec3 p){ p.xz *= rot(YAW); return p; }
// height of the tape at distance s behind the key: a standing loop, then nearly flat with slow ripples
float tapeH(float s){
  float t = clamp((s - S0) / ARC, 0., 1.), u = pow(t, .72), a = sin(PI * u);
  float rip = .5 * smoothstep(ARC + S0 - 2., ARC + S0 + 30., s) * (.5 + .5 * sin(s * .083 + 1.3)) * (.5 + .5 * sin(s * .19));
  return .05 + AH * a * a + rip * rip * 2.2; }
float tape(vec3 p){
  float s = -p.z;
  if(s < S0 - .5) return 1e9;
  float h = tapeH(s), dh = (tapeH(s + .05) - tapeH(s - .05)) / .1;
  float d = abs(p.y - h) / sqrt(1. + dh * dh) - .022;
  // the tape drifts a little sideways as it runs, as a strip laid by hand does
  float x = p.x - .9 * sin(s * .021) * smoothstep(40., 160., s);
  return max(max(d, abs(x) - TW), s - 520.); }
float keycap(vec3 p){
  p.y -= 1.5;
  float k = 1. + .052 * p.y;
  float d = sdBox(vec3(p.x * k, p.y - 2.3, p.z * k), vec3(3.5, 2.1, 3.5)) - .55;
  float dish = length(p - vec3(0, 4.9 + 17.2, 0)) - 17.6;     // a shallow dish in the top
  return -smin(-d * .86, dish, .35); }
float base(vec3 p){ return sdBox(p - vec3(0, .55, 0), vec3(4.55, .42, 4.55)) - .28; }
float sweep(vec3 p){
  vec2 q = vec2(p.y, p.z + 430.); const float r = 150.;
  return (q.x < r && q.y < r) ? r - length(r - q) : min(q.x, q.y); }
float map(vec3 p, out int id){
  float d = sweep(p); id = 0;
  vec3 s = loc(p);
  float e = tape(s); if(e < d){ d = e; id = 1; }
  float b = length(s - vec3(0, 3, 0)) - 9.;
  if(b < d){
    e = base(s); if(e < d){ d = e; id = 2; }
    e = keycap(s); if(e < d){ d = e; id = 3; }
  }
  return d; }

// what is printed on the tape: rows of words as rounded bars, a paragraph break now and then, and here
// and there a pill for a part that changes. u runs across the tape, v along it.
vec3 printed(vec2 uv, vec3 paper){
  const float ROW = .84, CW = .6;
  float r = floor(uv.y / ROW), fy = fract(uv.y / ROW) - .5;
  float para = mod(r, 9.);
  if(para > 7.5) return paper;                                   // the gap between paragraphs
  float len = para > 6.5 ? .35 + .4 * hash21(vec2(r, 7.)) : .86 + .14 * hash21(vec2(r, 3.));
  float x = (uv.x + TW - .55) / CW, n = floor((2. * TW - 1.1) / CW * len);
  if(x < 0. || x > n) return paper;
  float i = floor(x), fx = fract(x);
  // words: a gap after a cell when its hash says so; never two gaps together
  float gapR = step(.62, hash21(vec2(i, r))) , gapL = step(.62, hash21(vec2(i - 1., r)));
  if(i >= n - 1.) gapR = 1.; if(i < 1.) gapL = 1.;
  float dx = 0.;
  if(gapR > .5) dx = max(dx, fx - .72);
  if(gapL > .5) dx = max(dx, .1 - fx);
  // a pill takes two cells of a row now and then
  float pc = floor(i / 2.), pill = step(.9, hash21(vec2(pc + 31., r * 1.7))) * step(1.5, para) ;
  float hh = pill > .5 ? .27 : .15;
  float d = length(vec2(max(dx, 0.) * CW, max(abs(fy) * ROW - hh + .1, 0.))) - .1;
  // a pill is two cells long with fully round ends, as Cutling draws them
  if(pill > .5){ float rr = hh, in_ = rr / CW + .06; float e = mod(i, 2.) < .5 ? in_ - fx : fx - (1. - in_); d = length(vec2(max(e, 0.) * CW, abs(fy) * ROW)) - rr; }
  float m = smoothstep(.02, -.02, d);
  vec3 ink = pill > .5 ? vec3(.07, .70, .52) : vec3(.075, .085, .12);
  return mix(paper, ink, m * (pill > .5 ? 1. : .93)); }

Mat mat(int id, vec3 p, vec3 n){
  if(id == 0) return Mat(vec3(.030, .105, .66), .85, .03, 0.);
  vec3 s = loc(p);
  if(id == 1){
    float sd = -s.z;
    // distance along the tape: the run plus what the loop adds
    float a = 0., q = S0; for(int i = 0; i < 24; i++){ float w = min(sd, S0 + ARC) - S0; if(w <= 0.) break; float st = w / 24., h0 = tapeH(q), h1 = tapeH(q + st); a += sqrt(st * st + (h1 - h0) * (h1 - h0)); q += st; }
    float v = sd <= S0 + ARC ? a : a + (sd - S0 - ARC);
    float x = s.x - .9 * sin(sd * .021) * smoothstep(40., 160., sd);
    vec3 paper = vec3(.86, .85, .82) * (.985 + .03 * vnoise(vec2(x, v) * 30.));
    bool top = (s.y - tapeH(sd)) * 1. > 0. ? n.y > -.2 : n.y > .2;
    vec3 c = printed(vec2(x, v), paper);
    return Mat(c, .78, .03, .34); }
  if(id == 2) return Mat(vec3(.012, .016, .03), .32, .045, 0.);
  // the key: mint, a satin plastic with the faintest moulding grain
  return Mat(vec3(.05, .62, .45) * (.985 + .03 * vnoise(s.xz * 60.)), .3, .045, 0.); }
const int NL = 3;
void lightDef(int i, out vec3 c, out vec3 at, out vec2 hs, out vec3 Le){
  if(i == 0){ c = vec3(-70, 84, -40); at = vec3(4, 4, -8); hs = vec2(34, 26); Le = vec3(31., 29.6, 27.2); }
  else if(i == 1){ c = vec3(80, 70, 120); at = vec3(10, 10, -20); hs = vec2(60, 50); Le = vec3(2.9, 3.1, 3.6); }
  // a long bank over the run, so the tape stays lit all the way back
  else { c = vec3(110, 150, -150); at = vec3(120, 0, -110); hs = vec2(120, 70); Le = vec3(6.2, 6.1, 6.0); } }
vec3 sky(vec3 d){ return vec3(.022, .026, .04); }
`;
