// Draws the Inserted mark's contact sheet from spec.json, and nothing else.
// Every size, colour and time below is read from the spec; check.mjs fails on any literal the spec lacks
// (bare zero, one and two are allowed for arithmetic).
// Run: node mock.mjs  (writes mock.html, then renders mock.png with headless Chrome)
import { readFileSync, writeFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const S = JSON.parse(readFileSync(join(here, "spec.json"), "utf8"));
const M = S.mock;
const T = Object.fromEntries(S.timeline.elements.map((e) => [e.id, e]));
const hold = S.timeline.hold;
const RM = S.reduceMotion;

// Spring with bounce 0, SwiftUI's .smooth(duration:): critically damped, response = duration.
const spring = (t, d) => (t <= 0 ? 0 : 1 - (1 + (2 * Math.PI * t) / d) * Math.exp((-2 * Math.PI * t) / d));
const clamp = (x) => Math.max(0, Math.min(1, x));
const easeInOut = (x) => (1 - Math.cos(Math.PI * clamp(x))) / 2;

// The mark's state at time t (seconds from the insert).
function state(t, reduce) {
  const returning = t >= hold;
  const L = RM.lineSwap;
  let status, preview;
  if (reduce) {
    const fadeIn = (from) => easeInOut((t - from - L.inDelay) / L.inDuration);
    const fadeOut = (from) => 1 - easeInOut((t - from) / L.outDuration);
    status = !returning ? fadeIn(0) : fadeOut(hold);
    preview = !returning ? fadeOut(0) : fadeIn(hold);
  } else {
    status = !returning ? spring(t - T.statusIn.start, T.statusIn.duration) : 1 - spring(t - T.statusOut.start, T.statusOut.duration);
    preview = !returning ? 1 - spring(t - T.previewOut.start, T.previewOut.duration) : spring(t - T.previewIn.start, T.previewIn.duration);
  }
  const draw = reduce ? 1 : spring(t - T.checkDraw.start, T.checkDraw.duration);
  const b = clamp((t - T.iconBounce.start) / T.iconBounce.duration);
  const bounce = reduce || t <= 0 ? 1 : 1 + (M.bounceScale - 1) * Math.sin(Math.PI * b);
  const wash = t < hold ? spring(t - T.washIn.start, T.washIn.duration) : 1 - spring(t - T.washOut.start, T.washOut.duration);
  return { status, preview, draw, bounce, wash, reduce, returning };
}

// blurReplace stand-in: v is how present the view is (0 gone, 1 settled).
function blurStyle(v, entering, reduce) {
  if (reduce) return `opacity:${v};`;
  const scale = entering ? M.blurReplaceScale + (1 - M.blurReplaceScale) * v : 1 + (1 - M.blurReplaceScale) * (1 - v);
  return `opacity:${v};filter:blur(${(1 - v) * M.blurReplaceBlur}px);transform:scale(${scale});transform-origin:left center;`;
}

function check(size, colour, draw) {
  const pts = M.checkPath.map(([x, y]) => `${x * size},${y * size}`).join(" ");
  const len = size * M.checkPath.slice(1).reduce((a, p, i) => a + Math.hypot(p[0] - M.checkPath[i][0], p[1] - M.checkPath[i][1]), 0);
  const stroke = size * M.checkStroke;
  return `<svg width="${size}" height="${size}" style="flex:none;overflow:visible"><polyline points="${pts}" fill="none" stroke="${colour}" stroke-width="${stroke}" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="${len}" stroke-dashoffset="${len * (1 - draw)}"/></svg>`;
}

// One text card. bp = breakpoint, c = colours, st = state (null = idle), today = draw the shipped mark instead.
function textCard(bp, c, st, width, name, preview, tint, today) {
  const lh = M.lineHeight;
  const previewTop = bp.cardPadding + bp.titleSize * lh + bp.rowSpacing;
  const s = st || { status: 0, preview: 1, draw: 0, bounce: 1, wash: 0, reduce: false };
  const washA = c.washOpacity * s.wash;
  const font = `font-family:-apple-system,system-ui,sans-serif;`;
  let html = `<div style="position:relative;width:${width}px;height:${bp.cardHeight}px;border-radius:${bp.cornerRadius}px;background:${c.keyFill};overflow:hidden;${font}">`;
  html += `<div style="position:absolute;inset:0;background:${tint};opacity:${washA}"></div>`;
  html += `<div style="position:absolute;left:${bp.cardPadding}px;top:${bp.cardPadding}px;right:${bp.cardPadding}px;display:flex;align-items:center;gap:${bp.iconTitleSpacing}px;height:${bp.titleSize * lh}px">`;
  html += `<div style="width:${bp.iconSize}px;height:${bp.iconSize}px;border-radius:${bp.iconSize / 2}px;background:${tint};transform:scale(${s.bounce});flex:none"></div>`;
  html += `<div style="font-size:${bp.titleSize}px;font-weight:${S.type.title.weight};color:${c.primary};white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${name}</div></div>`;
  html += `<div style="position:absolute;left:${bp.cardPadding}px;right:${bp.cardPadding}px;top:${previewTop}px;font-size:${bp.bodySize}px;line-height:${lh};color:${c.secondary};display:-webkit-box;-webkit-line-clamp:${S.type.preview.lines};-webkit-box-orient:vertical;overflow:hidden;${blurStyle(s.preview, !!s.returning, s.reduce)}">${preview}</div>`;
  if (s.status > 0) {
    html += `<div style="position:absolute;left:${bp.cardPadding}px;right:${bp.cardPadding}px;top:${previewTop}px;height:${bp.bodySize * lh}px;display:flex;align-items:center;gap:${bp.statusIconSpacing}px;font-size:${bp.statusTextSize}px;font-weight:${S.type.status.weight};color:${c.primary};${blurStyle(s.status, !s.returning, s.reduce)}">`;
    html += check(bp.statusCheckSize, tint, s.draw) + `<span>${S.copy.textInserted}</span></div>`;
  }
  if (today) {
    html += `<div style="position:absolute;inset:0;backdrop-filter:blur(${M.todayMaterialBlur}px);background:${c.keyFill};opacity:${M.todayMaterialOpacity}"></div>`;
    html += `<div style="position:absolute;inset:0;display:flex;align-items:center;justify-content:center;gap:${bp.statusIconSpacing}px;font-size:${bp.titleSize}px;font-weight:${S.type.status.weight};color:${c.primary}">${check(bp.titleSize, c.primary, 1)}<span>${S.copy.textInserted}</span></div>`;
  }
  return html + `</div>`;
}

function imageCard(bp, c, st, width) {
  const lh = M.lineHeight;
  const s = st || { status: 0, preview: 1, draw: 0, bounce: 1, wash: 0, reduce: false };
  const band = bp.imageNameSize * lh + bp.imageNamePadding * 2;
  const font = `font-family:-apple-system,system-ui,sans-serif;`;
  const sh = S.type.imageShadow;
  const shadow = `text-shadow:0 ${sh.y}px ${sh.radius}px rgba(0,0,0,${sh.opacity})`;
  let html = `<div style="position:relative;width:${width}px;height:${bp.cardHeight}px;border-radius:${bp.cornerRadius}px;background:${c.imagePlaceholder};overflow:hidden;${font}">`;
  html += `<div style="position:absolute;left:0;right:0;bottom:0;height:${band}px;background:linear-gradient(transparent,${c.imageGradientBottom})"></div>`;
  html += `<div style="position:absolute;left:${bp.imageNamePadding}px;bottom:${bp.imageNamePadding}px;font-size:${bp.imageNameSize}px;font-weight:${S.type.imageStatus.weight};color:${c.imageStatus};${shadow};${blurStyle(s.preview, !!s.returning, s.reduce)}">${S.samples.imageCard.name}</div>`;
  if (s.status > 0) {
    html += `<div style="position:absolute;left:${bp.imageNamePadding}px;bottom:${bp.imageNamePadding}px;display:flex;align-items:center;gap:${bp.statusIconSpacing}px;font-size:${bp.imageNameSize}px;font-weight:${S.type.imageStatus.weight};color:${c.imageStatus};${shadow};${blurStyle(s.status, !s.returning, s.reduce)}">`;
    html += check(bp.imageNameSize, c.imageStatus, s.draw) + `<span>${S.copy.imageOrStyledCopied}</span></div>`;
  }
  return html + `</div>`;
}

const label = (text, colour) => `<div style="font:${M.labelSize}px ui-monospace,monospace;color:${colour};height:${M.labelGap}px">${text}</div>`;

function row(title, bpName, mode, kind, reduce) {
  const bp = S.breakpoints[bpName];
  const c = S.colors[mode];
  let html = `<div style="background:${c.keyboardBackground};padding:${M.margin / 2}px;border-radius:${bp.cornerRadius}px;margin-bottom:${M.rowGap}px">`;
  html += label(title, c.secondary);
  html += `<div style="display:flex;gap:${M.frameGap}px">`;
  for (const t of M.frames) {
    const st = state(t, reduce);
    html += `<div>${label(`t = ${t.toFixed(2)} s`, c.secondary)}`;
    html += kind === "text" ? textCard(bp, c, st, bp.mockCardWidth, S.samples.textCard.name, S.samples.textCard.preview, c.tintSample) : imageCard(bp, c, st, bp.mockCardWidth);
    html += `</div>`;
  }
  return html + `</div></div>`;
}

function grid(mode, today) {
  const bp = S.breakpoints.phone;
  const c = S.colors[mode];
  const w = (bp.mockKeyboardWidth - bp.horizontalPadding * 2 - bp.gridSpacing) / 2;
  const st = state(M.gridFrame, false);
  let html = `<div><div style="width:${bp.mockKeyboardWidth}px;background:${c.keyboardBackground};padding:${bp.horizontalPadding}px;box-sizing:border-box;border-radius:${bp.cornerRadius}px">`;
  html += label(`${today ? "today" : "new"} · phone ${mode} · t = ${M.gridFrame} s`, c.secondary);
  html += `<div style="display:grid;grid-template-columns:${w}px ${w}px;gap:${bp.gridSpacing}px">`;
  S.samples.gridNames.forEach((n, i) => {
    const marked = i === S.samples.gridMarked;
    html += textCard(bp, c, marked && !today ? st : null, w, n, S.samples.gridPreviews[i], S.samples.gridTints[i], marked && today);
  });
  return html + `</div></div></div>`;
}

function chart() {
  const W = M.chartWidth, lane = M.chartLaneHeight, secs = M.chartSeconds;
  const els = S.timeline.elements;
  const x = (t) => (t / secs) * W;
  const H = lane * els.length;
  let svg = `<svg width="${M.sheetWidth / 2}" height="${H + M.labelGap * 2}" style="font:${M.labelSize}px ui-monospace,monospace">`;
  for (let t = 0; t <= secs + M.chartTick / 2; t += M.chartTick) {
    svg += `<line x1="${x(t)}" x2="${x(t)}" y1="0" y2="${H}" stroke="#ccc"/><text x="${x(t)}" y="${H + M.labelGap}" fill="#666">${t.toFixed(2)}s</text>`;
  }
  svg += `<line x1="${x(hold)}" x2="${x(hold)}" y1="0" y2="${H}" stroke="#e33" stroke-dasharray="${M.blurReplaceBlur}"/>`;
  els.forEach((e, i) => {
    const y0 = i * lane;
    const pts = [];
    for (let k = 0; k <= W; k++) {
      const t = (k / W) * secs;
      const p = t < e.start ? 0 : spring(t - e.start, e.duration);
      pts.push(`${k},${y0 + lane - M.blurReplaceBlur - p * (lane - M.blurReplaceBlur * 2)}`);
    }
    svg += `<rect x="${x(e.start)}" y="${y0 + M.blurReplaceBlur / 2}" width="${x(e.duration)}" height="${lane - M.blurReplaceBlur}" fill="${M.chartColour}" opacity="${M.chartBandOpacity}"/>`;
    svg += `<polyline points="${pts.join(" ")}" fill="none" stroke="${M.chartColour}"/>`;
    svg += `<text x="${x(e.start + e.duration) + M.blurReplaceBlur}" y="${y0 + lane / 2 + M.blurReplaceBlur}" fill="#333">${e.id} ${e.start}+${e.duration}s ${e.curve}</text>`;
  });
  return svg + `</svg>`;
}

const html = `<!doctype html><html><head><meta charset="utf-8"><style>body{margin:0;padding:${M.margin}px;background:#fff;font-family:-apple-system,system-ui,sans-serif}h2{font-size:${S.breakpoints.pad.bodySize}px;margin:0 0 ${M.frameGap}px}</style></head><body>
<h2>Inserted mark · frames from spec.json v${S.version} · t = 0 is the insert, hold ${hold} s, end ${S.timeline.end} s</h2>
${row("A1 phone light · text card", "phone", "light", "text", false)}
${row("A2 phone dark · text card", "phone", "dark", "text", false)}
${row("A3 phone light · image card (Copied)", "phone", "light", "image", false)}
${row("A4 phone light · Reduce Motion", "phone", "light", "text", true)}
${row("B1 iPad light · text card", "pad", "light", "text", false)}
${row("B2 iPad dark · text card", "pad", "dark", "text", false)}
<div style="display:flex;gap:${M.margin}px;margin-bottom:${M.rowGap}px">${grid("light", true)}${grid("light", false)}${grid("dark", false)}</div>
<h2>C1 timeline · each lane is the element's progress, 0 to 1, from spec.json timeline</h2>
${chart()}
</body></html>`;

writeFileSync(join(here, "mock.html"), html);
const chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
execFileSync(chrome, ["--headless=new", "--disable-gpu", "--hide-scrollbars", `--force-device-scale-factor=${M.scale}`,
  `--window-size=${M.sheetWidth},${M.sheetHeight}`, `--screenshot=${join(here, "mock.png")}`, `file://${join(here, "mock.html")}`], { stdio: "ignore" });
console.log("wrote", join(here, "mock.html"), "and", join(here, "mock.png"));
