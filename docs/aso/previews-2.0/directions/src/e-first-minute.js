// Direction E, "First minute": for people who have never used a keyboard app. The remade setup guide
// from the first page to the first typed cutling, the three steps numbered large in the brand green,
// and the answer to Apple's Full Access warning placed on the moment the warning appears.
// Page words are the app's own (Cutling/SetupFlows.swift).
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 11 * B;
  const T = { cont: 1.9, addPage: 2.05, openSettings: 3.45, settings: 3.6, tglCutling: 4.25, tglFull: 5.05, alert: 5.2, allow: 7.4, back: 7.9, tryPage: 8.1,
    field: 9.3, globeDown: 9.75, globeUp: 10.75, cutling: 10.8, tryMe: 11.7, typed: 11.82, toMessages: 6 * B, tapReply: 14.25, panel: 14.4, maya: 15.3, endCard: 8.5 * B };

  const welcome = () => K.guidePage({ title: 'Welcome to Cutling', rows: [
    { icon: 'textbox', title: 'Tap to Type', text: 'Save what you type over and over, then tap it on the keyboard in any app.', y: 220 },
    { icon: 'photo', title: 'Images Too', text: 'Copy a saved image with one tap and paste it anywhere.', y: 332 },
    { icon: 'lock', title: 'Stays on Your iPhone', text: 'No account, no internet. Your cutlings sync only through your own iCloud.', y: 444 },
  ] });
  // The guide plays the real Settings steps as a short video; drawn here as its first frames.
  const settingsVideo = (t) => {
    const on = (t % 3) > 1.4;
    return `<div style="position:absolute;left:28px;top:200px;width:384px;height:210px;border-radius:18px;background:#f2f2f7;overflow:hidden;box-shadow:inset 0 0 0 1px rgba(0,0,0,.06)">
      <div style="position:absolute;left:0;right:0;top:14px;text-align:center;font-size:13px;font-weight:600">Keyboards</div>
      <div style="position:absolute;left:16px;right:16px;top:44px;height:88px;border-radius:14px;background:#fff">
        <div style="position:absolute;left:14px;right:14px;top:0;height:44px;display:flex;align-items:center;justify-content:space-between;font-size:14px">Cutling<div style="width:38px;height:23px;border-radius:12px;background:${on ? '#34c759' : '#e9e9eb'};position:relative"><div style="position:absolute;top:2px;left:${on ? 17 : 2}px;width:19px;height:19px;border-radius:50%;background:#fff;box-shadow:0 1px 3px rgba(0,0,0,.2)"></div></div></div>
        <div style="position:absolute;left:14px;right:0;top:44px;height:.5px;background:rgba(60,60,67,.18)"></div>
        <div style="position:absolute;left:14px;right:14px;top:44px;height:44px;display:flex;align-items:center;justify-content:space-between;font-size:14px">Allow Full Access<div style="width:38px;height:23px;border-radius:12px;background:#e9e9eb;position:relative"><div style="position:absolute;top:2px;left:2px;width:19px;height:19px;border-radius:50%;background:#fff;box-shadow:0 1px 3px rgba(0,0,0,.2)"></div></div></div></div>
      <div style="position:absolute;left:12px;bottom:10px;width:26px;height:26px;border-radius:50%;background:rgba(0,0,0,.45);display:flex;align-items:center;justify-content:center"><div style="width:0;height:0;border-left:9px solid #fff;border-top:6px solid transparent;border-bottom:6px solid transparent;margin-left:2px"></div></div></div>`;
  };
  const step = (n, html, y) => `<div style="position:absolute;left:28px;top:${y}px;width:384px;display:flex;gap:12px;font-size:16px;line-height:1.35"><div style="flex:none;width:24px;height:24px;border-radius:50%;background:${K.C.brand};color:#fff;font-size:13px;font-weight:700;display:flex;align-items:center;justify-content:center">${n}</div><div>${html}</div></div>`;
  const addPage = (t) => K.guidePage({ title: 'Add the Keyboard', subtitle: 'Turn on Cutling in Settings, then come back.', button: 'Open Settings', link: 'About Full Access', buttonPress: t >= T.openSettings && t < T.openSettings + 0.12,
    inner: settingsVideo(t) + step(1, 'Open Cutling in your device’s <b>Settings</b> app.', 432) + step(2, 'Tap <b>Keyboards</b> and enable <b>Cutling</b>.', 482) + step(3, 'Turn on <b>Allow Full Access</b> so the keyboard can copy images to your clipboard.', 532) });
  const tryPage = (t) => {
    const typed = t >= T.typed;
    const focused = t >= T.field;
    return K.guidePage({ title: 'Try It', subtitle: 'Type with Cutling here.', button: '', inner: `
      <div style="position:absolute;left:28px;top:200px;width:384px;height:52px;border-radius:14px;background:#f2f2f7;display:flex;align-items:center;padding-left:16px;font-size:17px;color:${typed ? '#000' : 'rgba(60,60,67,.5)'}">${typed ? 'Cutling typed this for me' : (focused ? '' : 'Tap here')}${focused ? `<span style="display:inline-block;width:2px;height:20px;background:${K.C.brand};margin-left:1px"></span>` : ''}</div>
      <div style="position:absolute;left:28px;top:266px;width:384px;font-size:15px;line-height:1.35;color:${typed ? K.C.accent : 'rgba(60,60,67,.6)'};font-weight:${typed ? 600 : 400}">${typed ? '✓ Cutling typed it. You’re set.' : 'Touch and hold the globe below, choose Cutling, then tap Try Me.'}</div>
      <div style="position:absolute;left:40px;top:470px;width:360px;height:54px;border-radius:27px;background:${K.C.brand};display:flex;align-items:center;justify-content:center;color:#fff;font-size:18px;font-weight:600">Continue</div>` });
  };

  function screen(t) {
    let content = '', kb = '', over = '', time = '9:41';
    if (t < T.addPage) { content = welcome(); over = K.touch(220, 875, t, T.cont, 0.1); }
    else if (t < T.settings) { content = addPage(t); over = K.touch(220, 875, t, T.openSettings, 0.1); }
    else if (t < T.tryPage) {
      content = K.settingsKeyboards({ cutlingOn: t >= T.tglCutling + 0.08, fullOn: t >= T.allow + 0.1, alert: t >= T.alert && t < T.allow + 0.12, alertPress: t >= T.allow && t < T.allow + 0.12 });
      // opened from the app, Settings shows "◀ Cutling" where the clock was
      content += `<div style="position:absolute;left:34px;top:20px;font-size:15px;font-weight:600;color:#000;z-index:50">◀ Cutling</div>`;
      time = '';
      over = K.touch(386, 166, t, T.tglCutling, 0.1) + K.touch(386, 218, t, T.tglFull, 0.1) + K.touch(304, 524, t, T.allow, 0.1) + K.touch(52, 20, t, T.back, 0.1);
    } else if (t < T.toMessages) {
      content = tryPage(t);
      if (t >= T.field && t < T.cutling) kb = K.systemKeyboard({}) + (t >= T.globeDown + 0.2 ? K.globeMenu({ p: K.seg(t, T.globeDown + 0.2, T.globeDown + 0.4), chosen: t > T.globeDown + 0.75 ? 'Cutling' : 'English (US)' }) : '');
      if (t >= T.cutling) kb = K.cutlingKeyboard({ cards: [{ name: 'Try Me', icon: 'wave', color: K.C.brand, preview: 'Cutling typed this for me' }], press: t >= T.tryMe && t < T.tryMe + 0.12 ? 0 : -1, inserted: t >= T.typed && t < T.typed + 0.8 ? 0 : -1 });
      const p = K.ease.inOut(K.seg(t, T.globeDown + 0.45, T.globeDown + 0.7));
      over = K.touch(220, 226, t, T.field, 0.1) + K.touch(K.lerp(44, 80, p), K.lerp(915, 806, p), t, T.globeDown, T.globeUp - T.globeDown) + K.touch(112, 687, t, T.tryMe, 0.1);
    } else {
      const landed = t >= T.maya + 0.12;
      content = K.messagesNew({ to: 'Maya', text: landed ? 'Hi Maya, your order ships Friday.' : '' });
      if (t >= T.panel && t < T.maya + 0.12) kb = K.cutlingKeyboard({ mode: 'fill', fill: { sentence: K.fillSentence(['Hi ', { label: 'Name', active: true }, ', your order ships Friday.']), values: [...S.seed.names, '__paste'], press: t >= T.maya && t < T.maya + 0.12 ? 0 : -1, last: true } });
      else kb = K.cutlingKeyboard({ cards: S.seed.shop(false), press: t >= T.tapReply && t < T.tapReply + 0.12 ? 0 : -1, inserted: landed && t < T.maya + 0.9 ? 0 : -1 });
      over = K.touch(112, 687, t, T.tapReply, 0.1) + K.touch(77, 729, t, T.maya, 0.1);
    }
    return K.iphone({ content, keyboard: kb, over, time });
  }

  const LINES = {
    intro: { n: '', text: 'Set up in<br>three steps' },
    s1: { n: '1', text: 'Turn on the keyboard in Settings' },
    trust: { n: '', text: 'iOS shows this warning for every keyboard' },
    s2: { n: '2', text: 'Hold the globe, pick Cutling' },
    s3: { n: '3', text: 'Tap to type' },
    after: { n: '', text: 'Then tap to type in any app' },
  };
  const caps = (t) => S.fades(t, [[0, 'intro'], [T.addPage + 0.1, 's1'], [T.alert, 'trust'], [T.allow + 0.3, 's1'], [9.07, 's2'], [11.33, 's3'], [T.toMessages, 'after'], [T.endCard, 'end']], 0.3);

  function words(t, d) {
    const f = caps(t);
    let h = '';
    for (const [k, v] of Object.entries(LINES)) {
      const o = f[k] || 0;
      if (o < 0.001) continue;
      if (v.n) h += S.text(v.n, { x: d.x, y: d.y - d.num * 0.12, w: d.num, size: d.num, weight: 800, color: K.C.brand, lh: 1, opacity: o });
      h += S.text(v.text, { x: v.n ? d.x + d.num * 0.78 : d.x, y: d.y + (v.n ? d.num * 0.08 : 0), w: v.n ? d.w - d.num * 0.78 : d.w, size: d.size, color: K.C.ink, lh: 1.08, opacity: o });
    }
    if ((f.end || 0) > 0.001) {
      h += S.text('Set up once.<br>Use it anywhere.', { x: d.x, y: d.y - 10, w: d.w, size: d.size * 1.15, color: K.C.ink, lh: 1.02, opacity: f.end });
      h += S.brand({ x: d.x, y: d.y + d.size * 2.9, icon: d.icon, size: d.brand, color: K.C.ink, opacity: f.end });
    }
    return h;
  }

  const iphone = {
    W: 886, H: 1920, L, loopDissolve: 0.6,
    draw(t) {
      const s = 1.38;
      return `<div style="position:absolute;inset:0;background:${K.C.tint}"></div>` + words(t, { x: 72, y: 110, w: 760, size: 80, num: 220, icon: 96, brand: 50 }) +
        S.place(screen(t), { x: (886 - 440 * s) / 2, y: 560, s, radius: `${62 * s}px`, shadow: '0 36px 80px rgba(11,59,46,.22)' });
    },
    stills: [
      { t: 0, name: 'iphone-01', note: 'Frame 0: Set up in three steps, the guide’s first page' },
      { t: 2.6, name: 'iphone-02', note: '1: the guide plays the Settings steps' },
      { t: 6.2, name: 'iphone-03', note: 'At Apple’s Full Access warning: iOS shows it for every keyboard' },
      { t: 10.3, name: 'iphone-04', note: '2: hold the globe, pick Cutling' },
      { t: 12.4, name: 'iphone-05', note: '3: tap to type, the guide says you’re set' },
      { t: 16.3, name: 'iphone-06', note: 'Then tap to type in any app' },
      { t: 21.8, name: 'iphone-07', note: 'End: Set up once. Use it anywhere.' },
    ],
    poster: 10.3,
    seam: { kind: 'dissolve', signals: { 'end card (opacity)': (t) => caps(t).end || 0, 'first line (opacity)': (t) => caps(t).intro || 0 } },
  };

  // iPad: the guide as a centred sheet over Cutling's grid
  const ipad = {
    W: 1200, H: 1600, L,
    draw(t) {
      const tt = 5.7;
      const sheet = `<div style="position:absolute;left:186px;top:200px;width:660px;height:900px;border-radius:30px;overflow:hidden;box-shadow:0 30px 80px rgba(0,0,0,.25)"><div style="transform:scale(1.5);transform-origin:0 0;width:440px;height:600px;position:relative">${K.settingsKeyboards({ cutlingOn: true, fullOn: false, alert: true }).replace(/height:956px/g, 'height:600px')}</div></div>`;
      const grid = `<div style="position:absolute;inset:0;background:#f2f2f7"></div><div style="position:absolute;inset:0;background:rgba(0,0,0,.28)"></div>`;
      const scr = K.ipad({ content: grid + sheet });
      return `<div style="position:absolute;inset:0;background:${K.C.tint}"></div>` +
        S.text('iOS shows this warning for every keyboard', { x: 84, y: 90, w: 1032, size: 64, color: K.C.ink, lh: 1.08 }) +
        S.place(scr, { x: (1200 - 1032 * 0.88) / 2, y: 330, s: 0.88, w: 1032, h: 1376, radius: '28px', shadow: '0 36px 80px rgba(11,59,46,.22)' });
    },
    stills: [{ t: 5.7, name: 'ipad-01', note: 'iPad: the Full Access warning, answered' }],
  };

  // Mac: the first run is the menu bar and one shortcut
  const mac = {
    W: 1920, H: 1080, L,
    draw() {
      const win = `<div style="position:absolute;left:470px;top:150px;width:560px;height:560px;border-radius:16px;background:#fff;box-shadow:0 30px 80px rgba(0,0,0,.35);font-family:-apple-system,system-ui;text-align:center">
        <div style="position:absolute;left:18px;top:18px;display:flex;gap:8px">${['#ff5f57', '#febc2e', '#28c840'].map((c) => `<div style="width:13px;height:13px;border-radius:50%;background:${c}"></div>`).join('')}</div>
        <div style="position:absolute;left:0;right:0;top:120px;font-size:28px;font-weight:700">Summon Cutling from anywhere</div>
        <div style="position:absolute;left:60px;right:60px;top:170px;font-size:16px;line-height:1.45;color:#555">Press ⌘⇧V from any app to open a floating picker at your cursor. Pick a cutling and it’s ready to paste, no menu bar trip required.</div>
        <div style="position:absolute;left:0;right:0;top:290px;display:flex;justify-content:center">${K.keycaps(['⌘', '⇧', 'V'], 0, 0, 70, 1, false).replace('position:absolute;left:0px;top:0px;', 'position:relative;')}</div>
        <div style="position:absolute;left:150px;right:150px;bottom:40px;height:44px;border-radius:12px;background:${K.C.brand};color:#fff;font-weight:600;font-size:16px;display:flex;align-items:center;justify-content:center">Continue</div></div>`;
      const desk = K.macDesktop({}) + K.macMenuBar({ app: 'Cutling', cutlingActive: true }) + win;
      return S.place(desk, { x: 0, y: 0, s: 1920 / 1512, w: 1512, h: 982, clipBottom: 982 - 1080 / (1920 / 1512) }) +
        `<div style="position:absolute;left:0;top:0;width:640px;height:1080px;background:linear-gradient(90deg,rgba(232,246,240,.97) 70%,rgba(232,246,240,0))"></div>` +
        S.text('One shortcut opens Cutling in any app', { x: 80, y: 420, w: 520, size: 64, color: K.C.ink, lh: 1.1 });
    },
    stills: [{ t: 0, name: 'mac-01', note: 'Mac: the welcome window teaches ⌘⇧V' }],
  };

  window.FILMS['e-first-minute'] = { iphone, ipad, mac };
})();
