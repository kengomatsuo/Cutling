// Direction G, "Every app": an overview of what Cutling is by where it works. The Cutling keyboard holds still
// at the bottom while Apple's own apps change above it, one a bar: your address in Maps, the studio in Calendar,
// a reply in Messages that asks for the name (2.0), your account number in a refund form in Safari, a photo in
// Messages. The end card says "any app", as Cutling's own listing does (promotional_text.txt).
// Full-bleed at the recording's own resolution; one line of type for each app.
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 10 * B;
  const T = { globeDown: 0.5, globeUp: 1.5, slide: 1.0, cutling: 1.55, maps: 1 * B, mapsTap: 1 * B + 0.55, cal: 2 * B, calTap: 2 * B + 0.5,
    msg: 3 * B, orderTap: 3 * B + 0.45, maya: 3 * B + 1.45, thanks: 3 * B + 3.0, rem: 5 * B, remTap: 5 * B + 0.6, photo: 6 * B, photoTap: 6 * B + 0.45, paste: 6 * B + 1.25, end: 7 * B };
  const cards = K.everyday(false);
  const sizeChart = { name: 'Size chart', icon: 'photo', color: '#7a5af5', preview: 'Image · S, M, L, XL' };
  const account = { name: 'Account number', icon: 'bank', color: '#30a46c', preview: '0441 2290 18' };
  const keys = [cards[0], cards[1], account, cards[3], sizeChart, cards[5]];
  // a refund form on a plain page in Safari (the take uses a local file; no business is named)
  const refund = (filled) => `<div style="font-size:24px;font-weight:700;margin-bottom:4px">Refund details</div>
    <div style="color:#6e6e73;margin-bottom:18px">Where should we send your refund?</div>
    <div style="font-size:15px;color:#6e6e73;margin-bottom:6px">Name on account</div>
    <div style="height:44px;border:1px solid #d2d2d7;border-radius:10px;display:flex;align-items:center;padding:0 12px;margin-bottom:16px">Sam Okafor</div>
    <div style="font-size:15px;color:#6e6e73;margin-bottom:6px">Account number</div>
    <div style="height:44px;border:2px solid #0a7cff;border-radius:10px;display:flex;align-items:center;padding:0 12px">${filled ? '0441 2290 18' : ''}<span style="display:inline-block;width:2px;height:20px;background:#0a7cff;margin-left:1px"></span></div>`;

  function app(t) {
    if (t < T.maps) return K.messagesNew({ to: 'Maya', text: '' });
    if (t < T.cal) { const on = t >= T.mapsTap + 0.1; return K.maps({ query: on ? '14 Linden Road, Flat 3' : '', result: on ? '14 Linden Road' : '' }); }
    if (t < T.msg) return K.calendarEvent({ title: 'Pottery class', location: t >= T.calTap + 0.1 ? '22 Mill Lane, Studio 4' : '' });
    if (t < T.rem) {
      let text = t >= T.maya + 0.1 ? 'Hi Maya, your order ships Friday.' : '';
      if (t >= T.thanks + 0.1) text += ' Thank you so much for your order!';
      return K.messagesNew({ to: 'Maya', text });
    }
    if (t < T.photo) return K.safariPage({ body: refund(t >= T.remTap + 0.1), addr: 'Refund' });
    const pasted = t >= T.paste;
    return K.messagesNew({ to: 'Lea', text: pasted ? ' ' : '' }) + (pasted ? `<div style="position:absolute;left:206px;top:${388}px;width:200px;height:150px;border-radius:16px;background:linear-gradient(135deg,#2b5876,#4e4376);box-shadow:0 2px 10px rgba(0,0,0,.2)"><div style="position:absolute;left:12px;bottom:10px;color:#fff;font-weight:600;font-size:15px">Size chart</div></div>` : '');
  }
  const appKey = (t) => (t < T.maps ? 0 : t < T.cal ? 1 : t < T.msg ? 2 : t < T.rem ? 3 : t < T.photo ? 4 : 5);

  function keyboard(t) {
    if (t < T.cutling) return K.systemKeyboard({}) + (t >= T.globeDown + 0.2 && t < T.globeUp ? K.globeMenu({ p: K.seg(t, T.globeDown + 0.2, T.globeDown + 0.4), chosen: t > T.slide + 0.2 ? 'Cutling' : 'English (US)' }) : '');
    if (t >= T.orderTap + 0.14 && t < T.maya + 0.1) return K.orderFill(t >= T.maya && t < T.maya + 0.12 ? 0 : -1);
    const taps = [[T.mapsTap, 0], [T.calTap, 3], [T.orderTap, 1], [T.thanks, 5], [T.remTap, 2], [T.photoTap, 4]];
    const press = taps.find(([a]) => t >= a && t < a + 0.12);
    const ins = taps.find(([a]) => t >= a + 0.12 && t < a + 0.75 && a !== T.orderTap);
    const copied = t >= T.photoTap + 0.12 && t < T.photoTap + 0.9;
    return K.cutlingKeyboard({ cards: keys, press: press ? press[1] : -1, inserted: ins ? ins[1] : -1, insertedLabel: copied ? 'Copied' : 'Inserted' });
  }
  function touches(t) {
    let h = K.globeTouch(t, T.globeDown, T.globeUp, T.slide);
    for (const [a, i] of [[T.mapsTap, 0], [T.calTap, 3], [T.orderTap, 1], [T.thanks, 5], [T.remTap, 2], [T.photoTap, 4]]) h += K.touch(K.cardXY(i).x, K.cardXY(i).y, t, a, 0.1);
    h += K.touch(K.valueXY(0).x, K.valueXY(0).y, t, T.maya, 0.1);
    h += K.touch(150, 540, t, T.paste - 0.25, 0.12);
    return h;
  }

  // the screen: the app above changes with a dissolve while the keyboard below holds still
  function screen(t) {
    const k = appKey(t), cuts = [T.maps, T.cal, T.msg, T.rem, T.photo];
    const cut = cuts[k - 1];
    let content = app(t);
    if (cut !== undefined && t < cut + 0.3) content = `<div style="position:absolute;inset:0">${app(cut - 0.01)}</div><div style="position:absolute;inset:0;opacity:${K.ease.inOut(K.seg(t, cut, cut + 0.3))}">${content}</div>`;
    return K.iphone({ content, keyboard: keyboard(t), over: touches(t) });
  }

  const LABELS = [
    [0, 'What you keep typing, one tap away', ''],
    [T.maps, 'Your address', 'in Maps'],
    [T.cal, 'The studio', 'in Calendar'],
    [T.msg, 'A reply that asks for the name', 'in Messages'],
    [T.rem, 'Your account number', 'in Safari'],
    [T.photo, 'A photo', 'in Messages'],
  ];
  const ink = '#1c1c1e';
  function words(t) {
    const f = S.fades(t, LABELS.map(([a], i) => [a, 'l' + i]).concat([[T.end, 'end']]), 0.3);
    let h = '';
    LABELS.forEach(([, big, small], i) => {
      const o = f['l' + i] || 0;
      if (o < 0.001) return;
      h += S.text(big, { x: 72, y: 96, w: 760, size: i ? 80 : 86, color: ink, lh: 1.04, opacity: o });
      // a line of more than about 20 characters wraps at 80 px across 760 px
      if (small) h += S.text(small, { x: 74, y: 96 + (big.length > 20 ? 176 : 92), w: 760, size: 52, weight: 600, color: K.C.accent, opacity: o });
    });
    if ((f.end || 0) > 0.001) {
      h += `<div style="position:absolute;inset:0;background:${K.C.paper};opacity:${f.end}"></div>`;
      h += S.text('Any app on<br>your iPhone.', { x: 72, y: 560, w: 760, size: 112, color: ink, lh: 1.02, opacity: f.end });
      h += S.text('Also on iPad and Mac, one purchase for all three.', { x: 74, y: 830, w: 700, size: 46, weight: 600, color: K.C.accent, lh: 1.2, opacity: f.end });
      h += S.brand({ x: 72, y: 1060, icon: 110, size: 58, color: ink, opacity: f.end });
    }
    return h;
  }

  const iphone = {
    W: 886, H: 1920, L, loopDissolve: 0.6,
    draw(t) {
      const s = 1.5;
      return `<div style="position:absolute;inset:0;background:${K.C.paper}"></div>` +
        S.place(screen(Math.min(t, T.end + 0.4)), { x: (886 - 440 * s) / 2, y: 470, s, radius: `${62 * s}px`, shadow: '0 30px 80px rgba(0,0,0,.14), 0 0 0 1px rgba(0,0,0,.05)' }) + words(t);
    },
    stills: [
      { t: 0, name: 'iphone-01', note: 'Frame 0: What you keep typing, one tap away' },
      { t: 3.4, name: 'iphone-02', note: 'Your address in Maps' },
      { t: 5.6, name: 'iphone-03', note: 'The studio in Calendar' },
      { t: 8.0, name: 'iphone-04', note: 'A reply in Messages: Cutling asks for the name' },
      { t: 12.6, name: 'iphone-05', note: 'Your account number in Safari' },
      { t: 15.0, name: 'iphone-06', note: 'A photo in Messages' },
      { t: 19.5, name: 'iphone-07', note: 'End: Any app on your iPhone. Also on iPad and Mac.' },
    ],
    poster: 3.4,
    seam: { kind: 'dissolve', signals: { 'end card (opacity)': (t) => S.fades(t, [[0, 'a'], [T.end, 'end']], 0.3).end || 0 } },
  };

  // iPad: the same move with the iPad keyboard across the bottom and Calendar above
  const ipad = {
    W: 1200, H: 1600, L,
    draw() {
      const cal = `<div style="position:absolute;left:0;top:0;width:1032px;height:1376px;background:#f2f2f7">
        <div style="position:absolute;left:0;right:0;top:40px;text-align:center;font-weight:600;font-size:17px">New Event</div>
        <div style="position:absolute;left:266px;top:100px;width:500px;height:104px;border-radius:24px;background:#fff">
          <div style="position:absolute;left:18px;top:0;height:52px;display:flex;align-items:center;font-size:17px">Pottery class</div>
          <div style="position:absolute;left:18px;right:0;top:52px;height:.5px;background:${K.C.sep}"></div>
          <div style="position:absolute;left:18px;top:52px;height:52px;display:flex;align-items:center;font-size:17px">22 Mill Lane, Studio 4<span style="display:inline-block;width:2px;height:20px;background:#e8473f;margin-left:1px"></span></div></div></div>`;
      const ipadKeys = K.everyday(false).map((c) => (c.name === 'Bank details' ? account : c)).concat([{ name: 'Size chart', icon: 'photo', color: '#7a5af5', preview: 'Image · S, M, L, XL' }, { name: 'Opening hours', icon: 'clock', color: '#7a5af5', preview: 'Mon–Sat 10–6' }, { name: 'Returns', icon: 'return', color: '#e0559b', preview: 'Send it back within 30 days…' }, { name: 'Parking', icon: 'car', color: '#2f7cf6', preview: 'Free after 6 on Linden Road' }]);
      const scr = K.ipad({ content: cal, keyboard: K.ipadCutlingKeyboard({ cards: ipadKeys, inserted: 3 }) });
      return S.place(scr, { x: 0, y: 0, s: 1200 / 1032, w: 1032, h: 1376 }) +
        S.text('The studio', { x: 84, y: 360, w: 1000, size: 92, color: ink, extra: 'text-shadow:0 0 18px #fff' }) + S.text('in Calendar, on iPad', { x: 86, y: 470, w: 1000, size: 50, weight: 600, color: K.C.accent });
    },
    stills: [{ t: 0, name: 'ipad-01', note: 'iPad: the same keyboard under Calendar' }],
  };

  // Mac: ⌘⇧V's picker at the cursor in whichever app is in front
  const mac = {
    W: 1920, H: 1080, L,
    draw() {
      const rows = [
        { name: 'Studio address', icon: 'pin', color: '#f08a24', preview: '22 Mill Lane, Studio 4' },
        { name: 'Home address', icon: 'house', color: '#2f7cf6', preview: '14 Linden Road, Flat 3' },
        { name: 'Order update', icon: 'box', color: K.C.brand, preview: 'Hi Name, your order ships Friday.' },
        { name: 'Bank details', icon: 'bank', color: '#30a46c', preview: 'Account 0441 2290 18' },
        { name: 'Wi-Fi', icon: 'wifi', color: '#16a5b8', preview: 'studio-guest · fern2291' },
      ];
      const calWin = `<div style="position:absolute;left:300px;top:120px;width:820px;height:560px;border-radius:14px;background:#fff;box-shadow:0 30px 80px rgba(0,0,0,.35);overflow:hidden;font-family:-apple-system,system-ui">
        <div style="position:absolute;left:18px;top:19px;display:flex;gap:8px">${['#ff5f57', '#febc2e', '#28c840'].map((c) => `<div style="width:13px;height:13px;border-radius:50%;background:${c}"></div>`).join('')}</div>
        <div style="position:absolute;left:0;right:0;top:16px;text-align:center;font-size:14px;font-weight:600">Calendar</div>
        <div style="position:absolute;left:60px;top:90px;width:700px;height:120px;border-radius:12px;background:#fde7e5;border-left:5px solid #e8473f;padding:14px 18px;box-sizing:border-box">
          <div style="font-size:16px;font-weight:600">Pottery class</div><div style="font-size:14px;color:#555;margin-top:6px">Location: <span style="display:inline-block;width:1.5px;height:16px;background:#000;vertical-align:-3px"></span></div></div></div>`;
      const desk = K.macDesktop({}) + K.macMenuBar({ app: 'Calendar', cutlingActive: true }) + calWin + K.macPicker({ x: 520, y: 300, rows, hover: 0, count: 6 });
      return S.place(desk, { x: 0, y: 0, s: 1920 / 1512, w: 1512, h: 982, clipBottom: 982 - 1080 / (1920 / 1512) }) +
        `<div style="position:absolute;left:1240px;top:0;width:680px;height:1080px;background:linear-gradient(270deg,rgba(251,251,250,.97) 70%,rgba(251,251,250,0))"></div>` +
        S.text('Any app on your Mac', { x: 1330, y: 400, w: 520, size: 64, color: ink, lh: 1.08 }) + S.text('⌘⇧V opens your cutlings at the cursor', { x: 1332, y: 560, w: 500, size: 36, weight: 600, color: K.C.accent, lh: 1.2 });
    },
    stills: [{ t: 0, name: 'mac-01', note: 'Mac: ⌘⇧V in Calendar' }],
  };

  window.FILMS['g-every-app'] = { iphone, ipad, mac };
})();
