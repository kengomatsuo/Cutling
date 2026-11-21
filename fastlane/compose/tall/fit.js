/* Shrinks each [data-fit] line until the copy column fits its box, then dumps the
   boxes render_cdp.mjs reads (#hypershots-boxes). A column that will not fit at
   data-fit-floor is a failure, so a long locale never renders clipped.
   #wide renders the same page 1440x756 (1.9:1), the cover for link previews and directories. */
if (location.hash === '#wide') document.documentElement.classList.add('wide');
(async () => {
  await document.fonts.ready;
  const failures = [];
  const over = (el) => {
    if (el.dataset.nowrap === '1') {
      const r = document.createRange(); r.selectNodeContents(el);
      if (r.getBoundingClientRect().width > el.clientWidth + 0.5) return true;
    }
    return el.scrollWidth > el.clientWidth + 0.5;
  };
  for (const wrap of document.querySelectorAll('.wrap')) {
    const tall = () => wrap.scrollHeight > wrap.clientHeight + 0.5;
    for (const el of wrap.querySelectorAll('[data-fit]')) {
      const floor = parseFloat(el.dataset.fitFloor || 30);
      let size = parseFloat(getComputedStyle(el).fontSize);
      while ((over(el) || tall()) && size > floor) { size -= 1; el.style.fontSize = size + 'px'; }
    }
    for (const el of wrap.querySelectorAll('[data-fit]')) if (over(el)) failures.push(el.dataset.i18n);
    if (tall()) failures.push('height');
  }
  const box = (el) => { const r = el.getBoundingClientRect(); return { name: el.dataset.protect || el.className, x: r.x, y: r.y, w: r.width, h: r.height }; };
  const dump = {
    panelW: innerWidth, panelH: innerHeight, fitFailures: failures,
    boxes: [...document.querySelectorAll('[data-protect]')].map(box), shots: [], mockups: [],
    copy: [...document.querySelectorAll('[data-i18n]')].map((el) => ({ name: el.dataset.i18n, px: parseFloat(getComputedStyle(el).fontSize) })),
  };
  const s = document.createElement('script'); s.type = 'application/json'; s.id = 'hypershots-boxes';
  s.textContent = JSON.stringify(dump); document.body.appendChild(s);
})();
