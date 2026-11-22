// Direction I, "Who it's for": an overview of what Cutling is by who uses it. Three people, three Cutlings:
// someone who sells online, someone who works for themselves, someone who runs a busy home. Above the real
// screen, the person and the names of what they keep; below, the lower half of the screen at its own
// resolution, that person's keyboard doing their everyday job.
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 13 * B;
  const p = (s) => K.pill(s, false);
  const people = [
    {
      at: 0, to: 4 * B, line: 'If you sell online', bg: K.C.paper, fg: '#1c1c1e', chipBg: '#ffffff',
      keep: ['Order update', 'Size chart', 'Returns', 'Shipping times'],
      cards: [
        { name: 'Order update', icon: 'box', color: K.C.brand, preview: `Hi ${p('Name')}, your order ships ${p('Friday')}.` },
        { name: 'Size chart', icon: 'photo', color: '#7a5af5', preview: 'Image · S, M, L, XL' },
        { name: 'Returns', icon: 'return', color: '#e0559b', preview: 'Send it back within 30 days and…' },
        { name: 'Shipping times', icon: 'clock', color: '#f08a24', preview: 'Orders leave within two working days' },
        { name: 'Thank you', icon: 'sparkle', color: '#e0559b', preview: 'Thank you so much for your order!' },
        { name: 'Bank details', icon: 'bank', color: '#30a46c', preview: 'Account 0441 2290 18' },
      ],
      to_: 'Maya',
      beats: [{ tap: 2.4, card: 0, fill: 3.5, text: 'Hi Maya, your order ships Friday.' }, { tap: 5.6, card: 1, photo: 6.8 }],
    },
    {
      at: 4 * B, to: 8 * B, line: 'If you work for yourself', bg: K.C.tint, fg: K.C.bandFrom, chipBg: '#ffffff',
      keep: ['Bank details', 'Project brief', 'When I’m free', 'Portfolio'],
      cards: [
        { name: 'Bank details', icon: 'bank', color: '#30a46c', preview: 'Account 0441 2290 18 · Sort code 20-14-55' },
        { name: 'Project brief', icon: 'doc', color: '#2f7cf6', preview: 'What you’ll get: • Three first sketches…' },
        { name: 'When I’m free', icon: 'cal', color: '#f08a24', preview: `I can start on ${p('Monday')}` },
        { name: 'Portfolio', icon: 'link', color: '#7a5af5', preview: 'Recent work, with three case studies' },
        { name: 'Invoice note', icon: 'doc', color: K.C.brand, preview: 'Payment within 14 days, thank you!' },
        { name: 'Signature', icon: 'person', color: '#e0559b', preview: 'Sam Okafor · Illustration' },
      ],
      to_: 'Ben',
      beats: [{ tap: 4 * B + 1.0, card: 0, text: 'Account 0441 2290 18 · Sort code 20-14-55' }, { tap: 4 * B + 3.1, card: 1, text: 'What you’ll get:\n• Three first sketches\n• Two rounds of changes\n• Final files for print and web' }],
    },
    {
      at: 8 * B, to: 11 * B, line: 'If you run a busy home', bg: K.C.bandFrom, fg: '#ffffff', chipBg: 'rgba(255,255,255,.12)',
      keep: ['Home address', 'Wi-Fi', 'House notes', 'School office'],
      cards: [
        { name: 'House notes', icon: 'house', color: '#2f7cf6', preview: 'Wi-Fi, door code, bedtime…' },
        { name: 'Home address', icon: 'house', color: '#2f7cf6', preview: '14 Linden Road, Flat 3' },
        { name: 'Wi-Fi', icon: 'wifi', color: '#16a5b8', preview: 'home-net · fern2291' },
        { name: 'School office', icon: 'doc', color: '#f08a24', preview: 'Lea Okafor, class 4B, is off today…' },
        { name: 'Swimming', icon: 'pin', color: '#7a5af5', preview: 'Leisure centre, Park Road' },
        { name: 'Allergies', icon: 'shield', color: '#e0559b', preview: 'No nuts, please; she has an…' },
      ],
      to_: 'Lea',
      beats: [{ tap: 8 * B + 1.0, card: 0, text: 'Wi-Fi: home-net · fern2291\nDoor code: 4815\nBedtime is 7:30, a story first.' }],
    },
  ];
  const T = { globeDown: 0.5, globeUp: 1.5, slide: 1.0, cutling: 1.55, end: 11 * B };

  function screen(t, who) {
    let text = '', kb, over = '';
    for (const b of who.beats) {
      const done = b.fill ? t >= b.fill + 0.1 : t >= b.tap + 0.12;
      if (done && b.text) text += (text ? (b.text.includes('\n') ? '\n\n' : ' ') : '') + b.text;
    }
    const photo = who.beats.find((b) => b.photo && t >= b.photo);
    if (who === people[0] && t < T.cutling) {
      kb = K.systemKeyboard({}) + (t >= T.globeDown + 0.2 && t < T.globeUp ? K.globeMenu({ p: K.seg(t, T.globeDown + 0.2, T.globeDown + 0.4), chosen: t > T.slide + 0.2 ? 'Cutling' : 'English (US)' }) : '');
      over += K.globeTouch(t, T.globeDown, T.globeUp, T.slide);
    } else {
      const fillBeat = who.beats.find((b) => b.fill && t >= b.tap + 0.14 && t < b.fill + 0.1);
      if (fillBeat) kb = K.orderFill(t >= fillBeat.fill && t < fillBeat.fill + 0.12 ? 0 : -1);
      else {
        const pressB = who.beats.find((b) => t >= b.tap && t < b.tap + 0.12);
        const insB = who.beats.find((b) => { const a = b.fill || b.tap; return t >= a + 0.12 && t < a + 0.8; });
        kb = K.cutlingKeyboard({ cards: who.cards, press: pressB ? pressB.card : -1, inserted: insB ? insB.card : -1, insertedLabel: insB && insB.photo ? 'Copied' : 'Inserted' });
      }
    }
    for (const b of who.beats) {
      over += K.touch(K.cardXY(b.card).x, K.cardXY(b.card).y, t, b.tap, 0.1);
      if (b.fill) over += K.touch(K.valueXY(0).x, K.valueXY(0).y, t, b.fill, 0.1);
      if (b.photo) over += K.touch(150, 540, t, b.photo - 0.25, 0.12);
    }
    let content = K.messagesNew({ to: who.to_, text: K.esc(text).replace(/\n/g, '<br>') + (photo ? ' ' : '') });
    if (photo) content += `<div style="position:absolute;left:226px;top:384px;width:180px;height:124px;border-radius:16px;background:linear-gradient(135deg,#2b5876,#4e4376)"><div style="position:absolute;left:12px;bottom:10px;color:#fff;font-weight:600;font-size:15px">Size chart</div></div>`;
    return K.iphone({ content, keyboard: kb, over });
  }

  function personFrame(t, who, d) {
    let h = `<div style="position:absolute;inset:0;background:${who.bg}"></div>`;
    h += S.text(who.line, { x: d.x, y: d.y, w: d.w, size: d.line, color: who.fg, lh: 1.02 });
    const chips = who.keep.map((k, i) => {
      const c = who.cards.find((c) => c.name === k) || who.cards[i];
      // the first person's chips are already there at frame 0, so the poster and the loop's seam show them
      const on = who.at === 0 ? 1 : K.ease.out(K.seg(t, who.at + 0.25 + i * 0.12, who.at + 0.6 + i * 0.12));
      return `<span style="display:inline-flex;align-items:center;gap:10px;margin:0 12px 14px 0;padding:10px 18px;border-radius:999px;background:${who.chipBg};box-shadow:0 1px 0 rgba(0,0,0,.06);font:600 ${d.chip}px/1.1 -apple-system,system-ui;color:${who.fg};opacity:${on};transform:translateY(${(1 - on) * 12}px)">${K.icon(c.icon, d.chip, c.color, 2)}${K.esc(k)}</span>`;
    }).join('');
    h += `<div style="position:absolute;left:${d.x}px;top:${d.chipsY}px;width:${d.w}px">${chips}</div>`;
    const s = d.W / 440, clipTop = 956 - (d.H - d.zone) / s;
    h += S.place(screen(t, who), { x: 0, y: d.zone, s, clipTop, radius: '64px 64px 0 0' });
    return h;
  }

  function frame(t, d) {
    const i = people.findIndex((w) => t >= w.at && t < w.to);
    if (i >= 0) {
      const who = people[i];
      let h = personFrame(t, who, d);
      if (i > 0 && t < who.at + 0.35) h = `<div style="position:absolute;inset:0">${personFrame(who.at - 0.01, people[i - 1], d)}</div><div style="position:absolute;inset:0;opacity:${K.ease.inOut(K.seg(t, who.at, who.at + 0.35))}">${h}</div>`;
      return h;
    }
    const p2 = K.ease.inOut(K.seg(t, T.end, T.end + 0.4));
    return `<div style="position:absolute;inset:0">${personFrame(T.end - 0.01, people[2], d)}</div><div style="position:absolute;inset:0;opacity:${p2}"><div style="position:absolute;inset:0;background:${K.C.paper}"></div>` +
      S.text('For whatever you<br>type twice.', { x: d.x, y: d.ey, w: d.w, size: d.endSize, color: '#1c1c1e', lh: 1.02 }) +
      S.text('On iPhone, iPad and Mac,<br>with one purchase', { x: d.x + 4, y: d.ey + d.endSize * 2.35, w: d.w, size: d.sub, weight: 600, color: K.C.accent, lh: 1.2 }) +
      S.brand({ x: d.x, y: d.ey + d.endSize * 2.35 + d.sub * 3.1, icon: d.icon, size: d.brand, color: '#1c1c1e' }) + `</div>`;
  }

  const iphone = {
    W: 886, H: 1920, L, loopDissolve: 0.6,
    draw: (t) => frame(t, { W: 886, H: 1920, x: 64, y: 96, w: 770, line: 96, chip: 36, chipsY: 330, zone: 700, endSize: 84, sub: 44, ey: 600, icon: 104, brand: 54 }),
    stills: [
      { t: 0.2, name: 'iphone-01', note: 'Frame 0: If you sell online, and what a seller keeps' },
      { t: 3.0, name: 'iphone-02', note: 'The seller’s reply asks for the buyer’s name' },
      { t: 7.4, name: 'iphone-03', note: 'The size chart, a photo from the keyboard' },
      { t: 11.6, name: 'iphone-04', note: 'If you work for yourself: bank details in one tap' },
      { t: 14.6, name: 'iphone-05', note: 'The project brief, a whole list in one tap' },
      { t: 21.2, name: 'iphone-06', note: 'If you run a busy home: notes for the babysitter' },
      { t: 26.6, name: 'iphone-07', note: 'End: For whatever you type twice' },
    ],
    poster: 3.0,
    seam: { kind: 'dissolve', signals: { 'end card (opacity)': (t) => (t >= T.end ? K.ease.inOut(K.seg(t, T.end, T.end + 0.4)) : 0) } },
  };

  // iPad: the freelancer, whose brief is long enough to want the iPad's width
  const ipad = {
    W: 1200, H: 1600, L,
    draw() {
      const who = people[1];
      const text = 'Account 0441 2290 18 · Sort code 20-14-55<br><br>What you’ll get:<br>• Three first sketches<br>• Two rounds of changes<br>• Final files for print and web';
      const scr = K.ipad({ content: K.ipadMessages({ to: 'Ben', text }), keyboard: K.ipadCutlingKeyboard({ cards: who.cards.concat([{ name: 'Rates sheet', icon: 'doc', color: '#16a5b8', preview: 'Day rate and what it covers' }, { name: 'Contract', icon: 'doc', color: '#2f7cf6', preview: 'Usual terms, two pages' }, { name: 'Thanks', icon: 'sparkle', color: '#e0559b', preview: 'Thanks so much, Ben!' }, { name: 'Holiday', icon: 'sun', color: '#f0a020', preview: 'I’m away until Monday' }]), inserted: 1 }) });
      const chips = who.keep.map((k) => `<span style="display:inline-block;margin:0 10px 12px 0;padding:9px 18px;border-radius:999px;background:#fff;font:600 30px/1.1 -apple-system,system-ui;color:${K.C.bandFrom}">${K.esc(k)}</span>`).join('');
      return `<div style="position:absolute;inset:0;background:${K.C.tint}"></div>` + S.text(who.line, { x: 84, y: 70, w: 1032, size: 92, color: K.C.bandFrom }) +
        `<div style="position:absolute;left:84px;top:200px;width:1032px">${chips}</div>` +
        S.place(scr, { x: 0, y: 420, s: 1200 / 1032, w: 1032, h: 1376, clipTop: 1376 - (1600 - 420) / (1200 / 1032), radius: '40px 40px 0 0' });
    },
    stills: [{ t: 0, name: 'ipad-01', note: 'iPad: the freelancer’s brief, full width' }],
  };

  // Mac: the seller answering a buyer in Notes with ⌘⇧V's form
  const mac = {
    W: 1920, H: 1080, L,
    draw() {
      const desk = K.macDesktop({}) + K.macMenuBar({ app: 'Notes', cutlingActive: true }) + K.macNotes({ x: 560, y: 120, w: 760, h: 600, body: '' }) +
        K.macPicker({ x: 780, y: 250, mode: 'form', form: { name: 'Order update', icon: 'box', fields: [{ label: 'Name', value: 'Maya', focus: true, selected: true, chips: ['Maya', 'Jonas', 'Aiko', 'Sam'] }], preview: 'Hi Maya, your order ships Friday.', button: 'Paste' } });
      return S.place(desk, { x: 0, y: 0, s: 1920 / 1512, w: 1512, h: 982, clipBottom: 982 - 1080 / (1920 / 1512) }) +
        `<div style="position:absolute;left:0;top:0;width:760px;height:1080px;background:linear-gradient(90deg,rgba(251,251,250,.98) 70%,rgba(251,251,250,0))"></div>` +
        S.text('If you sell online', { x: 80, y: 330, w: 600, size: 84, color: '#1c1c1e', lh: 1.04 }) +
        S.text('⌘⇧V asks for the buyer’s name, then pastes the reply', { x: 84, y: 540, w: 540, size: 36, weight: 600, color: K.C.accent, lh: 1.2 });
    },
    stills: [{ t: 0, name: 'mac-01', note: 'Mac: the seller’s reply from ⌘⇧V’s form' }],
  };

  window.FILMS['i-who-its-for'] = { iphone, ipad, mac };
})();
