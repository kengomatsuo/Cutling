// Renders one page of options/src to a PNG through headless Chrome over the DevTools protocol.
//   bun render.mjs <page.html?query> <out.png> <width> <height> [canvas|page] [scale]
// "canvas" (default) waits for window.__done and saves the page's <canvas> pixels, so a WebGL
// path trace can take as long as it needs; "page" saves a screenshot of the document.
// --enable-unsafe-swiftshader is what lets headless Chrome reach the Mac's GPU (ANGLE Metal).
import { spawn } from "node:child_process";
import { writeFileSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const [page, out, w, h, mode = "canvas", scale = "1"] = process.argv.slice(2);
const CHROME = process.env.CHROME || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
// A wide port range: two sessions rendering at once that drew the same port shared one browser, and the
// second one's tab put the first in the background, where Chrome slows its timers to one a minute.
const port = 20000 + Math.floor(Math.random() * 20000);
const profile = mkdtempSync(join(tmpdir(), "event-art-"));
const chrome = spawn(CHROME, [
  "--headless=new", "--enable-unsafe-swiftshader", "--disable-background-timer-throttling", "--disable-renderer-backgrounding", "--disable-backgrounding-occluded-windows", "--hide-scrollbars", "--no-sandbox",
  "--force-color-profile=srgb", "--allow-file-access-from-files", `--remote-debugging-port=${port}`,
  `--user-data-dir=${profile}`, "about:blank",
], { stdio: "ignore" });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

let ws, nextId = 1, pageError = null;
const pending = new Map();
for (let i = 0; ; i++) {
  try {
    const v = await (await fetch(`http://127.0.0.1:${port}/json/version`)).json();
    ws = new WebSocket(v.webSocketDebuggerUrl);
    await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
    break;
  } catch (e) { if (i > 150) throw new Error("chrome did not start"); await sleep(200); }
}
ws.onmessage = (e) => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) {
    const { res, rej } = pending.get(m.id);
    pending.delete(m.id);
    m.error ? rej(new Error(m.error.message)) : res(m.result);
  } else if (m.method === "Runtime.exceptionThrown") {
    const d = m.params.exceptionDetails;
    pageError = `${d.exception?.description || d.text} (line ${d.lineNumber})`;
  }
};
const send = (method, params = {}, sessionId) => new Promise((res, rej) => {
  const id = nextId++;
  pending.set(id, { res, rej });
  ws.send(JSON.stringify({ id, method, params, sessionId }));
});

try {
  const [file, query = ""] = page.split("?");
  const url = `file://${resolve(file)}${query ? "?" + query : ""}`;
  const { targetId } = await send("Target.createTarget", { url: "about:blank" });
  const { sessionId } = await send("Target.attachToTarget", { targetId, flatten: true });
  const S = (m, p) => send(m, p, sessionId);
  await S("Emulation.setDeviceMetricsOverride", { width: +w, height: +h, deviceScaleFactor: +scale, mobile: false });
  await S("Page.enable");
  await S("Runtime.enable");
  await S("Page.navigate", { url });
  const ev = async (expression) => (await S("Runtime.evaluate", { expression, returnByValue: true, awaitPromise: true })).result.value;
  const t0 = Date.now();
  for (;;) {
    const state = await ev("window.__done ? 'done' : (window.__error || window.__progress || 'wait')");
    if (state === "done") break;
    if (pageError) throw new Error(pageError);
    if (typeof state === "string" && state.startsWith("ERR")) throw new Error(state);
    if (Date.now() - t0 > 1000 * 60 * 30) throw new Error("timed out: " + state);
    await sleep(300);
  }
  let b64;
  if (mode === "page") {   // the whole document, however tall it turned out
    const height = await ev("document.documentElement.scrollHeight");
    b64 = (await S("Page.captureScreenshot", { format: "png", captureBeyondViewport: true, clip: { x: 0, y: 0, width: +w, height, scale: 1 } })).data;
  }
  else b64 = (await ev("document.querySelector('canvas').toDataURL('image/png')")).split(",")[1];
  writeFileSync(out, Buffer.from(b64, "base64"));
  console.log(`${out} ${((Date.now() - t0) / 1000).toFixed(1)}s ${await ev("window.__note || ''")}`);
} finally {
  chrome.kill();
  await sleep(300);
  rmSync(profile, { recursive: true, force: true });
}
process.exit(0);
