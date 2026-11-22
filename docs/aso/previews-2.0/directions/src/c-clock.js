// Direction C, "Around the clock": the same two saved replies typed at 9:12 in the morning, 2:20 in the
// afternoon and 9:40 at night. Each time the clock above turns into the greeting Cutling typed, the order
// number goes up by one, and the ground moves from morning to night and back, so the loop never stops.
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 13 * B;
  const takes = [
    { from: 0, to: 8.75, dark: false, clock: '9:12', ampm: 'AM', time: '9:12 AM', greet: 'Good morning', to_: 'Ana', order: 1041, globe: true, hello: 2.0, ship: 3.6 },
    { from: 8.75, to: 17.8, dark: false, clock: '2:20', ampm: 'PM', time: '2:20 PM', greet: 'Good afternoon', to_: 'Ben', order: 1042, hello: 10.2, ship: 11.6 },
    { from: 17.8, to: L, dark: true, clock: '9:40', ampm: 'PM', time: '9:40 PM', greet: 'Good evening', to_: 'Chloe', order: 1043, hello: 19.3, ship: 20.7 },
  ];
  const T = { endCard: 22.5, back: 27.05 };
  const grounds = [['#eaf7f1', '#cdeee0'], ['#08c38b', '#04986b'], ['#0b3b2e', '#04140f']];
  const mixHex = (a, b, p) => {
    const pa = [1, 3, 5].map((i) => parseInt(a.slice(i, i + 2), 16)), pb = [1, 3, 5].map((i) => parseInt(b.slice(i, i + 2), 16));
    return '#' + pa.map((v, i) => Math.round(K.lerp(v, pb[i], p)).toString(16).padStart(2, '0')).join('');
  };
  // how far the ground has moved from morning (0) to afternoon (1) to night (2) and back to morning (3 = 0)
  function dayPhase(t) {
    const e = K.ease.inOut;
    if (t < 8.35) return 0;
    if (t < 9.35) return e(K.seg(t, 8.35, 9.35));
    if (t < 17.4) return 1;
    if (t < 18.4) return 1 + e(K.seg(t, 17.4, 18.4));
    if (t < T.back) return 2;
    return 2 + e(K.seg(t, T.back, L));
  }
  function ground(t) {
    const ph = dayPhase(t) % 3;
    const i = Math.floor(ph), p = ph - i, j = (i + 1) % 3;
    return [mixHex(grounds[i][0], grounds[j][0], p), mixHex(grounds[i][1], grounds[j][1], p)];
  }
  // the screen floats on one slow sine whose period is the film, so its motion runs on across the seam
  const floatY = (t) => 16 * Math.sin((2 * Math.PI * t) / L);
  const floatS = (t) => 1.42 + 0.012 * Math.sin((2 * Math.PI * t) / L + 1.1);

  const cards = (dark, k) => {
    const p = (s) => K.pill(s, dark);
    return [
      { name: 'Hello', icon: 'wave', color: '#f0a020', preview: `${p(k.greet)}! Thanks for your message.` },
      { name: 'Order shipped', icon: 'box', color: K.C.brand, preview: `Your order #${p(String(k.order))} went out at ${p(k.time)}` },
      { name: 'Opening hours', icon: 'clock', color: '#7a5af5', preview: 'Mon–Sat 10–6, Sun closed' },
      { name: 'Returns', icon: 'return', color: '#e0559b', preview: 'Send it back within 30 days and…' },
      { name: 'Home address', icon: 'house', color: '#2f7cf6', preview: '14 Linden Road, Flat 3' },
      { name: 'Thank you', icon: 'sparkle', color: '#e0559b', preview: 'Thank you so much for your order!' },
    ];
  };
  const takeAt = (t) => takes.find((k) => t >= k.from && t < k.to) || takes[2];

  function screen(t, k) {
    const dark = k.dark;
    const hi = t >= k.hello + 0.1, sh = t >= k.ship + 0.1;
    let text = '';
    if (hi) text += `${k.greet}! Thanks for your message.`;
    if (sh) text += ` Your order #${k.order} went out at ${k.time} and arrives Friday.`;
    const menu = k.globe && t >= 0.62 && t < 1.45 ? K.globeMenu({ dark, p: K.seg(t, 0.62, 0.8), chosen: t > 1.2 ? 'Cutling' : 'English (US)' }) : '';
    const sys = k.globe && t < 1.5;
    const kb = sys ? K.systemKeyboard({ dark }) + menu
      : K.cutlingKeyboard({ dark, cards: cards(dark, k), press: (t >= k.hello && t < k.hello + 0.12) ? 0 : (t >= k.ship && t < k.ship + 0.12 ? 1 : -1), inserted: t >= k.hello + 0.1 && t < k.hello + 0.7 ? 0 : (t >= k.ship + 0.1 && t < k.ship + 0.7 ? 1 : -1) });
    let over = K.touch(112, 687, t, k.hello, 0.1, dark) + K.touch(329, 687, t, k.ship, 0.1, dark);
    if (k.globe) {
      const p = K.ease.inOut(K.seg(t, 0.95, 1.2));
      over += K.touch(K.lerp(44, 80, p), K.lerp(915, 806, p), t, 0.45, 1.0, dark);
    }
    return K.iphone({ dark, time: k.clock, content: K.messagesNew({ dark, to: k.to_, text: K.esc(text) }), keyboard: kb, over });
  }

  // above the screen: the take's clock, which turns into the greeting Cutling typed
  function bigType(t, k, d) {
    const p = K.ease.inOut(K.seg(t, k.hello + 0.05, k.hello + 0.4));
    const light = dayPhase(t) > 0.5 && dayPhase(t) < 2.5;
    const col = light ? '#fff' : K.C.bandFrom;
    const clock = S.text(`${k.clock}<span style="font-size:${d.clock * 0.3}px;font-weight:500;margin-left:${d.clock * 0.06}px;letter-spacing:0">${k.ampm}</span>`, { x: d.x, y: d.y, w: d.w, size: d.clock, weight: 300, color: col, ls: '-0.03em', lh: 1, opacity: 1 - p, extra: `transform:translateY(${-p * 30}px)` });
    const greet = S.text(`${k.greet.replace(' ', '<br>')}`, { x: d.x, y: d.y + d.clock * 0.18, w: d.w, size: d.greet, weight: 700, color: col, lh: 1.02, opacity: p, extra: `transform:translateY(${(1 - p) * 30}px)` });
    const q = K.ease.out(K.seg(t, k.ship + 0.1, k.ship + 0.5));
    const filled = d.detail ? S.text(`#${k.order}&nbsp;&nbsp;·&nbsp;&nbsp;${k.time}&nbsp;&nbsp;·&nbsp;&nbsp;Friday`, { x: d.x, y: d.detailY, w: d.w, size: d.detail, weight: 600, color: light ? K.C.tint : K.C.accent, ls: '0', opacity: q * p, extra: `transform:translateY(${(1 - q) * 14}px)` }) : '';
    return clock + greet + filled;
  }

  const LINE = 'The same saved reply, three times a day';
  function frameAt(t, d) {
    const [g0, g1] = ground(t);
    let h = `<div style="position:absolute;inset:0;background:linear-gradient(180deg,${g0} 0%,${g1} 100%)"></div>`;
    const k = takeAt(t);
    const light = dayPhase(t) > 0.5 && dayPhase(t) < 2.5;
    const end = K.seg(t, T.endCard, T.endCard + 0.4) * (1 - K.seg(t, T.back, T.back + 0.4));
    // the words: the take's clock or greeting; then the end card; then back to the morning clock
    const morningBack = t >= T.back ? K.ease.inOut(K.seg(t, T.back + 0.2, L - 0.4)) : 0;
    if (t < T.back) h += `<div style="opacity:${1 - end}">${bigType(t, k, d)}</div>`;
    h += S.text(LINE, { x: d.x, y: d.lineY, w: d.w, size: d.line, weight: 600, color: light ? 'rgba(255,255,255,.86)' : 'rgba(11,59,46,.8)', lh: 1.2, ls: '-0.01em', opacity: (1 - end) * (t < T.back ? 1 : morningBack) });
    if (end > 0.001) {
      h += S.text('Right at<br>any hour.', { x: d.x, y: d.y + d.clock * 0.18, w: d.w, size: d.greet, color: '#fff', opacity: end, lh: 1.02 });
      h += S.brand({ x: d.x, y: d.lineY, icon: d.icon, size: d.brand, opacity: end });
    }
    if (t >= T.back) h += `<div style="opacity:${morningBack}">${bigType(0, takes[0], d)}</div>`;
    // the screen: each take dissolves into the next; at the end the night take dissolves into the morning's first frame
    const s = floatS(t) * d.s0, x = (d.W - 440 * s) / 2, y = d.screenY + floatY(t) * d.s0 / 1.42;
    const place = (html, op) => S.place(html, { x, y, s, radius: `${62 * s}px`, shadow: '0 40px 90px rgba(0,0,0,.25)', opacity: op });
    const cut = (a) => K.seg(t, a - 0.25, a + 0.25);
    if (t < takes[0].to + 0.25) h += place(screen(Math.min(t, takes[0].to), takes[0]), 1);
    if (t >= takes[1].from - 0.25 && t < takes[1].to + 0.25) h += place(screen(t, takes[1]), cut(takes[1].from));
    if (t >= takes[2].from - 0.25) h += place(screen(Math.min(t, T.back + 1.2), takes[2]), cut(takes[2].from));
    if (t >= L - 0.9) h += place(screen(0, takes[0]), K.ease.inOut(K.seg(t, L - 0.9, L)));
    return h;
  }

  const iphone = {
    W: 886, H: 1920, L,
    draw: (t) => frameAt(t, { W: 886, x: 72, y: 84, w: 760, clock: 230, greet: 112, line: 40, lineY: 446, detail: 40, detailY: 378, icon: 100, brand: 52, s0: 1, screenY: 560 }),
    stills: [
      { t: 0, name: 'iphone-01', note: 'Frame 0: 9:12 in the morning' },
      { t: 1.2, name: 'iphone-02', note: 'Holding the globe: Cutling' },
      { t: 4.6, name: 'iphone-03', note: 'Good morning, order 1041, 9:12 AM' },
      { t: 13.4, name: 'iphone-04', note: 'Good afternoon, order 1042, 2:20 PM' },
      { t: 21.8, name: 'iphone-05', note: 'Good evening in dark mode, order 1043, 9:40 PM' },
      { t: 25.0, name: 'iphone-06', note: 'End: Right at any hour' },
      { t: 28.6, name: 'iphone-07', note: 'Night turning back into morning: the loop' },
    ],
    poster: 4.6,
    seam: {
      kind: 'seamless',
      signals: {
        'screen float y (px)': (t) => floatY(t),
        'screen scale': (t) => floatS(t),
        // brightness is linear in the colours mixed, so it is mixed here unrounded, as the picture mixes them
        'ground brightness (top colour)': (t) => {
          const lum = (c) => [1, 3, 5].reduce((a, i, j) => a + [0.2126, 0.7152, 0.0722][j] * parseInt(c.slice(i, i + 2), 16) / 255, 0);
          const ph = dayPhase(t) % 3, i = Math.floor(ph), p = ph - i;
          return K.lerp(lum(grounds[i][0]), lum(grounds[(i + 1) % 3][0]), p);
        },
      },
    },
  };

  // iPad: the same clock-to-greeting move, the iPad floating under it
  const ipad = {
    W: 1200, H: 1600, L,
    draw(t) {
      const k = takeAt(t);
      const [g0, g1] = ground(t);
      const light = dayPhase(t) > 0.5 && dayPhase(t) < 2.5;
      const dark = k.dark;
      let text = '';
      if (t >= k.hello + 0.1) text += `${k.greet}! Thanks for your message.`;
      if (t >= k.ship + 0.1) text += ` Your order #${k.order} went out at ${k.time} and arrives Friday.`;
      const ipadCards = cards(dark, k).concat([{ name: 'Size guide', icon: 'ruler', color: '#16a5b8', preview: 'S 36–38 · M 40–42' }, { name: 'Directions', icon: 'pin', color: '#f08a24', preview: 'Second floor, above the bakery' }]);
      const scr = K.ipad({ dark, time: k.clock, content: K.ipadMessages({ dark, to: k.to_, text: K.esc(text) }), keyboard: K.ipadCutlingKeyboard({ dark, cards: ipadCards, inserted: 1 }) });
      return `<div style="position:absolute;inset:0;background:linear-gradient(180deg,${g0},${g1})"></div>` + bigType(t, k, { x: 84, y: 70, w: 1032, clock: 170, greet: 100 }) +
        S.text(LINE, { x: 84, y: 330, w: 1032, size: 42, weight: 600, color: light ? 'rgba(255,255,255,.86)' : 'rgba(11,59,46,.8)' }) +
        S.place(scr, { x: (1200 - 1032 * 0.9) / 2, y: 430, s: 0.9, w: 1032, h: 1376, radius: '30px', shadow: '0 40px 90px rgba(0,0,0,.28)' });
    },
    stills: [{ t: 13.4, name: 'ipad-01', note: 'iPad: Good afternoon at 2:20 PM' }],
  };

  // Mac: the real menu bar clock reads the hour; ⌘⇧V pastes the greeting into Mail
  const mac = {
    W: 1920, H: 1080, L,
    draw(t) {
      const k = takes[2];
      const body = `${k.greet}! Thanks for your message. Your order #${k.order} went out at ${k.time} and arrives Friday.`;
      const desk = K.macDesktop({ dark: true }) + K.macMenuBar({ dark: true, app: 'Notes', time: 'Thu 9:40 PM' }) + K.macNotes({ dark: true, x: 600, y: 120, w: 760, h: 560, to: 'Chloe', subject: 'Your order', body });
      return S.place(desk, { x: 0, y: 0, s: 1920 / 1512, w: 1512, h: 982, clipBottom: 982 - 1080 / (1920 / 1512) }) +
        `<div style="position:absolute;left:0;top:0;width:820px;height:1080px;background:linear-gradient(90deg,rgba(11,59,46,.96) 0%,rgba(11,59,46,.92) 70%,rgba(11,59,46,0) 100%)"></div>` +
        bigType(t, k, { x: 90, y: 230, w: 680, clock: 180, greet: 104 }) + S.text(LINE, { x: 90, y: 540, w: 600, size: 38, weight: 600, color: 'rgba(255,255,255,.86)' });
    },
    stills: [{ t: 21, name: 'mac-01', note: 'Mac at night: Good evening, order 1043, 9:40 PM, the menu bar clock agreeing' }],
  };

  window.FILMS['c-clock'] = { iphone, ipad, mac };
})();
