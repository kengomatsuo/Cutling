// Renders a direction's frames from film.html through headless Chrome (the same flags as the event
// directions' frames.mjs and studio-render's render.mjs).
//   bun render.mjs stills <direction> <iphone|ipad|mac> <outdir>         every still the film lists, at delivered size
//   bun render.mjs at <direction> <device> <t> <out.png>                one frame
//   bun render.mjs movie <direction> <device> <out.mp4> [fps=30]         the animatic's picture, H.264, no sound
//   bun render.mjs seam <direction> <device> <out.json>                  the seam signals, sampled at 120 a second
import { spawn } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const [cmd, dir, dev = 'iphone', a4, a5] = process.argv.slice(2);
const CHROME = process.env.CHROME || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const port = 20000 + Math.floor(Math.random() * 20000);
const profile = mkdtempSync(join(tmpdir(), 'cutling-previews-'));
const chrome = spawn(CHROME, ['--headless=new', '--disable-background-timer-throttling', '--disable-renderer-backgrounding',
  '--disable-backgrounding-occluded-windows', '--hide-scrollbars', '--no-sandbox', '--force-color-profile=srgb', '--allow-file-access-from-files',
  `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`, 'about:blank'], { stdio: 'ignore' });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const stop = async (code) => { chrome.kill(); await sleep(300); rmSync(profile, { recursive: true, force: true }); process.exit(code); };
for (const sig of ['SIGINT', 'SIGTERM', 'SIGHUP']) process.on(sig, () => stop(1));

let ws, nextId = 1; const pending = new Map();
for (let i = 0; ; i++) {
  try {
    const v = await (await fetch(`http://127.0.0.1:${port}/json/version`)).json(); ws = new WebSocket(v.webSocketDebuggerUrl);
    await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; }); break;
  } catch (e) { if (i > 150) throw new Error('chrome did not start'); await sleep(200); }
}
let pageError = null;
ws.onmessage = (e) => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { const { res, rej } = pending.get(m.id); pending.delete(m.id); m.error ? rej(new Error(m.error.message)) : res(m.result); }
  else if (m.method === 'Runtime.exceptionThrown') { const d = m.params.exceptionDetails; pageError = `${d.exception?.description || d.text} (line ${d.lineNumber})`; }
};
const send = (method, params = {}, sessionId) => new Promise((res, rej) => { const id = nextId++; pending.set(id, { res, rej }); ws.send(JSON.stringify({ id, method, params, sessionId })); });

