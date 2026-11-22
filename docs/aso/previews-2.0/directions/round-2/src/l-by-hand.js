// Direction L, "By hand": an overview of what Cutling is by what it saves you. Two lanes, the same message:
// above, someone types it on the iPhone's own keyboard at an ordinary thumb pace; below, Cutling puts in the
// address, the bank details, a reply that asks for the name (2.0), the Wi-Fi and a thank-you before the hand
// has finished the second of them (Cutling is done at 9.8 s; the hand reaches the end of the bank details at
// 13.8 s). No timer or counter is laid over it; the two fields say it.
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 11 * B;
  const full = '14 Linden Road, Flat 3. Account 0441 2290 18. Hi Maya, your order ships Friday. studio-guest · fern2291. Thank you so much for your order!';
  const typeStart = 0.6, cps = 3.4;   // an ordinary pace on a phone keyboard, about 40 words a minute
  const T = { globeDown: 0.3, globeUp: 1.3, slide: 0.8, cutling: 1.35, end: 8 * B };
  const taps = [
    { at: 1.9, card: 0, text: '14 Linden Road, Flat 3.' },
    { at: 3.6, card: 2, text: 'Account 0441 2290 18.' },
    { at: 5.3, card: 1, fill: 6.2, text: 'Hi Maya, your order ships Friday.' },
    { at: 8.0, card: 4, text: 'studio-guest · fern2291.' },
    { at: 9.7, card: 5, text: 'Thank you so much for your order!' },
  ];
  const cards = K.everyday(false);

  function handLane(t) {
    const n = Math.max(0, Math.min(full.length, Math.floor((Math.min(t, T.end) - typeStart) * cps)));
    const typed = full.slice(0, n);
    const ch = full[n] || '';
    const key = /[a-z]/i.test(ch) ? ch.toLowerCase() : null;
    const kb = K.systemKeyboard({ pressKey: t < T.end ? key : null, predict: ['Flat', 'Road', 'the'] });
    return K.iphone({ content: K.messagesNew({ to: 'Maya', text: K.esc(typed) }), keyboard: kb });
  }
  function cutlingLane(t) {
    let text = '';
    for (const b of taps) if (t >= (b.fill || b.at) + 0.12) text += (text ? ' ' : '') + b.text;
    let kb;
    if (t < T.cutling) kb = K.systemKeyboard({}) + (t >= T.globeDown + 0.2 && t < T.globeUp ? K.globeMenu({ p: K.seg(t, T.globeDown + 0.2, T.globeDown + 0.4), chosen: t > T.slide + 0.2 ? 'Cutling' : 'English (US)' }) : '');
    else {
      const asking = taps.find((b) => b.fill && t >= b.at + 0.14 && t < b.fill + 0.12);
      if (asking) kb = K.orderFill(t >= asking.fill && t < asking.fill + 0.12 ? 0 : -1);
      else {
        const press = taps.find((b) => t >= b.at && t < b.at + 0.12);
        const ins = taps.find((b) => { const a = (b.fill || b.at) + 0.12; return t >= a && t < a + 0.7; });
        kb = K.cutlingKeyboard({ cards, press: press ? press.card : -1, inserted: ins ? ins.card : -1 });
      }
    }
    let over = K.globeTouch(t, T.globeDown, T.globeUp, T.slide);
    for (const b of taps) { over += K.touch(K.cardXY(b.card).x, K.cardXY(b.card).y, t, b.at, 0.1); if (b.fill) over += K.touch(K.valueXY(0).x, K.valueXY(0).y, t, b.fill, 0.1); }
    return K.iphone({ content: K.messagesNew({ to: 'Maya', text: K.esc(text) }), keyboard: kb, over });
  }

  function lanes(t, d) {
    let h = `<div style="position:absolute;left:0;top:0;width:${d.W}px;height:${d.H / 2}px;background:${K.C.paper}"></div><div style="position:absolute;left:0;top:${d.H / 2}px;width:${d.W}px;height:${d.H / 2}px;background:${K.C.tint}"></div>`;
    const laneH = d.H / 2 - d.labelH - d.gap, s = laneH / (956 - d.clipTop), w = 440 * s, x = (d.W - w) / 2;
    h += S.text('Typing it', { x: d.x, y: d.labelY, w: 500, size: d.label, color: '#1c1c1e', lh: 1 });
    h += S.place(handLane(t), { x, y: d.labelH, s, clipTop: d.clipTop, radius: `${40 * s}px`, shadow: '0 16px 40px rgba(0,0,0,.12)' });
    h += S.text('With Cutling', { x: d.x, y: d.H / 2 + d.labelY, w: 600, size: d.label, color: K.C.bandFrom, lh: 1 });
    h += S.place(cutlingLane(t), { x, y: d.H / 2 + d.labelH, s, clipTop: d.clipTop, radius: `${40 * s}px`, shadow: '0 16px 40px rgba(0,0,0,.12)' });
    return h;
  }

  function frame(t, d) {
    const end = K.ease.inOut(K.seg(t, T.end, T.end + 0.4));
    let h = end < 1 ? lanes(t, d) : '';
    if (end > 0) h += `<div style="position:absolute;inset:0;background:${K.C.paper};opacity:${end}">` +
      S.text('Stop typing<br>the same things.', { x: d.x, y: d.ey, w: d.w, size: d.endSize, color: '#1c1c1e', lh: 1.02 }) +
      S.text('On iPhone, iPad and Mac,<br>with one purchase', { x: d.x + 4, y: d.ey + d.endSize * 2.3, w: d.w, size: d.sub, weight: 600, color: K.C.accent, lh: 1.2 }) +
      S.brand({ x: d.x, y: d.ey + d.endSize * 2.3 + d.sub * 3.1, icon: d.icon, size: d.brand, color: '#1c1c1e' }) + `</div>`;
    return h;
  }

  const iphone = {
    W: 886, H: 1920, L, loopDissolve: 0.6,
    draw: (t) => frame(t, { W: 886, H: 1920, x: 64, w: 760, label: 64, labelY: 40, labelH: 130, gap: 26, clipTop: 420, ey: 640, endSize: 84, sub: 44, icon: 104, brand: 54 }),
    stills: [
      { t: 0, name: 'iphone-01', note: 'Frame 0: the same message, typed or tapped' },
      { t: 2.4, name: 'iphone-02', note: 'Cutling has the address in; the hand is on “14 Lin”' },
      { t: 6.0, name: 'iphone-03', note: 'Cutling asks for the name; the hand is still on the address' },
      { t: 10.5, name: 'iphone-04', note: 'Cutling has put in five things' },
      { t: 15.5, name: 'iphone-05', note: 'The hand is on the third of five; Cutling finished at 9.8 s' },
      { t: 20.0, name: 'iphone-06', note: 'End: Stop typing the same things' },
    ],
    poster: 6.0,
    seam: { kind: 'dissolve', signals: { 'end card (opacity)': (t) => K.ease.inOut(K.seg(t, T.end, T.end + 0.4)) } },
  };

  // iPad: the race at the iPad's width, two lanes stacked
  const ipad = {
    W: 1200, H: 1600, L,
    draw() {
      const t = 6.6;
      const n = Math.floor((t - typeStart) * cps);
      const top = K.ipad({ content: K.ipadMessages({ to: 'Maya', text: K.esc(full.slice(0, n)), list: false }) });
      const bottom = K.ipad({ content: K.ipadMessages({ to: 'Maya', text: K.esc(taps.slice(0, 3).map((b) => b.text).join(' ')), list: false }), keyboard: K.ipadCutlingKeyboard({ cards: cards.concat([{ name: 'Size chart', icon: 'photo', color: '#7a5af5', preview: 'Image · S, M, L, XL' }]) }) });
      const s = 0.98, crop = 1376 - 700 / s;
      return `<div style="position:absolute;left:0;top:0;width:1200px;height:800px;background:${K.C.paper}"></div><div style="position:absolute;left:0;top:800px;width:1200px;height:800px;background:${K.C.tint}"></div>` +
        S.text('Typing it', { x: 84, y: 26, w: 600, size: 56, color: '#1c1c1e' }) + S.text('With Cutling', { x: 84, y: 826, w: 600, size: 56, color: K.C.bandFrom }) +
        S.place(top, { x: (1200 - 1032 * s) / 2, y: 100, s, w: 1032, h: 1376, clipTop: crop, radius: '24px' }) +
        S.place(bottom, { x: (1200 - 1032 * s) / 2, y: 900, s, w: 1032, h: 1376, clipTop: crop, radius: '24px' });
    },
    stills: [{ t: 0, name: 'ipad-01', note: 'iPad: the two lanes' }],
  };

  // Mac: typing the address by hand beside ⌘⇧V pasting it
  const mac = {
    W: 1920, H: 1080, L,
    draw() {
      const desk1 = K.macDesktop({}) + K.macNotes({ x: 60, y: 60, w: 620, h: 420, body: '14 Linden Road, Fl' });
      const desk2 = K.macDesktop({}) + K.macNotes({ x: 60, y: 60, w: 620, h: 420, body: '14 Linden Road, Flat 3. Account 0441 2290 18. Hi Maya, your order ships Friday. studio-guest · fern2291.' });
      return `<div style="position:absolute;inset:0;background:${K.C.paper}"></div>` +
        S.text('Typing it', { x: 90, y: 60, w: 700, size: 60, color: '#1c1c1e' }) + S.text('With ⌘⇧V', { x: 1000, y: 60, w: 700, size: 60, color: K.C.bandFrom }) +
        S.place(desk1, { x: 60, y: 170, s: 1.12, w: 740, h: 540, radius: '20px', shadow: '0 16px 40px rgba(0,0,0,.12)' }) +
        S.place(desk2, { x: 990, y: 170, s: 1.12, w: 740, h: 540, radius: '20px', shadow: '0 16px 40px rgba(0,0,0,.12)' }) +
        S.text('Stop typing the same things.', { x: 90, y: 860, w: 1700, size: 64, color: '#1c1c1e' });
    },
    stills: [{ t: 0, name: 'mac-01', note: 'Mac: by hand beside ⌘⇧V' }],
  };

  window.FILMS['l-by-hand'] = { iphone, ipad, mac };
})();
