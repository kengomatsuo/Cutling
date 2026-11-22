// Direction J, "The first week": an overview of what Cutling is by what it becomes. Day 1 it holds your
// address; Day 2 your bank details too; Day 3 a reply that asks for the name (2.0); Day 5 a photo, saved from
// Photos' share sheet; Day 7 thirty things, one tap each. The keyboard itself counts the days: one key on Day 1,
// more each day, each new one at the end of the list as the app adds it (CutlingStore.add appends).
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 12 * B;
  const days = [
    { n: 1, at: 0, label: 'Your address' },
    { n: 2, at: 2 * B, label: 'Your bank details' },
    { n: 3, at: 4 * B, label: 'A reply that asks for the name' },
    { n: 5, at: 6 * B, label: 'A photo you send a lot' },
    { n: 7, at: 8 * B, label: 'Thirty things, one tap each' },
  ];
  const T = { globeDown: 0.5, globeUp: 1.5, slide: 1.0, cutling: 1.55, d1tap: 2.6, d2tap: 2 * B + 1.3, d3tap: 4 * B + 0.6, d3maya: 4 * B + 1.6,
    d5share: 6 * B + 0.8, d5cut: 6 * B + 1.6, d5ours: 6 * B + 1.75, d5done: 6 * B + 2.8, d5gone: 6 * B + 2.95, end: 10 * B };
  const all = K.everyday(false);
  const home = all[0], bank = all[2], order = all[1];
  const photo = { name: 'Size chart', icon: 'photo', color: '#7a5af5', preview: 'Image · S, M, L, XL' };

  function screen(t) {
    if (t < days[1].at) {
      let kb;
      if (t < T.cutling) kb = K.systemKeyboard({}) + (t >= T.globeDown + 0.2 && t < T.globeUp ? K.globeMenu({ p: K.seg(t, T.globeDown + 0.2, T.globeDown + 0.4), chosen: t > T.slide + 0.2 ? 'Cutling' : 'English (US)' }) : '');
      else kb = K.cutlingKeyboard({ cards: [home], press: t >= T.d1tap && t < T.d1tap + 0.12 ? 0 : -1, inserted: t >= T.d1tap + 0.12 && t < T.d1tap + 0.8 ? 0 : -1 });
      const on = t >= T.d1tap + 0.12;
      return K.iphone({ content: K.maps({ query: on ? '14 Linden Road, Flat 3' : '', result: on ? '14 Linden Road' : '' }), keyboard: kb, over: K.globeTouch(t, T.globeDown, T.globeUp, T.slide) + K.touch(K.cardXY(0).x, K.cardXY(0).y, t, T.d1tap, 0.1) });
    }
    if (t < days[2].at) {
      const kb = K.cutlingKeyboard({ cards: [home, bank], press: t >= T.d2tap && t < T.d2tap + 0.12 ? 1 : -1, inserted: t >= T.d2tap + 0.12 && t < T.d2tap + 0.8 ? 1 : -1 });
      return K.iphone({ content: K.messagesNew({ to: 'Jonas', text: t >= T.d2tap + 0.12 ? 'Account 0441 2290 18' : '' }), keyboard: kb, over: K.touch(K.cardXY(1).x, K.cardXY(1).y, t, T.d2tap, 0.1) });
    }
    if (t < days[3].at) {
      const kb = t >= T.d3tap + 0.14 && t < T.d3maya + 0.1 ? K.orderFill(t >= T.d3maya && t < T.d3maya + 0.12 ? 0 : -1)
        : K.cutlingKeyboard({ cards: [home, bank, order], press: t >= T.d3tap && t < T.d3tap + 0.12 ? 2 : -1, inserted: t >= T.d3maya + 0.1 && t < T.d3maya + 0.8 ? 2 : -1 });
      return K.iphone({ content: K.messagesNew({ to: 'Maya', text: t >= T.d3maya + 0.1 ? 'Hi Maya, your order ships Friday.' : '' }), keyboard: kb, over: K.touch(K.cardXY(2).x, K.cardXY(2).y, t, T.d3tap, 0.1) + K.touch(K.valueXY(0).x, K.valueXY(0).y, t, T.d3maya, 0.1) });
    }
    if (t < days[4].at) {
      // Photos: Share, Cutling in the row of apps, then Cutling's own sheet, named Size chart, and Done
      let content = K.photo('#2b5876,#4e4376') + `<div style="position:absolute;left:30px;top:640px;color:#fff;font:600 22px -apple-system,system-ui">Size chart</div>`;
      if (t >= T.d5share && t < T.d5ours + 0.3) content += K.shareSheet({ press: t >= T.d5cut && t < T.d5cut + 0.12, p: K.ease.out(K.seg(t, T.d5share, T.d5share + 0.3)) });
      if (t >= T.d5ours && t < T.d5gone + 0.3) {
        const up = K.ease.out(K.seg(t, T.d5ours, T.d5ours + 0.3)) * (1 - K.ease.inOut(K.seg(t, T.d5gone, T.d5gone + 0.3)));
        content += K.cutlingShare({ name: 'Size chart', icon: 'photo', color: '#7a5af5', image: 'linear-gradient(135deg,#2b5876,#4e4376)', p: up, donePress: t >= T.d5done && t < T.d5done + 0.12 });
      }
      return K.iphone({ dark: true, content, over: K.touch(48, 900, t, T.d5share - 0.3, 0.1, true) + K.touch(303, 636, t, T.d5cut, 0.1) + K.touch(379, 102, t, T.d5done, 0.1) });
    }
    const names = ['Home address', 'Order update', 'Bank details', 'Size chart', 'Studio address', 'Wi-Fi', 'Thank you', 'Returns', 'Shipping times', 'Opening hours', 'Directions', 'Door code', 'Parking', 'Signature', 'Booking', 'Allergies', 'Invoice note', 'Portfolio', 'School office', 'Gift wrap'];
    const icons = ['house', 'box', 'bank', 'photo', 'pin', 'wifi', 'sparkle', 'return', 'clock', 'clock', 'pin', 'lock', 'car', 'person', 'cal', 'shield', 'doc', 'link', 'doc', 'ticket'];
    const colors = ['#2f7cf6', K.C.brand, '#30a46c', '#7a5af5', '#f08a24', '#16a5b8', '#e0559b'];
    const cards = names.map((n, i) => ({ name: n, icon: icons[i], color: colors[i % colors.length], preview: (all.find((c) => c.name === n) || {}).preview || '' }));
    const scroll = 900 * K.ease.inOut(K.seg(t, days[4].at + 0.8, T.end - 0.3));
    return K.iphone({ content: K.mainGrid({ count: '30 Cutlings', cards, scroll }) });
  }

  function dayWords(t, d) {
    const i = days.findIndex((x, k) => t >= x.at && (k === days.length - 1 || t < days[k + 1].at));
    const day = days[i];
    const p = i > 0 ? K.ease.out(K.seg(t, day.at, day.at + 0.35)) : 1;
    let h = S.text(`Day <span style="color:${K.C.brand}">${day.n}</span>`, { x: d.x, y: d.y, w: d.w, size: d.day, weight: 800, color: '#1c1c1e', ls: '-0.03em', lh: 1, opacity: p });
    h += S.text(day.label, { x: d.x + 4, y: d.y + d.day * 1.02, w: d.w, size: d.label, weight: 600, color: K.C.accent, lh: 1.15, opacity: p });
    // seven marks, one a day, filled up to today
    h += `<div style="position:absolute;left:${d.x + 4}px;top:${d.dotsY}px;display:flex;gap:${d.dot * 0.7}px">${[1, 2, 3, 4, 5, 6, 7].map((n) => `<div style="width:${d.dot}px;height:${d.dot}px;border-radius:50%;background:${n <= day.n ? K.C.brand : '#e2e2de'}"></div>`).join('')}</div>`;
    return h;
  }

  function frame(t, d) {
    let h = `<div style="position:absolute;inset:0;background:${K.C.paper}"></div>`;
    const end = K.ease.inOut(K.seg(t, T.end, T.end + 0.4));
    if (end < 1) {
      h += dayWords(Math.min(t, T.end), d);
      const cut = days.find((x) => x.at > 0 && t >= x.at && t < x.at + 0.3);
      let scr = screen(Math.min(t, T.end));
      if (cut) scr = `<div style="position:absolute;inset:0">${screen(cut.at - 0.01)}</div><div style="position:absolute;inset:0;opacity:${K.ease.inOut(K.seg(t, cut.at, cut.at + 0.3))}">${scr}</div>`;
      h += S.place(scr, { x: (d.W - 440 * d.s) / 2, y: d.sy, s: d.s, radius: `${62 * d.s}px`, shadow: '0 30px 80px rgba(0,0,0,.14), 0 0 0 1px rgba(0,0,0,.05)' });
    }
    if (end > 0) h += `<div style="position:absolute;inset:0;background:${K.C.paper};opacity:${end}">` +
      S.text('Save it the first time.<br>Tap it every time after.', { x: d.x, y: d.ey, w: d.w, size: d.endSize, color: '#1c1c1e', lh: 1.04 }) +
      S.text('On iPhone, iPad and Mac,<br>with one purchase', { x: d.x + 4, y: d.ey + d.endSize * 2.45, w: d.w, size: 44, weight: 600, color: K.C.accent, lh: 1.2 }) +
      S.brand({ x: d.x, y: d.ey + d.endSize * 2.45 + 44 * 3.1, icon: d.icon, size: d.brand, color: '#1c1c1e' }) + `</div>`;
    return h;
  }

  const iphone = {
    W: 886, H: 1920, L, loopDissolve: 0.6,
    draw: (t) => frame(t, { W: 886, x: 72, y: 80, w: 760, day: 150, label: 50, dotsY: 380, dot: 26, s: 1.36, sy: 470, ey: 620, endSize: 64, icon: 104, brand: 54 }),
    stills: [
      { t: 0, name: 'iphone-01', note: 'Frame 0: Day 1, your address' },
      { t: 3.2, name: 'iphone-02', note: 'Day 1: the only card types the address into Maps' },
      { t: 6.0, name: 'iphone-03', note: 'Day 2: two keys; the bank details to Jonas' },
      { t: 9.9, name: 'iphone-04', note: 'Day 3: the reply asks for the name' },
      { t: 15.9, name: 'iphone-05', note: 'Day 5: a photo, saved from the share sheet into Cutling' },
      { t: 20.2, name: 'iphone-06', note: 'Day 7: 30 Cutlings' },
      { t: 24.8, name: 'iphone-07', note: 'End: Save it the first time. Tap it every time after.' },
    ],
    poster: 9.9,
    seam: { kind: 'dissolve', signals: { 'end card (opacity)': (t) => K.ease.inOut(K.seg(t, T.end, T.end + 0.4)) } },
  };

  // iPad: Day 7 on the iPad, thirty cutlings in its keyboard
  const ipad = {
    W: 1200, H: 1600, L,
    draw() {
      const cards = K.everyday(false).concat([{ name: 'Size chart', icon: 'photo', color: '#7a5af5', preview: 'Image · S, M, L, XL' }, { name: 'Returns', icon: 'return', color: '#e0559b', preview: 'Send it back within 30 days…' }, { name: 'Opening hours', icon: 'clock', color: '#7a5af5', preview: 'Mon–Sat 10–6' }, { name: 'Door code', icon: 'lock', color: '#30a46c', preview: '4815, then push twice' }, { name: 'Parking', icon: 'car', color: '#2f7cf6', preview: 'Free after 6 on Linden Road' }, { name: 'Signature', icon: 'person', color: '#e0559b', preview: 'Sam Okafor · Illustration' }, { name: 'Booking', icon: 'cal', color: '#f08a24', preview: 'Your table for Guests is booked' }, { name: 'Allergies', icon: 'shield', color: K.C.brand, preview: 'No nuts, please' }, { name: 'Portfolio', icon: 'link', color: '#7a5af5', preview: 'Recent work, three case studies' }]);
      const scr = K.ipad({ content: K.ipadMessages({ to: 'Maya', text: '' }), keyboard: K.ipadCutlingKeyboard({ cards }) });
      return `<div style="position:absolute;inset:0;background:${K.C.paper}"></div>` + S.text(`Day <span style="color:${K.C.brand}">7</span>`, { x: 84, y: 60, w: 1000, size: 150, weight: 800, color: '#1c1c1e', lh: 1 }) +
        S.text('Thirty things, one tap each', { x: 88, y: 220, w: 1000, size: 50, weight: 600, color: K.C.accent }) +
        S.place(scr, { x: 0, y: 360, s: 1200 / 1032, w: 1032, h: 1376, clipTop: 1376 - (1600 - 360) / (1200 / 1032), radius: '40px 40px 0 0' });
    },
    stills: [{ t: 0, name: 'ipad-01', note: 'iPad: Day 7, a full keyboard' }],
  };

  // Mac: Day 2 on the Mac, where what you copied waits in History
  const mac = {
    W: 1920, H: 1080, L,
    draw() {
      const rows = [{ name: 'Account 0441 2290 18', icon: 'clip', color: K.C.brand, preview: '' }, { name: '14 Linden Road, Flat 3', icon: 'clip', color: K.C.brand, preview: '' }];
      const desk = K.macDesktop({}) + K.macMenuBar({ app: 'Notes', cutlingActive: true }) + K.macNotes({ x: 520, y: 120, w: 760, h: 600, body: '' }) + K.macPicker({ x: 760, y: 240, rows, hover: 0, tab: 'history', count: 2 });
      return S.place(desk, { x: 0, y: 0, s: 1920 / 1512, w: 1512, h: 982, clipBottom: 982 - 1080 / (1920 / 1512) }) +
        `<div style="position:absolute;left:0;top:0;width:740px;height:1080px;background:linear-gradient(90deg,rgba(251,251,250,.98) 70%,rgba(251,251,250,0))"></div>` +
        S.text(`Day <span style="color:${K.C.brand}">2</span>`, { x: 80, y: 320, w: 600, size: 150, weight: 800, color: '#1c1c1e', lh: 1 }) +
        S.text('Your bank details, saved from what you copied', { x: 84, y: 490, w: 520, size: 42, weight: 600, color: K.C.accent, lh: 1.2 });
    },
    stills: [{ t: 0, name: 'mac-01', note: 'Mac: Day 2, saved from the clipboard history' }],
  };

  window.FILMS['j-first-week'] = { iphone, ipad, mac };
})();