try {
  const { targetId } = await send('Target.createTarget', { url: 'about:blank' });
  const { sessionId } = await send('Target.attachToTarget', { targetId, flatten: true });
  const S = (m, p) => send(m, p, sessionId);
  await S('Page.enable'); await S('Runtime.enable');
  if (cmd === 'page') {
    // bun render.mjs page <page.html> <width> <out.png>: a whole page, however tall, at 1x
    await S('Emulation.setDeviceMetricsOverride', { width: +dev, height: 1000, deviceScaleFactor: 1, mobile: false });
    await S('Page.navigate', { url: `file://${resolve(dir)}` });
    const evp = async (expression) => (await S('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true })).result.value;
    for (let i = 0; !(await evp('!!window.__done')); i++) { if (i > 300) throw new Error('page never finished loading'); await sleep(100); }
    const height = await evp('document.documentElement.scrollHeight');
    await S('Emulation.setDeviceMetricsOverride', { width: +dev, height, deviceScaleFactor: 1, mobile: false });
    await sleep(300);
    writeFileSync(a4, Buffer.from((await S('Page.captureScreenshot', { format: 'png', clip: { x: 0, y: 0, width: +dev, height, scale: 1 } })).data, 'base64'));
    console.log(`${a4}: ${dev} x ${height}`);
    await stop(0);
  }
  const url = `file://${resolve(here, 'film.html')}?d=${dir}&dev=${dev}&label=${process.env.LABEL ?? '1'}`;
  await S('Page.navigate', { url });
  const ev = async (expression) => {
    const r = await S('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
    if (r.exceptionDetails) throw new Error(r.exceptionDetails.exception?.description || r.exceptionDetails.text);
    return r.result.value;
  };
  for (let i = 0; !(await ev('!!window.__done')); i++) { if (pageError) throw new Error(pageError); if (i > 300) throw new Error('page never finished loading'); await sleep(100); }
  const size = await ev('({w: parseInt(document.getElementById("frame").style.width), h: parseInt(document.getElementById("frame").style.height)})');
  await S('Emulation.setDeviceMetricsOverride', { width: size.w, height: size.h, deviceScaleFactor: 1, mobile: false });
  const shot = async (t) => {
    await ev(`(async () => { await window.draw(${t}); await new Promise(requestAnimationFrame); await new Promise(requestAnimationFrame); })()`);
    if (pageError) throw new Error(pageError);
    return Buffer.from((await S('Page.captureScreenshot', { format: 'png', clip: { x: 0, y: 0, width: size.w, height: size.h, scale: 1 } })).data, 'base64');
  };
  if (cmd === 'stills') {
    mkdirSync(a4, { recursive: true });
    const stills = await ev('window.STILLS');
    for (const s of stills) { writeFileSync(join(a4, `${s.name}.png`), await shot(s.t)); console.log(`${a4}/${s.name}.png  t=${s.t}s  ${s.note}`); }
  } else if (cmd === 'at') {
    writeFileSync(a5, await shot(+a4)); console.log(a5);
  } else if (cmd === 'movie') {
    const fps = +(a5 || 30), L = await ev('window.LOOP'), n = Math.round(L * fps);
    const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(fps), '-c:v', 'png', '-i', '-',
      '-c:v', 'libx264', '-preset', 'medium', '-crf', '24', '-pix_fmt', 'yuv420p', '-profile:v', 'high', '-movflags', '+faststart', '-r', String(fps), a4], { stdio: ['pipe', 'inherit', 'inherit'] });
    const t0 = Date.now();
    for (let i = 0; i < n; i++) { const b = await shot(i / fps); if (!ff.stdin.write(b)) await new Promise((r) => ff.stdin.once('drain', r)); }
    ff.stdin.end(); await new Promise((r) => ff.on('exit', r));
    console.log(`${a4}: ${n} frames at ${fps} fps, ${L.toFixed(2)} s, ${((Date.now() - t0) / 1000).toFixed(0)} s to render`);
  } else if (cmd === 'seam') {
    const data = await ev('window.seamSamples(1.5, 1/120)');
    writeFileSync(a4, JSON.stringify(data)); console.log(a4, data ? Object.keys(data.signals).join(', ') : 'no seam signals');
  } else if (cmd === 'seamplot') {
    // Speed and acceleration of every moving thing across the loop's seam, and whether each is continuous there.
    const data = await ev('window.seamSamples(1.5, 1/120)');
    const h = 1 / 120;
    const rows = [], verdicts = [];
    for (const [name, pts] of Object.entries(data.signals)) {
      const f = pts.map((p) => p[1]), u = pts.map((p) => p[0]);
      const i0 = u.findIndex((x) => Math.abs(x) < h / 2);          // the sample at the seam (the film's frame 0)
      const v = f.map((_, i) => (i === 0 || i === f.length - 1 ? NaN : (f[i + 1] - f[i - 1]) / (2 * h)));
      const a = f.map((_, i) => (i === 0 || i === f.length - 1 ? NaN : (f[i + 1] - 2 * f[i] + f[i - 1]) / (h * h)));
      // one-sided limits at the seam, from the film's last samples and its first
      const fL = 2 * f[i0 - 1] - f[i0 - 2], vL = (f[i0 - 1] - f[i0 - 2]) / h, vR = (f[i0 + 2] - f[i0 + 1]) / h;
      const aL = (f[i0 - 1] - 2 * f[i0 - 2] + f[i0 - 3]) / (h * h), aR = (f[i0 + 3] - 2 * f[i0 + 2] + f[i0 + 1]) / (h * h);
      const scaleV = Math.max(1e-9, ...v.filter(Number.isFinite).map(Math.abs)), scaleA = Math.max(1e-9, ...a.filter(Number.isFinite).map(Math.abs));
      const jumpF = Math.abs(f[i0] - fL), jumpV = Math.abs(vR - vL) / scaleV, jumpA = Math.abs(aR - aL) / scaleA;
      const range = Math.max(...f) - Math.min(...f);
      const ok = jumpF <= Math.max(1e-6, 0.01 * range) && (scaleV < 1e-6 || jumpV < 0.05) && (scaleA < 1e-6 || jumpA < 0.1);
      verdicts.push({ name, ok, jumpF, jumpV, jumpA, still: scaleV < 1e-6 });
      rows.push({ name, u, f, v, a, ok, still: scaleV < 1e-6 });
    }
    const W = 1200, rowH = 150, pad = 18, colW = (W - 260) / 3;
    const path = (u, ys, x0) => {
      const fin = ys.filter(Number.isFinite); const lo = Math.min(...fin), hi = Math.max(...fin);
      const span = hi - lo < 1e-9 ? 1 : hi - lo;
      return ys.map((y, i) => (Number.isFinite(y) ? `${i && Number.isFinite(ys[i - 1]) ? 'L' : 'M'}${(x0 + ((u[i] + 1.5) / 3) * colW).toFixed(1)},${(pad + 10 + (1 - (hi - lo < 1e-9 ? 0.5 : (y - lo) / span)) * (rowH - 2 * pad - 20)).toFixed(1)}` : '')).join('');
    };
    let svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${60 + rows.length * rowH}" font-family="-apple-system,system-ui" font-size="15">
      <rect width="100%" height="100%" fill="#fff"/>
      <text x="16" y="30" font-size="19" font-weight="700" fill="#1d1d1f">${dir}: the loop's seam (${data.kind}), 1.5 s either side, sampled 120 times a second</text>
      ${['value', 'speed', 'acceleration'].map((k, j) => `<text x="${260 + j * colW + colW / 2}" y="54" text-anchor="middle" font-weight="600" fill="#55555b">${k}</text>`).join('')}`;
    rows.forEach((r, k) => {
      const y0 = 60 + k * rowH;
      svg += `<g transform="translate(0,${y0})"><text x="16" y="${rowH / 2 - 6}" font-weight="600" fill="#1d1d1f">${r.name}</text>
        <text x="16" y="${rowH / 2 + 16}" fill="${r.ok ? '#007a56' : '#c0392b'}" font-weight="700">${r.ok ? (r.still ? 'at rest: continuous' : 'continuous') : 'BREAK at the seam'}</text>`;
      [r.f, r.v, r.a].forEach((ys, j) => {
        const x0 = 260 + j * colW;
        svg += `<rect x="${x0}" y="${pad}" width="${colW - 14}" height="${rowH - 2 * pad}" fill="#f6f6f4" rx="8"/>
          <line x1="${x0 + colW / 2}" x2="${x0 + colW / 2}" y1="${pad}" y2="${rowH - pad}" stroke="#00be86" stroke-width="2" stroke-dasharray="4 4"/>
          <path d="${path(r.u, ys, x0)}" fill="none" stroke="#1d1d1f" stroke-width="2.2"/>`;
      });
      svg += `</g>`;
    });
    svg += `<text x="${260 + colW * 1.5}" y="${60 + rows.length * rowH - 4}" text-anchor="middle" font-size="13" fill="#6e6e73">green dashes: the seam, where the film's last frame meets its first</text></svg>`;
    await S('Emulation.setDeviceMetricsOverride', { width: W, height: 60 + rows.length * rowH, deviceScaleFactor: 1, mobile: false });
    await S('Page.navigate', { url: 'data:text/html;charset=utf-8,' + encodeURIComponent(`<html><body style="margin:0">${svg}</body></html>`) });
    await sleep(500);
    writeFileSync(a4, Buffer.from((await S('Page.captureScreenshot', { format: 'png' })).data, 'base64'));
    writeFileSync(a4.replace(/\.png$/, '.json'), JSON.stringify({ kind: data.kind, verdicts }, null, 1));
    console.log(a4, verdicts.map((x) => `${x.name}: ${x.ok ? 'ok' : 'BREAK'}`).join('; '));
  } else throw new Error('unknown command ' + cmd);
} catch (e) { console.error(String(e)); await stop(1); }
await stop(0);
