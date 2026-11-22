// Direction K, "Every key, a whole sentence": an overview of what Cutling is by what one key holds. Dark; the
// lower half is the real keyboard in Messages at its own resolution; above it, whatever the last key typed is
// set huge: an address, bank details, the Wi-Fi, a reply that asks for the name (2.0), a photo, a welcome note
// with its list (2.0), and then a fast scroll through a keyboard with room for 5,000 (2.0). A keyboard types plain
// text, so a formatted cutling arrives with its list markers and without its bold (KeyboardViewController.swift).
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 12 * B;
  const p = (s) => K.pill(s, true);
  const keys = [
    { name: 'Home address', icon: 'house', color: '#5e9bff', preview: '14 Linden Road, Flat 3', text: '14 Linden Road,<br>Flat 3' },
    { name: 'Bank details', icon: 'bank', color: '#4cc38a', preview: 'Account 0441 2290 18', text: 'Account<br>0441 2290 18' },
    { name: 'Wi-Fi', icon: 'wifi', color: '#3ac3d6', preview: 'studio-guest · fern2291', text: 'studio-guest<br>fern2291' },
    { name: 'Order update', icon: 'box', color: K.C.accentDk, preview: `Hi ${p('Name')}, your order ships ${p('Friday')}.`, text: 'Hi Maya, your order ships Friday.' },
    { name: 'Size chart', icon: 'photo', color: '#a68bff', preview: 'Image · S, M, L, XL', photo: true },
    { name: 'Studio welcome', icon: 'sparkle', color: '#ff7ab6', preview: 'Welcome to the studio! • Door code 4815…', rich: true },
  ];
  const taps = [2.3, 4.55, 6.8, 9.07, 12.4, 14.7];
  // what the welcome key types: its text, each list line keeping its bullet (RichText.plainText)
  const WELCOME = 'Welcome to the studio!<br>• Door code 4815<br>• Wi-Fi: studio-guest<br>• Parking behind the bakery';
  const T = { globeDown: 0.5, globeUp: 1.5, slide: 1.0, cutling: 1.55, maya: 9.07 + 1.1, scroll: 7 * B + 0.3, scrollEnd: 9 * B - 0.2, end: 9 * B };

  function current(t) {
    let k = -1;
    taps.forEach((a, i) => { if (t >= a + 0.12) k = i; });
    return k;
  }
  function keyboard(t) {
    if (t < T.cutling) return K.systemKeyboard({ dark: true }) + (t >= T.globeDown + 0.2 && t < T.globeUp ? K.globeMenu({ dark: true, p: K.seg(t, T.globeDown + 0.2, T.globeDown + 0.4), chosen: t > T.slide + 0.2 ? 'Cutling' : 'English (US)' }) : '');
    if (t >= taps[3] + 0.14 && t < T.maya + 0.1) return K.orderFill(t >= T.maya && t < T.maya + 0.12 ? 0 : -1, true);
    const press = taps.findIndex((a) => t >= a && t < a + 0.12);
    const ins = taps.findIndex((a, i) => { const done = i === 3 ? T.maya + 0.1 : a + 0.12; return t >= done && t < done + 0.7; });
    // the scroll: the keyboard runs through a long library and settles
    const many = [];
    for (let i = 0; i < 60; i++) many.push(keys[i % keys.length]);
    const scroll = t >= T.scroll ? 1800 * K.ease.inOut(K.seg(t, T.scroll, T.scrollEnd)) : 0;
    return K.cutlingKeyboard({ dark: true, cards: t >= T.scroll ? many : keys, press, inserted: ins, insertedLabel: ins === 4 ? 'Copied' : 'Inserted', scroll });
  }
  function screen(t) {
    const k = current(t);
    const field = k < 0 ? '' : k === 3 && t < T.maya + 0.1 ? '' : k === 4 ? ' ' : k === 5 ? WELCOME : K.esc(keys[k].text.replace('<br>', ' '));
    let content = K.messagesNew({ dark: true, to: 'Maya', text: field });
    if (k === 4) content += `<div style="position:absolute;left:206px;top:340px;width:200px;height:150px;border-radius:16px;background:linear-gradient(135deg,#2b5876,#4e4376)"></div>`;
    let over = K.globeTouch(t, T.globeDown, T.globeUp, T.slide, true);
    taps.forEach((a, i) => { over += K.touch(K.cardXY(i).x, K.cardXY(i).y, t, a, 0.1, true); });
    over += K.touch(K.valueXY(0).x, K.valueXY(0).y, t, T.maya, 0.1, true);
    return K.iphone({ dark: true, content, keyboard: keyboard(t), over });
  }

  // the big type: what the last key put in the field, or the blank it is asking for
  function bigType(t, d) {
    const k = current(t);
    const mint = K.C.accentDk;
    let html = '', label = '';
    if (t < taps[0] + 0.12) {
      html = `Each key types<br><span style="color:${mint}">a whole thing</span>`;
    } else if (k === 3 && t < T.maya + 0.1) {
      html = `Hi <span style="color:${mint};border-bottom:${d.big * 0.08}px solid ${mint}">Name</span>, your order ships Friday.`;
      label = 'Order update asks for the name';
    } else if (k === 4) {
      html = `<div style="width:${d.w * 0.62}px;height:${d.w * 0.46}px;border-radius:28px;background:linear-gradient(135deg,#2b5876,#4e4376);position:relative"><div style="position:absolute;left:24px;bottom:18px;font-size:${d.big * 0.42}px">Size chart</div></div>`;
      label = 'Size chart, a photo';
    } else if (k === 5) {
      html = `<div style="font-size:${d.big * 0.62}px;line-height:1.22">${WELCOME}</div>`;
      label = 'Studio welcome, a whole list in one tap';
    } else {
      html = keys[k].text;
      label = keys[k].name;
    }
    if (t >= T.scroll) { html = `<span style="font-size:${d.big * 1.6}px;letter-spacing:-0.04em">5,000</span><br><span style="color:#8e8e93;font-size:${d.big * 0.62}px">keys, if you need them</span>`; label = ''; }
    // each change arrives at once, as the text does in the field, with a short settle
    const last = Math.max(...[0, ...taps.filter((a) => t >= a + 0.12).map((a) => a + 0.12), ...(t >= T.maya + 0.1 ? [T.maya + 0.1] : []), ...(t >= T.scroll ? [T.scroll] : [])]);
    // the opening line is already settled at frame 0, where the loop's dissolve lands
    const q = t < taps[0] + 0.12 ? 1 : K.ease.out(K.seg(t, last, last + 0.25));
    return S.text(html, { x: d.x, y: d.y, w: d.w, size: d.big, color: '#fff', lh: 1.04, extra: `opacity:${0.4 + 0.6 * q};transform:translateY(${(1 - q) * 10}px)` }) +
      (label ? S.text(label, { x: d.x + 4, y: d.labelY, w: d.w, size: d.label, weight: 600, color: mint, opacity: q }) : '');
  }

  function frame(t, d) {
    const end = K.ease.inOut(K.seg(t, T.end, T.end + 0.4));
    let h = `<div style="position:absolute;inset:0;background:#0b0f0d"></div>`;
    if (end < 1) {
      h += bigType(t, d);
      const s = d.W / 440, clipTop = 956 - (d.H - d.zone) / s;
      h += S.place(screen(Math.min(t, T.end)), { x: 0, y: d.zone, s, clipTop, radius: '64px 64px 0 0' });
    }
    if (end > 0) h += `<div style="position:absolute;inset:0;background:#0b0f0d;opacity:${end}">` +
      S.text('One key for each<br>thing you retype.', { x: d.x, y: d.ey, w: d.w, size: d.endSize, color: '#fff', lh: 1.04 }) +
      S.text('On iPhone, iPad and Mac,<br>with one purchase', { x: d.x + 4, y: d.ey + d.endSize * 2.35, w: d.w, size: d.label, weight: 600, color: K.C.accentDk, lh: 1.2 }) +
      S.brand({ x: d.x, y: d.ey + d.endSize * 2.35 + d.label * 3.1, icon: d.icon, size: d.brand }) + `</div>`;
    return h;
  }

  const iphone = {
    W: 886, H: 1920, L, loopDissolve: 0.6,
    draw: (t) => frame(t, { W: 886, H: 1920, x: 72, y: 170, w: 760, big: 112, label: 44, labelY: 700, zone: 860, ey: 620, endSize: 92, icon: 104, brand: 54 }),
    stills: [
      { t: 0, name: 'iphone-01', note: 'Frame 0: Each key types a whole thing' },
      { t: 3.2, name: 'iphone-02', note: 'Home address: 14 Linden Road, Flat 3' },
      { t: 7.6, name: 'iphone-03', note: 'Wi-Fi' },
      { t: 9.7, name: 'iphone-04', note: 'Order update asks for the name' },
      { t: 13.2, name: 'iphone-05', note: 'Size chart, a photo' },
      { t: 15.6, name: 'iphone-06', note: 'Studio welcome, a whole list in one tap' },
      { t: 18.6, name: 'iphone-07', note: '5,000 keys, if you need them' },
    ],
    poster: 3.2,
    seam: { kind: 'dissolve', signals: { 'end card (opacity)': (t) => K.ease.inOut(K.seg(t, T.end, T.end + 0.4)) } },
  };

  // iPad: the iPad keyboard, five keys across, each a whole thing
  const ipad = {
    W: 1200, H: 1600, L,
    draw() {
      const cards = keys.concat([{ name: 'Returns', icon: 'return', color: '#ff7ab6', preview: 'Send it back within 30 days…' }, { name: 'Opening hours', icon: 'clock', color: '#a68bff', preview: 'Mon–Sat 10–6' }, { name: 'Door code', icon: 'lock', color: '#4cc38a', preview: '4815, then push twice' }, { name: 'Signature', icon: 'person', color: '#ff7ab6', preview: 'Sam Okafor · Illustration' }]);
      const scr = K.ipad({ dark: true, content: K.ipadMessages({ dark: true, to: 'Maya', text: '14 Linden Road, Flat 3' }), keyboard: K.ipadCutlingKeyboard({ dark: true, cards, inserted: 0 }) });
      return `<div style="position:absolute;inset:0;background:#0b0f0d"></div>` + S.text('14 Linden Road, Flat 3', { x: 84, y: 120, w: 1032, size: 104, color: '#fff', lh: 1.04 }) +
        S.text('Home address', { x: 88, y: 380, w: 1000, size: 44, weight: 600, color: K.C.accentDk }) +
        S.place(scr, { x: 0, y: 520, s: 1200 / 1032, w: 1032, h: 1376, clipTop: 1376 - (1600 - 520) / (1200 / 1032), radius: '40px 40px 0 0' });
    },
    stills: [{ t: 0, name: 'ipad-01', note: 'iPad: one key, a whole address' }],
  };

  // Mac: each row of ⌘⇧V's picker is a whole thing, set huge as it pastes
  const mac = {
    W: 1920, H: 1080, L,
    draw() {
      const rows = keys.slice(0, 5).map((k) => ({ ...k, preview: k.preview.replace(/<[^>]+>/g, '') }));
      const desk = K.macDesktop({ dark: true }) + K.macMenuBar({ dark: true, app: 'Notes', cutlingActive: true }) + K.macNotes({ dark: true, x: 760, y: 120, w: 700, h: 600, body: 'Account 0441 2290 18' }) + K.macPicker({ dark: true, x: 960, y: 250, rows, hover: 1, count: 5000 });
      return S.place(desk, { x: 0, y: 0, s: 1920 / 1512, w: 1512, h: 982, clipBottom: 982 - 1080 / (1920 / 1512) }) +
        `<div style="position:absolute;left:0;top:0;width:900px;height:1080px;background:linear-gradient(90deg,rgba(11,15,13,.98) 72%,rgba(11,15,13,0))"></div>` +
        S.text('Account<br>0441 2290 18', { x: 80, y: 330, w: 760, size: 110, color: '#fff', lh: 1.04 }) +
        S.text('Bank details, one row in ⌘⇧V', { x: 84, y: 600, w: 700, size: 40, weight: 600, color: K.C.accentDk });
    },
    stills: [{ t: 0, name: 'mac-01', note: 'Mac: one row, a whole account number' }],
  };

  window.FILMS['k-every-key'] = { iphone, ipad, mac };
})();
