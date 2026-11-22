// Direction A, "Fill in the blank": one saved reply goes to five people; each time Cutling asks only for
// the name. Above the real screen, the reply's own sentence, set large, with its blank drawn the way the
// keyboard's fill-in bar draws it (FillInPanel.swift: the waiting blank in green, underlined).
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 13 * B;
  const SENT = (name) => `Hi ${name}, your order ships Friday.`;
  const rounds = [
    { start: 2.2, card: 2.27, panel: 2.42, pick: 3.4, ins: 3.52, name: 'Maya', vi: 0 },
    { start: 4.5, card: 4.72, panel: 4.86, pick: 5.42, ins: 5.54, name: 'Jonas', vi: 1 },
    { start: 6.74, card: 6.92, panel: 7.04, pick: 7.42, ins: 7.52, name: 'Aiko', vi: 2 },
    { start: 7.9, card: 8.04, panel: 8.14, pick: 8.44, ins: 8.54, name: 'Sam', vi: 3 },
    { start: 9.02, card: 9.14, panel: 9.24, pick: 9.5, ins: 9.6, name: 'Lea', vi: 4 },
  ];
  const T = { globeDown: 0.55, menu: 0.72, slide: 1.05, slid: 1.32, globeUp: 1.55, cutling: 1.6, payoff: 5 * B, endCard: 8 * B, globeBack: 11.5 * B, reset: 26.62, rest: 27.5 };
  const values = [...S.seed.names, '__paste'];
  const valueXY = (i) => ({ x: 6 + (i % 3) * (142.67 + 6) + 71.3, y: 587 + 62 + 52 + 6 + Math.floor(i / 3) * 50 + 22 });

  // What the screen shows at t, shared by the iPhone and iPad cuts.
  function stateAt(t) {
    const st = { kb: 'system', menu: 0, text: '', textPrev: '', mix: 1, pressCard: false, inserted: false, fill: null, round: null, blank: null, ask: false };
    if (t >= T.cutling && t < T.globeBack + 0.18) st.kb = 'cutling';
    if (t >= T.menu && t < T.globeUp) st.menu = K.seg(t, T.menu, T.menu + 0.18);
    let r = null;
    for (const x of rounds) if (t >= x.start) r = x;
    if (r) {
      st.round = r;
      const i = rounds.indexOf(r);
      const prev = rounds[i - 1];
      st.text = t >= r.ins ? SENT(r.name) : '';
      st.textPrev = prev ? SENT(prev.name) : '';
      st.mix = K.seg(t, r.start - 0.08, r.start + 0.1);
      if (t >= r.card && t < r.card + 0.14) st.pressCard = true;
      if (t >= r.panel && t < r.ins) {
        st.fill = { press: t >= r.pick && t < r.pick + 0.12 ? r.vi : -1 };
        st.ask = true;
      }
      if (t >= r.ins && t < Math.min(r.ins + 0.7, (rounds[i + 1] || { start: 99 }).start)) st.inserted = true;
      st.blank = t >= r.ins ? r.name : null;
      st.pop = K.seg(t, r.ins, r.ins + 0.35);
    }
    // the end: back to the person's own keyboard, then a fresh message, as at the start
    if (t >= T.reset) { st.textPrev = st.text; st.text = ''; st.mix = K.seg(t, T.reset - 0.1, T.reset + 0.2); st.blank = null; st.ask = false; }
    return st;
  }

  function touches(t, xy) {
    let h = '';
    // hold the globe, slide to Cutling, let go
    if (t > T.globeDown - 0.1 && t < T.globeUp + 0.5) {
      const p = K.ease.inOut(K.seg(t, T.slide, T.slid));
      const x = K.lerp(44, 80, p), y = K.lerp(915, 806, p);
      h += K.touch(x, y, t, T.globeDown, T.globeUp - T.globeDown);
    }
    for (const r of rounds) {
      h += K.touch(xy.card.x, xy.card.y, t, r.card, 0.12);
      const v = xy.value(r.vi);
      h += K.touch(v.x, v.y, t, r.pick, 0.1);
    }
    h += K.touch(44, 915, t, T.globeBack, 0.12);
    return h;
  }

  function phoneScreen(t, st) {
    const cards = S.seed.shop(false);
    let kb;
    if (st.kb === 'system') {
      kb = K.systemKeyboard({}) + (st.menu > 0 ? K.globeMenu({ p: st.menu, chosen: t > T.slid ? 'Cutling' : 'English (US)' }) : '');
    } else if (st.fill) {
      kb = K.cutlingKeyboard({ mode: 'fill', fill: { sentence: K.fillSentence(['Hi ', { label: 'Name', active: true }, ', your order ships Friday.']), values, press: st.fill.press, last: true } });
    } else {
      kb = K.cutlingKeyboard({ cards, press: st.pressCard ? 0 : -1, inserted: st.inserted ? 0 : -1 });
    }
    const field = (text) => K.messagesNew({ to: st.round ? st.round.name : 'Maya', text: K.esc(text) });
    const content = st.mix < 1 && st.textPrev !== st.text
      ? `<div style="position:absolute;inset:0;opacity:${1 - st.mix}">${field(st.textPrev)}</div><div style="position:absolute;inset:0;opacity:${st.mix}">${field(st.text)}</div>`
      : field(st.text);
    return K.iphone({ content, keyboard: kb, over: touches(t, { card: { x: 112, y: 687 }, value: valueXY }) });
  }

  // The reply set large. The blank is the keyboard's: green underline while it waits, the name once filled.
  function bigSentence(t, st, { size, x, y, w, labelSize }) {
    const mint = K.C.accentDk;
    const name = st.blank;
    const pop = name ? 1 + 0.06 * Math.sin(Math.PI * K.clamp(st.pop)) : 1;
    const nameCol = name ? (st.pop < 1 ? mint : '#fff') : mint;
    const under = name ? `rgba(58,214,166,${0.9 * (1 - K.ease.out(K.clamp(st.pop)))})` : mint;
    const thick = st.ask ? size * 0.11 : size * 0.085;
    const blank = `<span style="display:inline-block;position:relative;width:${size * 2.85}px;height:${size * 1.02}px;vertical-align:${-size * 0.2}px;margin:0 ${size * 0.06}px">
        <span style="position:absolute;left:0;right:0;bottom:${size * 0.02}px;height:${thick}px;border-radius:${thick}px;background:${under}"></span>
        <span style="position:absolute;left:0;right:0;bottom:${size * 0.12}px;text-align:center;color:${nameCol};transform:scale(${pop});transform-origin:50% 80%">${name ? K.esc(name) : ''}</span>
        <span style="position:absolute;left:0;right:0;bottom:${size * 0.24}px;text-align:center;font:600 ${labelSize}px/1 -apple-system,system-ui;letter-spacing:.12em;text-transform:uppercase;color:${mint};opacity:${name ? 0 : (st.ask ? 1 : 0.85)}">Name</span>
      </span>`;
    return S.text(`Hi${blank},<br>your order<br>ships Friday.`, { x, y, w, size, lh: 1.16 });
  }

  function stack(t, { x, y, size, gap, w }) {
    return rounds.map((r, i) => {
      const p = K.ease.out(K.seg(t, T.payoff + i * 0.1, T.payoff + i * 0.1 + 0.5));
      return S.text(`Hi <span style="color:${K.C.accentDk}">${r.name}</span>, your order ships Friday.`, { x, y: y + i * gap + (1 - p) * 30, w, size, weight: 600, opacity: p, lh: 1.2, ls: '-0.01em' });
    }).join('');
  }

  const caps = (t) => S.fades(t, [[0, 'c1'], [2.6, 'c2'], [T.payoff, 'c3'], [T.endCard, 'end'], [T.reset, 'c1']], 0.34);
  const LINES = {
    c1: 'One saved reply. A different name every time.',
    c2: 'Cutling asks for the name',
    c3: 'Two taps for each reply',
  };

  function typeZone(t, st, d) {
    const f = caps(t);
    const bg = `<div style="position:absolute;inset:0;background:linear-gradient(180deg,${K.C.bandFrom} 0%,${K.C.bandTo} 100%)"></div>`;
    let h = bg;
    for (const k of ['c1', 'c2', 'c3']) if (f[k] > 0.001) h += S.text(LINES[k], { x: d.x, y: d.capY, w: d.w, size: d.capSize, weight: 600, color: 'rgba(255,255,255,.78)', lh: 1.18, ls: '-0.01em', opacity: f[k] });
    const sentOp = Math.max(f.c1 || 0, f.c2 || 0);
    if (sentOp > 0.001) h += `<div style="opacity:${sentOp}">${bigSentence(t, st, d.sentence)}</div>`;
    if ((f.c3 || 0) > 0.001) h += `<div style="opacity:${f.c3}">${stack(t, d.stack)}</div>`;
    if ((f.end || 0) > 0.001) {
      h += S.text(d.end.br ? 'Write it<br>once.' : 'Write it once.', { x: d.x, y: d.end.y, w: d.w, size: d.end.size, opacity: f.end, lh: 1.02 });
      h += S.brand({ x: d.x, y: d.end.brandY, icon: d.end.icon, size: d.end.brandSize, opacity: f.end });
    }
    return h;
  }

  // ---------- iPhone 886 x 1920: type above, the screen's lower half below at its own resolution ----------
  const iphone = {
    W: 886, H: 1920, L,
    draw(t) {
      const st = stateAt(t);
      const zone = 880, s = 886 / 440;
      const clipTop = 956 - (1920 - zone) / s;
      return typeZone(t, st, {
        x: 72, w: 742, capY: 132, capSize: 48,
        sentence: { x: 72, y: 330, w: 760, size: 112, labelSize: 36 },
        stack: { x: 72, y: 318, size: 44, gap: 92, w: 760 },
        end: { y: 250, size: 158, brandY: 640, icon: 120, brandSize: 60, br: true },
      }) + S.place(phoneScreen(t, st), { x: 0, y: zone, s, clipTop, radius: '64px 64px 0 0' });
    },
    stills: [
      { t: 0.0, name: 'iphone-01', note: 'Frame 0 and poster: the reply with its blank' },
      { t: 1.25, name: 'iphone-02', note: 'Holding the globe: Cutling in the keyboard list' },
      { t: 3.1, name: 'iphone-03', note: 'Cutling asks for the name, past names one tap away' },
      { t: 3.75, name: 'iphone-04', note: 'Maya is in, the reply is typed' },
      { t: 8.5, name: 'iphone-05', note: 'Faster each round: Sam' },
      { t: 13.2, name: 'iphone-06', note: 'Five replies, two taps each' },
      { t: 21.0, name: 'iphone-07', note: 'End: Write it once' },
    ],
    poster: 3.1,
    seam: {
      kind: 'rest',
      signals: {
        'first line (opacity)': (t) => caps(t).c1 || 0,
        'end card (opacity)': (t) => caps(t).end || 0,
        'message reset (dissolve)': (t) => (t >= T.reset - 0.1 ? K.ease.inOut(K.seg(t, T.reset - 0.1, T.reset + 0.2)) : (t < L / 2 ? 1 : 0)),
        'blank fill': (t) => { const st = stateAt(t); return st.blank ? 1 : 0; },
      },
    },
  };

  // ---------- iPad 1200 x 1600 ----------
  function ipadScreen(t, st) {
    const cards = S.seed.shop(false).concat([
      { name: 'Opening hours', icon: 'clock', color: '#7a5af5', preview: 'Mon–Sat 10–6, Sun closed' },
      { name: 'Returns', icon: 'return', color: '#e0559b', preview: 'Send it back within 30 days and…' },
      { name: 'Size guide', icon: 'ruler', color: '#16a5b8', preview: 'S 36–38 · M 40–42 · L 44–46' },
      { name: 'Directions', icon: 'pin', color: '#f08a24', preview: 'Second floor, above the bakery' },
    ]);
    let kb;
    if (st.fill) kb = K.ipadCutlingKeyboard({ mode: 'fill', fill: { sentence: K.fillSentence(['Hi ', { label: 'Name', active: true }, ', your order ships Friday.']), values, last: true, press: st.fill.press } });
    else kb = K.ipadCutlingKeyboard({ cards, press: st.pressCard ? 0 : -1, inserted: st.inserted ? 0 : -1 });
    return K.ipad({ content: K.ipadMessages({ to: st.round ? st.round.name : 'Maya', text: K.esc(st.text) }), keyboard: kb });
  }
  const ipad = {
    W: 1200, H: 1600, L,
    draw(t) {
      const st = stateAt(t);
      if (st.kb === 'system') { st.kb = 'cutling'; }
      const zone = 640, s = 1200 / 1032;
      const clipTop = 1376 - (1600 - zone) / s;
      return typeZone(t, st, {
        x: 84, w: 1040, capY: 96, capSize: 46,
        sentence: { x: 84, y: 200, w: 1040, size: 104, labelSize: 34 },
        stack: { x: 84, y: 190, size: 46, gap: 80, w: 1040 },
        end: { y: 210, size: 128, brandY: 400, icon: 116, brandSize: 60 },
      }) + S.place(ipadScreen(t, st), { x: 0, y: zone, s, w: 1032, h: 1376, clipTop, radius: '40px 40px 0 0' });
    },
    stills: [{ t: 3.1, name: 'ipad-01', note: 'iPad: the keyboard asks across the full width' }],
  };

  // ---------- Mac 1920 x 1080: the sentence in a column, the desktop beside it ----------
  const mac = {
    W: 1920, H: 1080, L,
    draw(t) {
      // The Mac takes the same beats: ⌘⇧V, the picker's form asks for the name, Paste.
      const asking = t < 5;
      const name = asking ? null : 'Maya';
      const st = { blank: name, pop: 1, ask: asking };
      const s = 1.2;
      const body = name ? `Hi Maya, your order ships Friday.` : '';
      const desk = K.macDesktop({}) + K.macMenuBar({ app: 'Notes', cutlingActive: asking }) +
        K.macNotes({ x: 520, y: 120, w: 760, h: 600, to: 'Maya', subject: 'Your order', body }) +
        (asking ? K.macPicker({ x: 740, y: 250, mode: 'form', form: { name: 'Order update', icon: 'box', fields: [{ label: 'Name', value: '', focus: true, chips: S.seed.names }], preview: `Hi ${K.pill('Name', false, 12)}, your order ships Friday.`, button: 'Paste' } }) : '');
      const left = `<div style="position:absolute;left:0;top:0;width:700px;height:1080px;background:linear-gradient(180deg,${K.C.bandFrom},${K.C.bandTo})"></div>` +
        S.text(asking ? 'Cutling asks for the name' : 'One saved reply. A different name every time.', { x: 72, y: 120, w: 560, size: 40, weight: 600, color: 'rgba(255,255,255,.78)', lh: 1.2 }) +
        bigSentence(t, st, { x: 72, y: 330, w: 600, size: 92, labelSize: 30 });
      return S.place(desk, { x: 420, y: 0, s, w: 1512, h: 982 }) + left +
        (asking ? K.keycaps(['⌘', '⇧', 'V'], 1520, 880, 92, 1, true) : '');
    },
    stills: [{ t: 2, name: 'mac-01', note: 'Mac: ⌘⇧V, the picker asks for the name, past names as chips' }, { t: 8, name: 'mac-02', note: 'Mac: pasted into Mail with the name in' }],
  };

  window.FILMS['a-blank'] = { iphone, ipad, mac };
})();
