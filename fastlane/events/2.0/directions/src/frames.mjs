// Renders a page that exposes window.draw(t) and window.LOOP to a seamless H.264 loop, or to a strip of stills.
//   bun frames.mjs <page.html?query> <out.mp4> <width> <height> [fps=30] [loops=1]
//   bun frames.mjs <page.html?query> <out.png> <width> <height> strip <count>     (count frames side by side, to pick a still)
// Frames go from headless Chrome (the same flags as studio-render's render.mjs) straight into ffmpeg.
import { spawn } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const [page, out, w, h, a5 = "30", a6 = "1"] = process.argv.slice(2);
const strip = a5 === "strip", fps = strip ? 0 : +a5, loops = strip ? 1 : +a6, count = strip ? +a6 : 0;
const CHROME = process.env.CHROME || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const port = 20000 + Math.floor(Math.random() * 20000);
const profile = mkdtempSync(join(tmpdir(), "event-art-"));
const chrome = spawn(CHROME, ["--headless=new", "--enable-unsafe-swiftshader", "--disable-background-timer-throttling", "--disable-renderer-backgrounding",
  "--disable-backgrounding-occluded-windows", "--hide-scrollbars", "--no-sandbox", "--force-color-profile=srgb", "--allow-file-access-from-files",
  `--remote-debugging-port=${port}`, `--user-data-dir=${profile}`, "about:blank"], { stdio: "ignore" });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const stop = async (code) => { chrome.kill(); await sleep(300); rmSync(profile, { recursive: true, force: true }); process.exit(code); };
for (const sig of ["SIGINT", "SIGTERM", "SIGHUP"]) process.on(sig, () => stop(1));

let ws, nextId = 1; const pending = new Map();
for (let i = 0; ; i++) {
  try { const v = await (await fetch(`http://127.0.0.1:${port}/json/version`)).json(); ws = new WebSocket(v.webSocketDebuggerUrl);
    await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; }); break;
  } catch (e) { if (i > 150) throw new Error("chrome did not start"); await sleep(200); }
}
ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pending.has(m.id)) { const { res, rej } = pending.get(m.id); pending.delete(m.id); m.error ? rej(new Error(m.error.message)) : res(m.result); } };
const send = (method, params = {}, sessionId) => new Promise((res, rej) => { const id = nextId++; pending.set(id, { res, rej }); ws.send(JSON.stringify({ id, method, params, sessionId })); });

try {
  const [file, query = ""] = page.split("?");
  const { targetId } = await send("Target.createTarget", { url: "about:blank" });
  const { sessionId } = await send("Target.attachToTarget", { targetId, flatten: true });
  const S = (m, p) => send(m, p, sessionId);
  await S("Emulation.setDeviceMetricsOverride", { width: +w, height: +h, deviceScaleFactor: 1, mobile: false });
  await S("Page.enable"); await S("Runtime.enable");
  await S("Page.navigate", { url: `file://${resolve(file)}${query ? "?" + query : ""}` });
  const ev = async (expression) => { const r = await S("Runtime.evaluate", { expression, returnByValue: true, awaitPromise: true }); if (r.exceptionDetails) throw new Error(r.exceptionDetails.exception?.description || r.exceptionDetails.text); return r.result.value; };
  for (let i = 0; !(await ev("!!window.__done")); i++) { if (i > 200) throw new Error("page never finished loading"); await sleep(100); }
  const LOOP = await ev("window.LOOP");
  const shot = async (t) => { await ev(`(async () => { await window.draw(${t}); await new Promise(requestAnimationFrame); })()`); return Buffer.from((await S("Page.captureScreenshot", { format: "png" })).data, "base64"); };
  const t0 = Date.now();
  if (strip) {
    const dir = mkdtempSync(join(tmpdir(), "event-strip-")), files = [];
    for (let i = 0; i < count; i++) { const f = join(dir, `${String(i).padStart(3, "0")}.png`); writeFileSync(f, await shot(LOOP * i / count)); files.push(f); }
    const m = spawn("magick", [...files, "-resize", "25%", "+append", out], { stdio: "inherit" });
    await new Promise((r) => m.on("exit", r)); rmSync(dir, { recursive: true, force: true });
    console.log(`${out}: ${count} frames, ${(LOOP / count).toFixed(3)} s apart, loop ${LOOP} s`);
  } else {
    const n = Math.round(LOOP * fps);
    const ff = spawn("ffmpeg", ["-y", "-loglevel", "error", "-f", "image2pipe", "-framerate", String(fps), "-c:v", "png", "-i", "-",
      "-c:v", "libx264", "-preset", "slow", "-crf", "14", "-pix_fmt", "yuv420p", "-profile:v", "high", "-movflags", "+faststart", "-r", String(fps), out], { stdio: ["pipe", "inherit", "inherit"] });
    for (let l = 0; l < loops; l++) for (let i = 0; i < n; i++) { const b = await shot(LOOP * i / n); if (!ff.stdin.write(b)) await new Promise((r) => ff.stdin.once("drain", r)); }
    ff.stdin.end(); await new Promise((r) => ff.on("exit", r));
    console.log(`${out}: ${n * loops} frames at ${fps} fps, ${(LOOP * loops).toFixed(2)} s, ${((Date.now() - t0) / 1000).toFixed(0)} s to render`);
  }
} catch (e) { console.error(String(e)); await stop(1); }
await stop(0);
