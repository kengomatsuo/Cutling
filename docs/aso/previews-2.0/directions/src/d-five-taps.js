// Direction D, "Five taps": one uncut take of Messages at Larger Text. A long, warm reply is built from
// three saved cutlings in five taps (Hello, Maya, Booking, 4, Sign-off). No words are laid over the take
// until the end; while the viewer reads the finished message, what Cutling filled in glows once.
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 12 * B;
  const T = { globeDown: 0.5, globeUp: 1.5, cutling: 1.55, hello: 2.3, helloPanel: 2.44, maya: 3.4, booking: 5.2, bookingPanel: 5.34, four: 6.4, signoff: 8.6, read: 11.0, endCard: 9 * B };
  const SIZE = 22;
  const parts = {
    hello: `<span data-k="evening">Good evening</span>, <span data-k="maya">Maya</span>!`,
    booking: `Your table for <span data-k="four">4</span> is booked for <span data-k="sat">Saturday</span> at 7:30. We’re upstairs from the flower shop on the corner; ring 4 at the green door and we’ll buzz you in.`,
    signoff: `See you then!<br>Sam`,
  };
  const glows = [['evening', 11.5], ['maya', 12.3], ['four', 13.9], ['sat', 14.7], ['caret', 16.6]];

  function messageHTML(t) {
    let h = '';
    if (t >= T.maya + 0.12) h += parts.hello;
    if (t >= T.four + 0.12) h += `<br><br>${parts.booking}`;
    let caretHere = '';
    if (t >= T.signoff + 0.12) {
      caretHere = `<span data-k="caret" style="display:inline-block;width:2px;height:${SIZE * 1.1}px;background:${K.C.blue};vertical-align:-${SIZE * 0.18}px;margin-left:1px"></span>`;
      h += caretHere + `<br><br>${parts.signoff}`;
    }
    // what Cutling filled in glows mint for a moment while the camera reads down the message
    for (const [k, at] of glows) {
      const g = Math.sin(Math.PI * K.seg(t, at, at + 0.9));
      if (g > 0) h = h.replace(`data-k="${k}"`, `data-k="${k}" style="background:rgba(0,190,134,${0.34 * g});border-radius:5px;box-shadow:0 0 0 3px rgba(0,190,134,${0.34 * g})"`);
    }
    return { html: h, caretInside: t >= T.signoff + 0.12 };
  }

  const cards = () => {
    const p = (s) => K.pill(s, false);
    return [
      { name: 'Hello', icon: 'wave', color: '#f0a020', preview: `${p('Good evening')}, ${p('Name')}!` },
      { name: 'Booking', icon: 'fork', color: '#f08a24', preview: `Your table for ${p('Guests ▾')} is booked for ${p('Saturday')}` },
      { name: 'Sign-off', icon: 'sparkle', color: '#e0559b', preview: `${p('Cursor Position')} See you then! Sam` },
      { name: 'Directions', icon: 'pin', color: '#16a5b8', preview: 'Upstairs from the flower shop…' },
      { name: 'Menu', icon: 'doc', color: '#7a5af5', preview: 'Tonight: the autumn menu, five…' },
      { name: 'Allergies', icon: 'shield', color: K.C.brand, preview: 'Tell us about any allergies and…' },
    ];
  };
  const cardXY = (i) => ({ x: 6 + (i % 2) * 217 + 105.5, y: 587 + 68 + Math.floor(i / 2) * 70 + 32 });
  const valueXY = (i) => ({ x: 6 + (i % 3) * 148.67 + 71.3, y: 587 + 62 + 52 + 6 + Math.floor(i / 3) * 50 + 22 });

  function screen(t) {
    let kb;
    if (t < T.cutling) {
      kb = K.systemKeyboard({}) + (t >= 0.7 ? K.globeMenu({ p: K.seg(t, 0.7, 0.88), chosen: t > 1.2 ? 'Cutling' : 'English (US)' }) : '');
    } else if (t >= T.helloPanel && t < T.maya + 0.12) {
      kb = K.cutlingKeyboard({ mode: 'fill', fill: { sentence: K.fillSentence([{ label: 'Good evening', value: 'Good evening' }, ', ', { label: 'Name', active: true }, '!']), values: [...S.seed.names, '__paste'], press: t >= T.maya && t < T.maya + 0.12 ? 0 : -1, last: true } });
    } else if (t >= T.bookingPanel && t < T.four + 0.12) {
      kb = K.cutlingKeyboard({ mode: 'fill', fill: { sentence: K.fillSentence(['Your table for ', { label: 'Guests', active: true }, ' is booked for Saturday…']), values: ['2', '4', '6'], chosen: '2', press: t >= T.four && t < T.four + 0.12 ? 1 : -1, last: true } });
    } else {
      const press = [[T.hello, 0], [T.booking, 1], [T.signoff, 2]].find(([a]) => t >= a && t < a + 0.12);
      const ins = [[T.maya + 0.12, 0], [T.four + 0.12, 1], [T.signoff + 0.12, 2]].find(([a]) => t >= a && t < a + 0.7);
      kb = K.cutlingKeyboard({ cards: cards(), press: press ? press[1] : -1, inserted: ins ? ins[1] : -1 });
    }
    const m = messageHTML(t);
    const content = K.messagesNew({ to: 'Maya', text: m.html, size: SIZE, caret: !m.caretInside, maxLines: 16 });
    let over = '';
    const p = K.ease.inOut(K.seg(t, 0.95, 1.2));
    over += K.touch(K.lerp(44, 80, p), K.lerp(915, 806, p), t, T.globeDown, T.globeUp - T.globeDown);
    over += K.touch(cardXY(0).x, cardXY(0).y, t, T.hello, 0.1) + K.touch(valueXY(0).x, valueXY(0).y, t, T.maya, 0.1);
    over += K.touch(cardXY(1).x, cardXY(1).y, t, T.booking, 0.1) + K.touch(valueXY(1).x, valueXY(1).y, t, T.four, 0.1);
    over += K.touch(cardXY(2).x, cardXY(2).y, t, T.signoff, 0.1);
    return K.iphone({ content, keyboard: kb, over, radius: 0 });
  }

  // camera: native full-bleed, then a slow read down the finished message, then rest for the end card
  function camera(t) {
    const base = { s: 886 / 440, cx: 220, cy: 956 / 2 };
    const close = { s: 2.5, cx: 214, cy: 270 }, low = { s: 2.5, cx: 214, cy: 440 };
    if (t < T.read) return base;
    if (t < T.read + 0.9) return mix(base, close, K.ease.inOut(K.seg(t, T.read, T.read + 0.9)));
    if (t < 17.2) return mix(close, low, K.ease.sine(K.seg(t, T.read + 0.9, 17.2)));
    if (t < 18.4) return mix(low, base, K.ease.inOut(K.seg(t, 17.2, 18.4)));
    return base;
  }
  const mix = (a, b, p) => ({ s: K.lerp(a.s, b.s, p), cx: K.lerp(a.cx, b.cx, p), cy: K.lerp(a.cy, b.cy, p) });

  const caps = (t) => S.fades(t, [[0, 'c1'], [3.0, 'none'], [T.endCard, 'end']], 0.34);
  const ink = '#1c1c1e';
  const iphone = {
    W: 886, H: 1920, L, loopDissolve: 0.6,
    draw(t) {
      const cam = camera(t);
      const x = 443 - cam.cx * cam.s, y = 960 - cam.cy * cam.s;
      let h = `<div style="position:absolute;inset:0;background:#fdfdfd"></div>` + S.place(screen(Math.min(t, T.endCard + 1)), { x, y, s: cam.s });
      const f = caps(t);
      if ((f.c1 || 0) > 0.001) h += S.text('A long reply<br>in five taps', { x: 72, y: 430, w: 760, size: 92, color: ink, opacity: f.c1, lh: 1.04 });
      if ((f.end || 0) > 0.001) {
        const drop = K.ease.out(K.seg(t, T.endCard - 0.2, T.endCard + 0.5));
        h += `<div style="position:absolute;left:0;top:${-640 + 640 * drop}px;width:886px;height:640px;background:${K.C.paper};box-shadow:0 20px 60px rgba(0,0,0,.12)">` +
          S.text('That was<br>five taps.', { x: 72, y: 150, w: 760, size: 118, color: ink, lh: 1.02 }) + S.brand({ x: 72, y: 430, icon: 100, size: 52, color: ink }) + `</div>`;
      }
      return h;
    },
    stills: [
      { t: 0, name: 'iphone-01', note: 'Frame 0: A long reply in five taps' },
      { t: 2.9, name: 'iphone-02', note: 'Tap 1, Hello: Cutling asks for the name' },
      { t: 4.2, name: 'iphone-03', note: 'Tap 2, Maya: Good evening, Maya!' },
      { t: 5.9, name: 'iphone-04', note: 'Tap 3, Booking: a choice of 2, 4 or 6' },
      { t: 9.6, name: 'iphone-05', note: 'Taps 4 and 5: the booking, the sign-off, the cursor waiting for a personal line' },
      { t: 14.2, name: 'iphone-06', note: 'Reading down the message: what Cutling filled in glows' },
      { t: 24.0, name: 'iphone-07', note: 'End: That was five taps.' },
    ],
    poster: 9.6,
    seam: {
      kind: 'dissolve',
      signals: { 'camera scale': (t) => camera(t).s, 'camera centre y (pt)': (t) => camera(t).cy, 'end card (opacity)': (t) => caps(t).end || 0 },
    },
  };

  const ipad = {
    W: 1200, H: 1600, L,
    draw(t) {
      const tt = 9.8;
      const m = messageHTML(tt);
      const ipadCards = cards().concat([{ name: 'Parking', icon: 'car', color: '#2f7cf6', preview: 'Free after 6 on Linden Road' }, { name: 'Gift card', icon: 'ticket', color: '#e0559b', preview: 'Your gift card code is…' }]);
      const scr = K.ipad({ content: K.ipadMessages({ to: 'Maya', text: m.html, size: 24 }), keyboard: K.ipadCutlingKeyboard({ cards: ipadCards, inserted: 2, insertedLabel: 'Inserted' }) });
      return `<div style="position:absolute;inset:0;background:#fdfdfd"></div>` + S.place(scr, { x: 0, y: 0, s: 1200 / 1032, w: 1032, h: 1376 });
    },
    stills: [{ t: 9.8, name: 'ipad-01', note: 'iPad: the same five taps, full width' }],
  };

  const mac = {
    W: 1920, H: 1080, L,
    draw() {
      const body = `Good evening, Maya!<br><br>Your table for 4 is booked for Saturday at 7:30. We’re upstairs from the flower shop on the corner; ring 4 at the green door and we’ll buzz you in.<br><br>`;
      const desk = K.macDesktop({ dark: false }) + K.macMenuBar({ app: 'Notes', cutlingActive: true, time: 'Thu 7:12 PM' }) +
        K.macNotes({ x: 330, y: 110, w: 820, h: 620, to: 'Maya', subject: 'Your booking', body }) +
        K.macPicker({ x: 520, y: 380, rows: [
          { name: 'Sign-off', icon: 'sparkle', color: '#e0559b', preview: 'See you then! Sam' },
          { name: 'Hello', icon: 'wave', color: '#f0a020', preview: 'Good evening, Name!' },
          { name: 'Booking', icon: 'fork', color: '#f08a24', preview: 'Your table for Guests is booked for Saturday' },
          { name: 'Directions', icon: 'pin', color: '#16a5b8', preview: 'Upstairs from the flower shop…' },
          { name: 'Menu', icon: 'doc', color: '#7a5af5', preview: 'Tonight: the autumn menu, five…' },
        ], hover: 0, query: 'sign', count: 248 });
      return S.place(desk, { x: 0, y: 0, s: 1920 / 1512, w: 1512, h: 982, clipBottom: 982 - 1080 / (1920 / 1512) }) +
        K.keycaps(['⌘', '⇧', 'V'], 1560, 880, 92, 1, true);
    },
    stills: [{ t: 0, name: 'mac-01', note: 'Mac: the fifth pick, Sign-off, found by typing three letters' }],
  };

  window.FILMS['d-five-taps'] = { iphone, ipad, mac };
})();
