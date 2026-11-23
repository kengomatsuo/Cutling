// Renders many pages through one headless Chrome (starting Chrome costs 15 to 35 s; a frame costs about 3).
//   bun render-batch.mjs jobs.json        jobs: [{"html": "/abs/x.html", "png": "/abs/x.png", "w": 1320, "h": 2868}, ...]
// Same page contract as ../render.mjs "page" mode: the page sets window.__done (../ready.js) when it is painted.
import { spawn } from "node:child_process";
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const jobs = JSON.parse(readFileSync(process.argv[2], "utf8"));
const CHROME = process.env.CHROME || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const port = 9400 + Math.floor(Math.random() * 300);
const profile = mkdtempSync(join(tmpdir(), "frames-"));
const chrome = spawn(CHROME, ["--headless=new", "--enable-unsafe-swiftshader", "--hide-scrollbars", "--no-sandbox",
  "--force-color-profile=srgb", "--allow-file-access-from-files", `--remote-debugging-port=${port}`,
  `--user-data-dir=${profile}`, "about:blank"], { stdio: "ignore" });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
let ws, nextId = 1, pageError = null;
const pending = new Map();
for (let i = 0; ; i++) {
  try {
    const v = await (await fetch(`http://127.0.0.1:${port}/json/version`)).json();
    ws = new WebSocket(v.webSocketDebuggerUrl);
    await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
    break;
  } catch (e) { if (i > 300) throw new Error("chrome did not start"); await sleep(200); }
}
ws.onmessage = (e) => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { const { res, rej } = pending.get(m.id); pending.delete(m.id); m.error ? rej(new Error(m.error.message)) : res(m.result); }
  else if (m.method === "Runtime.exceptionThrown") { const d = m.params.exceptionDetails; pageError = `${d.exception?.description || d.text}`; }
};
const send = (method, params = {}, sessionId) => new Promise((res, rej) => {
  const id = nextId++; pending.set(id, { res, rej }); ws.send(JSON.stringify({ id, method, params, sessionId }));
});
let failed = 0;
try {
  for (const j of jobs) {
    const t0 = Date.now();
    const { targetId } = await send("Target.createTarget", { url: "about:blank" });
    const { sessionId } = await send("Target.attachToTarget", { targetId, flatten: true });
    const S = (m, p) => send(m, p, sessionId);
    try {
      await S("Emulation.setDeviceMetricsOverride", { width: j.w, height: j.h || 1200, deviceScaleFactor: 1, mobile: false });
      await S("Page.enable"); await S("Runtime.enable");
      pageError = null;
      await S("Page.navigate", { url: "file://" + j.html });
      const ev = async (expression) => (await S("Runtime.evaluate", { expression, returnByValue: true, awaitPromise: true })).result.value;
      for (;;) {
        if (await ev("!!window.__done")) break;
        if (pageError) throw new Error(pageError);
        if (Date.now() - t0 > 180000) throw new Error("timed out");
        await sleep(200);
      }
      if (!j.h) {   // h 0: the whole document, measured once it is painted
        j.h = await ev("Math.ceil(document.documentElement.scrollHeight)");
        await S("Emulation.setDeviceMetricsOverride", { width: j.w, height: j.h, deviceScaleFactor: 1, mobile: false });
        await sleep(1500);
      }
      const shots = j.crops || [[j.png, 0, j.w]];   // a double-width page is saved as two frames
      for (const [png, x, cw] of shots) {
        const b64 = (await S("Page.captureScreenshot", { format: "png", clip: { x, y: 0, width: cw, height: j.h, scale: 1 } })).data;
        writeFileSync(png, Buffer.from(b64, "base64"));
      }
      console.log(`${j.png} ${((Date.now() - t0) / 1000).toFixed(1)}s`);
    } catch (e) { failed++; console.error(`FAIL ${j.html}: ${e.message}`); }
    await send("Target.closeTarget", { targetId });
  }
} finally { chrome.kill(); await sleep(300); rmSync(profile, { recursive: true, force: true }); }
process.exit(failed ? 1 : 0);
