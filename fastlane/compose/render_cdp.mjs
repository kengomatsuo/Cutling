// Renders panel pages to PNG through one headless Chrome driven over the DevTools
// protocol, so a 750-panel run does not pay a browser launch per page.
//   node render_cdp.mjs jobs.json results.json [concurrency]
// jobs.json: [{page, png, w, h, scale}]. results.json: [{page, ok, boxes, wfail, error}]
import { spawn } from "node:child_process";
import { readFileSync, writeFileSync, mkdtempSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const [jobsPath, resultsPath, conc = "4"] = process.argv.slice(2);
const jobs = JSON.parse(readFileSync(jobsPath, "utf8"));
const CHROME = process.env.CHROME || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
const port = 9400 + Math.floor(Math.random() * 400);
const chrome = spawn(CHROME, [
  "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-sandbox",
  "--force-color-profile=srgb", `--remote-debugging-port=${port}`,
  `--user-data-dir=${mkdtempSync(join(tmpdir(), "cutling-cdp-"))}`, "about:blank",
], { stdio: "ignore" });

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
let ws, nextId = 1;
const pending = new Map();
const listeners = [];

async function connect() {
  for (let i = 0; i < 100; i++) {
    try {
      const v = await (await fetch(`http://127.0.0.1:${port}/json/version`)).json();
      ws = new WebSocket(v.webSocketDebuggerUrl);
      await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
      ws.onmessage = (e) => {
        const m = JSON.parse(e.data);
        if (m.id && pending.has(m.id)) {
          const { res, rej } = pending.get(m.id);
          pending.delete(m.id);
          m.error ? rej(new Error(m.error.message)) : res(m.result);
        } else if (m.method) listeners.forEach((l) => l(m));
      };
      return;
    } catch { await sleep(200); }
  }
  throw new Error("chrome did not start");
}
const send = (method, params = {}, sessionId) =>
  new Promise((res, rej) => {
    const id = nextId++;
    pending.set(id, { res, rej });
    ws.send(JSON.stringify({ id, method, params, sessionId }));
  });

async function render(job) {
  const { targetId } = await send("Target.createTarget", { url: "about:blank" });
  const { sessionId } = await send("Target.attachToTarget", { targetId, flatten: true });
  const S = (m, p) => send(m, p, sessionId);
  try {
    await S("Page.enable");
    await S("Emulation.setDeviceMetricsOverride", { width: job.w, height: job.h, deviceScaleFactor: job.scale, mobile: false });
    const loaded = new Promise((res) => {
      const l = (m) => { if (m.sessionId === sessionId && m.method === "Page.loadEventFired") { listeners.splice(listeners.indexOf(l), 1); res(); } };
      listeners.push(l);
    });
    await S("Page.navigate", { url: "file://" + job.page });
    await Promise.race([loaded, sleep(60000)]);
    let boxes = null;
    for (let i = 0; i < 300 && !boxes; i++) {
      const r = await S("Runtime.evaluate", { expression: "(document.getElementById('hypershots-boxes')||{}).textContent||''", returnByValue: true });
      if (r.result.value) boxes = r.result.value; else await sleep(100);
    }
    if (!boxes) return { page: job.page, ok: false, error: "no boxes dump" };
    const wf = (await S("Runtime.evaluate", { expression: "document.documentElement.dataset.wfail||''", returnByValue: true })).result.value;
    const j = JSON.parse(boxes);
    if (j.panelW !== job.w || j.panelH !== job.h || j.fitFailures.length || wf)
      return { page: job.page, ok: false, boxes: j, wfail: wf, error: "fit" };
    await S("Runtime.evaluate", { awaitPromise: true, expression: "Promise.all([...document.images].map(i=>i.decode().catch(()=>{}))).then(()=>new Promise(r=>requestAnimationFrame(()=>requestAnimationFrame(()=>setTimeout(r,150)))))" });
    const shot = await S("Page.captureScreenshot", { format: "png", captureBeyondViewport: false });
    writeFileSync(job.png, Buffer.from(shot.data, "base64"));
    return { page: job.page, ok: true, boxes: j, wfail: wf };
  } catch (e) {
    return { page: job.page, ok: false, error: String(e) };
  } finally {
    try { await send("Target.closeTarget", { targetId }); } catch {}
  }
}

await connect();
const results = new Array(jobs.length);
let next = 0;
await Promise.all(Array.from({ length: Number(conc) }, async () => {
  while (next < jobs.length) {
    const i = next++;
    results[i] = await render(jobs[i]);
    console.log(i + 1, "/", jobs.length, results[i].ok ? "ok" : "FAIL " + (results[i].error || ""), jobs[i].page.split("/").slice(-3).join("/"));
  }
}));
writeFileSync(resultsPath, JSON.stringify(results));
chrome.kill();
process.exit(0);
