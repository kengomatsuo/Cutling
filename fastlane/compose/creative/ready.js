// Tells render.mjs the page is drawn: every image decoded, fonts ready, then a long beat so a 3960-wide page
// with 3D layers and blurs has been rastered whole (a short beat captured half-painted pages).
addEventListener("load", async () => {
  await document.fonts.ready;
  await Promise.all([...document.images].map((i) => i.decode().catch(() => {})));
  const frame = () => new Promise((r) => requestAnimationFrame(r));
  for (let i = 0; i < 6; i++) await frame();
  setTimeout(() => { window.__done = true; }, window.READY_WAIT || 1800);   // a page of 3D layers sets READY_WAIT longer
});
