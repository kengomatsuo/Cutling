// Cutling 2.0 preview directions: a UI kit that draws Cutling's real screens in points, to the
// measurements of the store simulators (iPhone 18 Pro Max 440 x 956 pt, iPad Air 13-inch 1032 x 1376 pt)
// and of the app's own code (CutlingKeyboard/KeyboardViewController.swift KeyStyle, FillInPanel.swift).
// These drawings stand in for the store-simulator takes until they are recorded; every frame in the
// directions says so. Nothing here ships.
(function () {
  const K = {};

  // ---------- motion ----------
  K.clamp = (x, a = 0, b = 1) => Math.min(b, Math.max(a, x));
  K.seg = (t, a, b) => K.clamp((t - a) / (b - a));
  K.lerp = (a, b, p) => a + (b - a) * p;
  K.ease = {
    inOut: (p) => (p < 0.5 ? 4 * p * p * p : 1 - Math.pow(-2 * p + 2, 3) / 2),
    out: (p) => 1 - Math.pow(1 - p, 3),
    in: (p) => p * p * p,
    sine: (p) => -(Math.cos(Math.PI * p) - 1) / 2,
  };
  // "Complicated" (Arulo, Mixkit 281): a steady fit to its 191 measured beats gives 105.9 BPM.
  K.BPM = 105.88;
  K.BAR = (60 / K.BPM) * 4; // 2.2667 s
  K.bar = (n) => n * K.BAR;
  K.esc = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

  // ---------- colours (site tokens in web/style.css, keyboard colours sampled from a store-simulator take) ----------
  K.C = {
    brand: '#00be86', accent: '#007a56', accentDk: '#3ad6a6', bandFrom: '#0b3b2e', bandTo: '#0d5c45', tint: '#e8f6f0',
    ink: '#1d1d1f', ink2: '#55555b', ink3: '#6e6e73', paper: '#fbfbfa',
    kb: '#dfe1e5', key: '#fdfdfd', kbDk: '#1f1f21', keyDk: '#3a3a3d', blue: '#0a7cff', bubble: '#e7e7ed',
    secondary: 'rgba(60,60,67,0.6)', secondaryDk: 'rgba(235,235,245,0.6)', sep: 'rgba(60,60,67,0.18)', sepDk: 'rgba(84,84,88,0.6)',
    pill: '#d9f3e9', pillText: '#0a8a63', pillDk: '#14463a', pillTextDk: '#5fe0b8', highlight: '#efd2fb',
  };

  // ---------- icons: 24 x 24 strokes drawn after SF Symbols ----------
  const P = {
    globe: '<circle cx="12" cy="12" r="9.2"/><path d="M2.8 12h18.4M12 2.8c2.6 2.6 3.9 5.6 3.9 9.2s-1.3 6.6-3.9 9.2M12 2.8C9.4 5.4 8.1 8.4 8.1 12s1.3 6.6 3.9 9.2M4.6 7.2h14.8M4.6 16.8h14.8"/>',
    mic: '<rect x="8.6" y="2.6" width="6.8" height="12" rx="3.4"/><path d="M5.4 11.2a6.6 6.6 0 0 0 13.2 0M12 17.8v3.6"/>',
    del: '<path d="M8.6 5h11.2a1.6 1.6 0 0 1 1.6 1.6v10.8a1.6 1.6 0 0 1-1.6 1.6H8.6L2.6 12z"/><path d="M11.4 9.2l5.4 5.6M16.8 9.2l-5.4 5.6"/>',
    ret: '<path d="M19.6 5.4v5.2a3 3 0 0 1-3 3H5"/><path d="M8.8 9.6 4.8 13.6l4 4"/>',
    arrowR: '<path d="M4 12h15.6M13.4 5.8 19.6 12l-6.2 6.2"/>',
    check: '<path d="M4.6 12.6 9.6 17.4 19.4 6.8"/>',
    xmark: '<path d="M6 6l12 12M18 6 6 18"/>',
    keyboard: '<rect x="2.4" y="5.6" width="19.2" height="12.8" rx="2.2"/><path d="M6 9.4h.01M9.3 9.4h.01M12.6 9.4h.01M15.9 9.4h.01M18.2 9.4h.01M6 12.4h.01M9.3 12.4h.01M12.6 12.4h.01M15.9 12.4h.01M18.2 12.4h.01M7.8 15.4h8.4"/>',
    clip: '<rect x="7.4" y="5.2" width="11.4" height="15.4" rx="2"/><path d="M5.2 16.6V4.4a1.8 1.8 0 0 1 1.8-1.8h8.6"/><path d="M10.4 4.4h5.4" stroke-width="2.6"/>',
    open: '<rect x="3.4" y="3.4" width="17.2" height="17.2" rx="3.6"/><path d="M9.6 14.4l5.6-5.6M10.4 8.8h4.8v4.8"/>',
    plus: '<path d="M12 4.6v14.8M4.6 12h14.8"/>',
    chevL: '<path d="M14.8 4.6 7.4 12l7.4 7.4"/>',
    up: '<path d="M12 19V5.6M6 11.4 12 5.4l6 6"/>',
    envelope: '<rect x="2.8" y="5.2" width="18.4" height="13.6" rx="2"/><path d="m3.4 6.4 8.6 6.6 8.6-6.6"/>',
    box: '<path d="M12 2.8 20.4 7.4v9.2L12 21.2l-8.4-4.6V7.4z"/><path d="M3.8 7.4 12 12l8.2-4.6M12 12v9.2M7.8 5.1l8.4 4.6"/>',
    cal: '<rect x="3.2" y="4.6" width="17.6" height="16" rx="2.4"/><path d="M3.2 9.4h17.6M8 2.6v4M16 2.6v4"/>',
    clock: '<circle cx="12" cy="12" r="9"/><path d="M12 6.8V12l3.6 2.2"/>',
    house: '<path d="M3.6 10.8 12 3.8l8.4 7"/><path d="M5.8 9v11.2h12.4V9"/><path d="M10 20.2v-5.6h4v5.6"/>',
    bank: '<rect x="2.4" y="6" width="19.2" height="12" rx="1.8"/><circle cx="12" cy="12" r="2.6"/><path d="M5.4 9.2v.01M18.6 14.8v.01"/>',
    wifi: '<path d="M2.6 9.2a13.6 13.6 0 0 1 18.8 0M5.8 12.6a9 9 0 0 1 12.4 0M9 16a4.4 4.4 0 0 1 6 0"/><circle cx="12" cy="19.2" r=".9"/>',
    wave: '<path d="M7.4 12.4 5 10a1.6 1.6 0 0 1 2.3-2.3l3.2 3.2M10.6 10.9 7 7.3a1.6 1.6 0 0 1 2.3-2.3l4 4M12.6 8.6l-1.4-1.4a1.6 1.6 0 0 1 2.3-2.3l4.2 4.2a6.6 6.6 0 0 1 0 9.3 6.6 6.6 0 0 1-9.3 0L5.2 15"/>',
    fork: '<path d="M7 2.8v7.4a2.4 2.4 0 0 0 4.8 0V2.8M9.4 2.8v18.4M17 21.2V2.8c-2 1.4-3 3.8-3 7.2v3.6h3"/>',
    pin: '<path d="M12 21.4s6.8-6.2 6.8-11.6a6.8 6.8 0 0 0-13.6 0c0 5.4 6.8 11.6 6.8 11.6z"/><circle cx="12" cy="9.8" r="2.4"/>',
    sparkle: '<path d="M12 3.2c.7 4.6 2.9 6.9 7.6 7.6-4.7.7-6.9 3-7.6 7.6-.7-4.6-2.9-6.9-7.6-7.6 4.7-.7 6.9-3 7.6-7.6z"/>',
    highlighter: '<path d="m14.6 4.4 5 5-8.4 8.4H6.2v-5z"/><path d="M4 21h9"/>',
    link: '<path d="M10 14a4.4 4.4 0 0 0 6.2 0l3-3a4.4 4.4 0 0 0-6.2-6.2l-1.2 1.2"/><path d="M14 10a4.4 4.4 0 0 0-6.2 0l-3 3a4.4 4.4 0 0 0 6.2 6.2l1.2-1.2"/>',
    code: '<path d="M8.4 6.4 2.8 12l5.6 5.6M15.6 6.4l5.6 5.6-5.6 5.6M13.8 4.2l-3.6 15.6"/>',
    listBullet: '<circle cx="4.6" cy="6.4" r="1.2" fill="currentColor"/><circle cx="4.6" cy="12" r="1.2" fill="currentColor"/><circle cx="4.6" cy="17.6" r="1.2" fill="currentColor"/><path d="M9 6.4h11.4M9 12h11.4M9 17.6h11.4"/>',
    listDash: '<path d="M3.2 6.4h3M3.2 12h3M3.2 17.6h3M9 6.4h11.4M9 12h11.4M9 17.6h11.4"/>',
    listNum: '<path d="M3.4 4.6h1.4v4M3.2 8.6h3M3.2 13.6c0-1 .8-1.6 1.6-1.6s1.4.6 1.4 1.4c0 1.2-3 2.2-3 3.4h3M9 6.4h11.4M9 12h11.4M9 17.6h11.4"/>',
    braces: '<path d="M8.4 3.4c-2 0-2.6.8-2.6 2.6v2.6c0 1.6-.8 2.6-2.4 3.4 1.6.8 2.4 1.8 2.4 3.4V18c0 1.8.6 2.6 2.6 2.6M15.6 3.4c2 0 2.6.8 2.6 2.6v2.6c0 1.6.8 2.6 2.4 3.4-1.6.8-2.4 1.8-2.4 3.4V18c0 1.8-.6 2.6-2.6 2.6"/>',
    search: '<circle cx="10.6" cy="10.6" r="6.6"/><path d="m15.6 15.6 5 5"/>',
    gear: '<circle cx="12" cy="12" r="3.2"/><path d="M12 2.8v2.6M12 18.6v2.6M2.8 12h2.6M18.6 12h2.6M5.5 5.5l1.8 1.8M16.7 16.7l1.8 1.8M5.5 18.5l1.8-1.8M16.7 7.3l1.8-1.8"/>',
    trash: '<path d="M4.4 6.6h15.2M9.4 6.6V4.2h5.2v2.4M6.4 6.6l1 13.6h9.2l1-13.6"/>',
    question: '<circle cx="12" cy="12" r="9"/><path d="M9.4 9.4a2.6 2.6 0 1 1 3.8 2.4c-.8.4-1.2 1-1.2 1.8v.6M12 17.2v.01"/>',
    power: '<path d="M12 3v8.4"/><path d="M6.6 6.4a7.6 7.6 0 1 0 10.8 0"/>',
    lock: '<rect x="5.2" y="10.6" width="13.6" height="10" rx="2"/><path d="M8.2 10.6V7.8a3.8 3.8 0 0 1 7.6 0v2.8"/>',
    photo: '<rect x="3" y="4.6" width="18" height="14.8" rx="2.4"/><circle cx="8.6" cy="9.6" r="1.8"/><path d="m3.4 17.2 5.4-5 4.2 3.8 2.8-2.4 5 4.2"/>',
    sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2.4v2.2M12 19.4v2.2M2.4 12h2.2M19.4 12h2.2M5.2 5.2l1.6 1.6M17.2 17.2l1.6 1.6M5.2 18.8l1.6-1.6M17.2 6.8l1.6-1.6"/>',
    moon: '<path d="M19.6 14.6A8.2 8.2 0 0 1 9.4 4.4a8.2 8.2 0 1 0 10.2 10.2z"/>',
    person: '<circle cx="12" cy="8" r="3.8"/><path d="M4.6 20.4c.8-3.8 3.8-5.8 7.4-5.8s6.6 2 7.4 5.8"/>',
    ellipsis: '<circle cx="5.4" cy="12" r="1.3" fill="currentColor"/><circle cx="12" cy="12" r="1.3" fill="currentColor"/><circle cx="18.6" cy="12" r="1.3" fill="currentColor"/>',
    undo: '<path d="M8.6 13.6 4 9l4.6-4.6"/><path d="M4.4 9h10a5.6 5.6 0 0 1 0 11.2h-3.2"/>',
    textbox: '<rect x="2.6" y="5.2" width="18.8" height="13.6" rx="2"/><path d="M8.4 15.4 11 8.6h.6l2.6 6.8M9.2 13.4h4.6M16.6 8.8v6.4"/>',
    shield: '<path d="M12 2.8 19.4 5.8v5.6c0 4.6-3 8.2-7.4 9.8-4.4-1.6-7.4-5.2-7.4-9.8V5.8z"/><path d="m8.8 12 2.2 2.2 4.2-4.4"/>',
    cloud: '<path d="M7 18.4h10.4a4 4 0 0 0 .6-8 6 6 0 0 0-11.6 1.4A3.4 3.4 0 0 0 7 18.4z"/>',
    tag: '<path d="M3.4 12.6V4.4a1 1 0 0 1 1-1h8.2l8.4 8.4a1.4 1.4 0 0 1 0 2l-6.2 6.2a1.4 1.4 0 0 1-2 0z"/><circle cx="8" cy="8" r="1.4"/>',
    doc: '<path d="M6 2.8h8.2l4.4 4.4v13.2a.8.8 0 0 1-.8.8H6a.8.8 0 0 1-.8-.8V3.6a.8.8 0 0 1 .8-.8z"/><path d="M14 2.8v4.6h4.6M8.4 12.4h7.2M8.4 16h7.2"/>',
    ticket: '<path d="M3 7.6V5.4h18v2.2a2.4 2.4 0 0 0 0 4.8v2.2a2.4 2.4 0 0 0 0 4.8v-.2H3v.2a2.4 2.4 0 0 0 0-4.8v-2.2a2.4 2.4 0 0 0 0-4.8z"/><path d="M9.4 5.4v13.2" stroke-dasharray="2 2"/>',
    car: '<path d="M4.6 16.4V12l2-5.4h10.8l2 5.4v4.4"/><path d="M3.4 16.4h17.2v2.4H3.4zM4.6 12h14.8"/><circle cx="7.6" cy="14.2" r=".6"/><circle cx="16.4" cy="14.2" r=".6"/>',
    ruler: '<rect x="2.6" y="7.4" width="18.8" height="9.2" rx="1.4"/><path d="M6.4 7.4v3.4M10.2 7.4v2.2M14 7.4v3.4M17.8 7.4v2.2"/>',
    return: '<path d="M9 14.6 4.4 10 9 5.4"/><path d="M4.8 10h9.6a5.2 5.2 0 0 1 0 10.4H12"/>',
  };
  K.icon = (name, size = 17, color = 'currentColor', weight = 1.7) =>
    `<svg width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="${color}" stroke-width="${weight}" stroke-linecap="round" stroke-linejoin="round" style="display:block;color:${color}">${P[name] || ''}</svg>`;

  // ---------- small helpers ----------
  const abs = (x, y, w, h, extra = '') => `position:absolute;left:${x}px;top:${y}px;width:${w}px;height:${h}px;${extra}`;
  K.abs = abs;
  K.div = (style, html = '') => `<div style="${style}">${html}</div>`;

  // A fill-in or stamp as the editor and cards draw it: a mint pill as tall as the line (FillInPills.swift).
  K.pill = (label, dark, size) =>
    `<span style="display:inline-block;background:${dark ? K.C.pillDk : K.C.pill};color:${dark ? K.C.pillTextDk : K.C.pillText};border-radius:${(size || 15) * 0.32}px;padding:0 ${(size || 15) * 0.28}px;line-height:1.25;font-size:${size ? size * 0.92 + 'px' : '0.92em'}">${K.esc(label)}</span>`;

  // A touch hotspot (App Review allows them): brand ring, in at 0.12 s, held while pressed, out over 0.3 s.
  K.touch = (x, y, t, at, hold = 0.14, dark = false) => {
    const a = t - at;
    if (a < -0.06 || a > hold + 0.34) return '';
    const inP = K.ease.out(K.seg(a, -0.06, 0.08));
    const outP = K.seg(a, hold, hold + 0.32);
    const s = 0.72 + 0.28 * inP + 0.12 * outP;
    const o = inP * (1 - outP);
    return `<div style="${abs(x - 23, y - 23, 46, 46)};border-radius:50%;border:3px solid ${K.C.brand};background:rgba(0,190,134,${dark ? 0.32 : 0.22});transform:scale(${s});opacity:${o};box-shadow:0 0 0 1px rgba(255,255,255,0.7)"></div>`;
  };

  // ---------- iPhone 18 Pro Max, 440 x 956 pt ----------
  K.statusBar = (dark, time = '9:41', w = 440) => {
    const c = dark ? '#fff' : '#000';
    return `<div style="${abs(0, 0, w, 54)};color:${c};font:600 17px/1 -apple-system,system-ui;z-index:40">
      <div style="${abs(40, 21, 70, 20)};text-align:center;letter-spacing:-0.2px">${time}</div>
      <div style="${abs(157, 11, 126, 37)};background:#000;border-radius:19px"></div>
      <div style="${abs(300, 22, 80, 14)};display:flex;align-items:flex-end;gap:2.4px">${[5, 7.4, 9.8, 12].map((h) => `<div style="width:3.2px;height:${h}px;background:${c};border-radius:1px"></div>`).join('')}
        <svg width="17" height="13" viewBox="0 0 17 13" style="margin-left:5px"><path d="M8.5 12.2 6.2 9.7a3.4 3.4 0 0 1 4.6 0zM3.8 7.4a6.8 6.8 0 0 1 9.4 0l-1.5 1.6a4.6 4.6 0 0 0-6.4 0zM1.3 4.9a10.4 10.4 0 0 1 14.4 0l-1.5 1.6a8.2 8.2 0 0 0-11.4 0z" fill="${c}"/></svg>
        <div style="margin-left:5px;width:25px;height:12.4px;border:1.2px solid ${dark ? 'rgba(255,255,255,.45)' : 'rgba(0,0,0,.4)'};border-radius:4px;padding:1.4px;box-sizing:border-box"><div style="width:100%;height:100%;background:${c};border-radius:2px"></div></div></div>
    </div>`;
  };

  // The phone's whole screen. `content` is drawn on a white or black page; `keyboard` sits over it.
  K.iphone = ({ dark = false, time = '9:41', content = '', keyboard = '', over = '', radius = 62, bg } = {}) =>
    `<div style="position:relative;width:440px;height:956px;overflow:hidden;border-radius:${radius}px;background:${bg || (dark ? '#000' : '#fdfdfd')};font-family:-apple-system,system-ui;color:${dark ? '#fff' : '#000'};-webkit-font-smoothing:antialiased">
      ${content}${keyboard}${K.statusBar(dark, time)}${over}
      <div style="${abs(146, 942, 148, 5)};border-radius:3px;background:${dark ? 'rgba(255,255,255,.7)' : 'rgba(0,0,0,.8)'};z-index:41"></div>
    </div>`;

  // Messages: a new message to one person, the compose field above the keyboard (iOS 27 layout, drawn).
  // text: HTML of what is in the field; size: the field's type size (17, or larger for Dynamic Type).
  K.messagesNew = ({ dark = false, to = 'Maya', text = '', size = 17, kbTop = 569, caret = true, caretBlink = 1, maxLines = 14, scrollLines = 0 } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const sec = dark ? K.C.secondaryDk : K.C.secondary;
    const sep = dark ? K.C.sepDk : K.C.sep;
    const glass = dark ? 'rgba(60,60,64,.8)' : 'rgba(255,255,255,.92)';
    const lineH = size * 1.3;
    const fieldW = 365;
    const linesGuess = text ? Math.max(1, K.lineCount(text, size, fieldW - 52)) : 1;
    const shown = Math.min(linesGuess, maxLines);
    const fieldH = Math.max(40, shown * lineH + 14);
    const fieldTop = kbTop - 10 - fieldH;
    const hasText = !!text;
    return `
      <div style="${abs(0, 54, 440, 120)};font-family:-apple-system,system-ui">
        <div style="${abs(18, 6, 44, 44)};border-radius:50%;background:${glass};box-shadow:0 1px 4px rgba(0,0,0,.12);display:flex;align-items:center;justify-content:center">${K.icon('xmark', 18, fg, 2.2)}</div>
        <div style="${abs(0, 18, 440, 22)};text-align:center;font-weight:600;font-size:17px;color:${fg}">New Message</div>
        <div style="${abs(20, 70, 400, 24)};font-size:17px;color:${sec}">To: <span style="color:${K.C.blue}">${K.esc(to)}</span></div>
        <div style="${abs(394, 66, 30, 30)};display:flex;align-items:center;justify-content:center">${K.icon('plus', 22, K.C.blue, 2)}</div>
        <div style="${abs(20, 108, 420, 0.5)};background:${sep}"></div>
      </div>
      <div style="${abs(12, kbTop - 10 - 40, 38, 38)};border-radius:50%;background:${dark ? '#2c2c2e' : '#ececf0'};display:flex;align-items:center;justify-content:center">${K.icon('plus', 20, dark ? '#bbb' : '#666', 2)}</div>
      <div style="${abs(57, fieldTop, fieldW, fieldH)};border-radius:20px;border:1.2px solid ${dark ? '#3a3a3c' : '#d4d4d8'};background:${dark ? '#1c1c1e' : '#fff'};box-sizing:border-box;overflow:hidden">
        <div style="position:absolute;left:14px;right:40px;bottom:6px;font-size:${size}px;line-height:${lineH}px;color:${hasText ? fg : sec};white-space:pre-wrap;word-wrap:break-word;transform:translateY(${scrollLines * lineH}px)">${hasText ? text : 'Message'}${caret && caretBlink ? `<span style="display:inline-block;width:2px;height:${size * 1.1}px;background:${K.C.blue};vertical-align:-${size * 0.18}px;margin-left:1px"></span>` : ''}</div>
        ${hasText ? `<div style="position:absolute;right:5px;bottom:5px;width:29px;height:29px;border-radius:50%;background:${K.C.blue};display:flex;align-items:center;justify-content:center">${K.icon('up', 17, '#fff', 2.6)}</div>` : ''}
      </div>`;
  };

  // Rough line count for laying out a text field: plain-text length against characters per line.
  K.lineCount = (html, size, width) => {
    const text = String(html).replace(/<br\s*\/?>/g, '\n').replace(/<[^>]+>/g, '').replace(/&amp;/g, '&');
    const perLine = Math.max(8, Math.floor(width / (size * 0.5)));
    return text.split('\n').reduce((n, line) => n + Math.max(1, Math.ceil(line.length / perLine)), 0);
  };

  // The keyboard panel behind any keyboard (system or Cutling): iOS 26 glass, rounded top.
  const panel = (dark, top = 569) => `<div style="${abs(0, top, 440, 956 - top)};background:${dark ? K.C.kbDk : K.C.kb};border-radius:28px 28px 62px 62px"></div>`;
  const sysRow = (dark, top = 569) => {
    const c = dark ? '#d8d8dc' : '#3a3a3c';
    return `<div style="${abs(26, 897, 36, 36)};display:flex;align-items:center;justify-content:center">${K.icon('globe', 27, c, 1.6)}</div>
            <div style="${abs(378, 897, 36, 36)};display:flex;align-items:center;justify-content:center">${K.icon('mic', 25, c, 1.7)}</div>`;
  };

  // A Cutling card as the keyboard draws it: colored symbol and bold name, then a one-line preview with pills.
  K.card = (c, w, h, dark, opts = {}) => {
    const bg = dark ? K.C.keyDk : K.C.key;
    const fg = dark ? '#fff' : '#000';
    const sec = dark ? K.C.secondaryDk : 'rgba(60,60,67,0.62)';
    const pressed = opts.pressed ? `filter:brightness(${dark ? 1.5 : 0.86})` : '';
    const ns = opts.nameSize || 15, ps = opts.previewSize || 13;
    const inserted = opts.inserted
      ? `<div style="position:absolute;inset:0;border-radius:10px;background:${dark ? 'rgba(20,70,58,.94)' : 'rgba(217,243,233,.96)'};display:flex;align-items:center;justify-content:center;gap:6px;color:${dark ? K.C.pillTextDk : K.C.pillText};font-weight:600;font-size:${ns}px">${K.icon('check', ns + 2, dark ? K.C.pillTextDk : K.C.pillText, 2.4)}${opts.insertedLabel || 'Inserted'}</div>`
      : '';
    return `<div style="position:relative;width:${w}px;height:${h}px;border-radius:10px;background:${bg};box-shadow:0 1px 0 rgba(0,0,0,${dark ? 0.35 : 0.08});box-sizing:border-box;padding:${h * 0.17}px 11px 0;overflow:hidden;${pressed}">
      <div style="display:flex;align-items:center;gap:6px;font-weight:600;font-size:${ns}px;color:${fg};white-space:nowrap;overflow:hidden">${K.icon(c.icon || 'doc', ns, c.color || K.C.brand, 2)}<span style="overflow:hidden;text-overflow:ellipsis">${K.esc(c.name)}</span></div>
      <div style="margin-top:${h * 0.09}px;font-size:${ps}px;color:${sec};white-space:nowrap;overflow:hidden;text-overflow:ellipsis;${c.mono ? 'font-family:ui-monospace,Menlo;' : ''}">${c.preview || ''}</div>
      ${inserted}</div>`;
  };

  // The Cutling keyboard on iPhone. mode 'grid' shows the cards; mode 'fill' shows FillInPanel.swift's screen.
  K.cutlingKeyboard = ({ dark = false, mode = 'grid', cards = [], press = -1, inserted = -1, insertedLabel, fill = null, scroll = 0, returnIcon, sectionTitle } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const y0 = 587;
    let top = '', body = '';
    if (mode === 'grid') {
      top = `<div style="${abs(6, y0 + 6, 428, 44)};display:flex;align-items:center;justify-content:center;gap:6px;font-size:17px;color:${fg}">${K.icon('clip', 17, fg, 1.8)}<span>Add from Clipboard</span></div>
             <div style="${abs(392, y0 + 6, 44, 44)};display:flex;align-items:center;justify-content:center">${K.icon('open', 20, fg, 1.8)}</div>`;
      const W = 211, H = 64, G = 6;
      const items = cards.map((c, i) => {
        const col = i % 2, row = Math.floor(i / 2);
        return `<div style="${abs(6 + col * (W + G), y0 + 62 + 6 + row * (H + G) - scroll, W, H)}">${K.card(c, W, H, dark, { pressed: i === press, inserted: i === inserted, insertedLabel })}</div>`;
      }).join('');
      body = `<div style="${abs(0, y0 + 62, 440, 180)};overflow:hidden"><div style="position:absolute;left:0;top:${-(y0 + 62)}px;width:440px;height:956px">${sectionTitle ? `<div style="${abs(14, y0 + 62 + 2 - scroll, 300, 18)};font-size:13px;font-weight:600;color:${dark ? K.C.secondaryDk : K.C.secondary}">${sectionTitle}</div>` : ''}${items}</div></div>`;
    } else if (mode === 'fill' && fill) {
      top = `<div style="${abs(10, y0 + 6, 376, 44)};display:flex;align-items:center;justify-content:center;font-size:17px;color:${fg};white-space:nowrap;overflow:hidden">${fill.sentence}</div>
             <div style="${abs(392, y0 + 6, 44, 44)};display:flex;align-items:center;justify-content:center">${K.icon('xmark', 19, fg, 2)}</div>`;
      const keyBg = dark ? K.C.keyDk : K.C.key;
      const yk = y0 + 62;
      const values = fill.values || [];
      const cols = 3, kw = (428 - 2 * 6) / 3;
      const keys = values.map((v, i) => {
        const col = i % cols, row = Math.floor(i / cols);
        const isPaste = v === '__paste';
        const pressed = i === fill.press ? `filter:brightness(${dark ? 1.5 : 0.86})` : '';
        const label = isPaste ? `${K.icon('clip', 16, dark ? K.C.secondaryDk : '#8a8a8e', 1.8)}<span>Paste</span>` : `<span>${K.esc(v)}</span>${fill.chosen === v ? K.icon('check', 14, K.C.brand, 2.6) : ''}`;
        return `<div style="${abs(6 + col * (kw + 6), yk + 52 + 6 + row * 50, kw, 44)};border-radius:10px;background:${keyBg};box-shadow:0 1px 0 rgba(0,0,0,${dark ? 0.35 : 0.08});display:flex;align-items:center;justify-content:center;gap:6px;font-size:17px;color:${fg};${pressed}">${label}</div>`;
      }).join('');
      body = `<div style="${abs(6, yk, 428, 52)};border-radius:10px;background:${keyBg};box-shadow:0 1px 0 rgba(0,0,0,${dark ? 0.35 : 0.08});display:flex;align-items:center;justify-content:center;gap:8px;color:${K.C.brand};font-weight:600;font-size:17px;${fill.press === 'yours' ? `filter:brightness(${dark ? 1.5 : 0.86})` : ''}">${K.icon('keyboard', 20, K.C.brand, 1.8)}<span>Type with Your Keyboard</span></div>${keys}`;
    }
    const keyBg = dark ? K.C.keyDk : K.C.key;
    const isAction = mode === 'fill';
    const rIcon = returnIcon || (isAction ? (fill && fill.last ? 'check' : 'arrowR') : 'ret');
    const bottom = `<div style="${abs(6, 835, 52, 44)};border-radius:10px;background:${keyBg};box-shadow:0 1px 0 rgba(0,0,0,.08);display:flex;align-items:center;justify-content:center">${K.icon('del', 22, fg, 1.7)}</div>
      <div style="${abs(64, 835, 272, 44)};border-radius:10px;background:${keyBg};box-shadow:0 1px 0 rgba(0,0,0,.08)"></div>
      <div style="${abs(342, 835, 92, 44)};border-radius:10px;background:${isAction ? K.C.brand : keyBg};box-shadow:0 1px 0 rgba(0,0,0,.08);display:flex;align-items:center;justify-content:center">${K.icon(rIcon, 22, isAction ? '#fff' : fg, isAction ? 2.4 : 1.7)}</div>`;
    return panel(dark) + top + body + bottom + sysRow(dark);
  };

  // The system keyboard (English), with the predictive row, as iOS 27 draws it on this iPhone.
  K.systemKeyboard = ({ dark = false, predict = ['I', 'The', 'I’m'], shift = false, pressKey = null } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const keyBg = dark ? '#6b6b70' : '#fdfdfd';
    const modBg = dark ? '#47474b' : '#b4b8bf';
    const rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];
    const kw = 37.6, kh = 46, gx = 6.2;
    let html = panel(dark);
    html += `<div style="${abs(0, 586, 440, 36)};display:flex;align-items:center;font-size:17px;color:${fg}">${predict.map((p, i) => `<div style="flex:1;text-align:center;${i ? `border-left:1px solid ${dark ? '#555' : '#c3c6cc'};` : ''}">${K.esc(p)}</div>`).join('')}</div>`;
    const rowY = [630, 686, 742];
    rows.forEach((r, ri) => {
      const n = r.length;
      const total = n * kw + (n - 1) * gx;
      const x0 = (440 - total) / 2;
      [...r].forEach((ch, i) => {
        const pressed = pressKey === ch ? 'filter:brightness(.82)' : '';
        html += `<div style="${abs(x0 + i * (kw + gx), rowY[ri], kw, kh)};border-radius:8px;background:${keyBg};box-shadow:0 1px 0 rgba(0,0,0,.25);display:flex;align-items:center;justify-content:center;font-size:24px;color:${fg};${pressed}">${shift ? ch.toUpperCase() : ch}</div>`;
      });
    });
    html += `<div style="${abs(4, 742, 48, 46)};border-radius:8px;background:${modBg};display:flex;align-items:center;justify-content:center">${K.icon('up', 22, fg, 2)}</div>`;
    html += `<div style="${abs(388, 742, 48, 46)};border-radius:8px;background:${modBg};display:flex;align-items:center;justify-content:center">${K.icon('del', 22, fg, 1.7)}</div>`;
    html += `<div style="${abs(4, 798, 48, 46)};border-radius:8px;background:${modBg};display:flex;align-items:center;justify-content:center;font-size:16px;color:${fg}">123</div>`;
    html += `<div style="${abs(58, 798, 42, 46)};border-radius:8px;background:${modBg};display:flex;align-items:center;justify-content:center;font-size:20px">☺︎</div>`;
    html += `<div style="${abs(106, 798, 228, 46)};border-radius:8px;background:${keyBg};box-shadow:0 1px 0 rgba(0,0,0,.25);display:flex;align-items:flex-end;justify-content:flex-end;padding:0 8px 4px 0;box-sizing:border-box;font-size:10px;color:${dark ? '#bbb' : '#999'}">EN</div>`;
    html += `<div style="${abs(340, 798, 96, 46)};border-radius:8px;background:${modBg};display:flex;align-items:center;justify-content:center">${K.icon('ret', 22, fg, 1.8)}</div>`;
    return html + sysRow(dark);
  };

  // Holding the globe: the list of keyboards iOS shows, Cutling under the finger.
  K.globeMenu = ({ dark = false, chosen = 'Cutling', p = 1 } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const bg = dark ? 'rgba(44,44,46,.97)' : 'rgba(250,250,252,.97)';
    const rows = ['Keyboard Settings…', 'English (US)', 'Cutling'];
    const o = K.clamp(p * 1.4);
    return `<div style="${abs(18, 690, 250, 190)};border-radius:22px;background:${bg};box-shadow:0 12px 40px rgba(0,0,0,.25);opacity:${o};transform:scale(${0.92 + 0.08 * K.ease.out(K.clamp(p * 1.5))});transform-origin:20% 100%;font-size:17px;color:${fg};overflow:hidden">
      ${rows.map((r, i) => `<div style="${abs(8, 10 + i * 46, 234, 42)};border-radius:12px;padding-left:12px;display:flex;align-items:center;${r === chosen ? `background:${dark ? 'rgba(255,255,255,.14)' : 'rgba(0,0,0,.08)'}` : ''}">${r}</div>`).join('')}
      <div style="${abs(18, 150, 214, 30)};display:flex;justify-content:space-around;align-items:center;opacity:.55">${['keyboard', 'keyboard', 'keyboard'].map((n) => K.icon(n, 22, fg, 1.6)).join('')}</div>
    </div>`;
  };

  // The fill-in bar's sentence (FillInBar): words, the waiting blank in green with a 2 pt underline,
  // filled blanks as their value, other blanks as their name underlined in grey.
  K.fillSentence = (parts, dark) => '<span style="white-space:pre">' + parts.map((p) => {
    if (typeof p === 'string') return `<span>${K.esc(p)}</span>`;
    if (p.active) return `<span style="color:${K.C.brand};border-bottom:2px solid ${K.C.brand};padding-bottom:1px">${K.esc(p.value || p.label)}</span>`;
    if (p.value) return `<span>${K.esc(p.value)}</span>`;
    return `<span style="color:${dark ? K.C.secondaryDk : K.C.secondary};border-bottom:1px solid rgba(128,128,128,.5)">${K.esc(p.label)}</span>`;
  }).join('') + '</span>';

  // ---------- Cutling's Text page (TextPageView.swift): a page like Notes, with the glass bar above the keyboard ----------
  K.textPage = ({ dark = false, body = '', bar = 'styles', active = {}, formatCard = false, formatActive = {}, keyboard = 'system', caretAt = null, title = '', barItems = null } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const glass = dark ? 'rgba(58,58,60,.92)' : 'rgba(255,255,255,.95)';
    const shadow = '0 2px 10px rgba(0,0,0,.12)';
    let html = `<div style="${abs(18, 62, 46, 46)};border-radius:50%;background:${glass};box-shadow:${shadow};display:flex;align-items:center;justify-content:center">${K.icon('chevL', 20, fg, 2.2)}</div>
      <div style="${abs(376, 62, 46, 46)};border-radius:50%;background:${K.C.brand};display:flex;align-items:center;justify-content:center">${K.icon('check', 22, '#fff', 2.6)}</div>
      <div style="${abs(24, 126, 392, 420)};font-size:19px;line-height:1.42;color:${fg};overflow:hidden">${body}</div>`;
    const kbTop = 569;
    if (bar) {
      // round two passes the bar's first eight as the page now has them: Aa, the fill-ins, then the styles
      const items = barItems || [
        ['clip', 'clip'], ['b', 'B'], ['i', 'I'], ['u', 'U'], ['s', 'S'], ['hl', 'highlighter'], ['code', 'code'], ['link', 'link'],
      ];
      const glyph = (k, v) => {
        if (k === 'aa') return `<span style="font-size:19px;font-weight:600">Aa</span>`;
        if (k === 'b') return `<b style="font-size:20px">B</b>`;
        if (k === 'i') return `<i style="font-size:20px;font-family:Georgia,serif">I</i>`;
        if (k === 'u') return `<span style="font-size:19px;text-decoration:underline">U</span>`;
        if (k === 's') return `<span style="font-size:19px;text-decoration:line-through">S</span>`;
        return K.icon(v, 21, fg, 1.8);
      };
      html += `<div style="${abs(10, kbTop - 62, 420, 52)};border-radius:26px;background:${glass};box-shadow:${shadow};display:flex;align-items:center;justify-content:space-around;padding:0 6px;box-sizing:border-box;color:${fg}">
        ${items.map(([k, v]) => `<div style="width:42px;height:42px;border-radius:50%;display:flex;align-items:center;justify-content:center;${active[k] ? `background:${K.C.brand};color:#fff` : ''}">${active[k] && (k === 'b' || k === 'i' || k === 'u' || k === 's') ? glyph(k, v).replace(/<(b|i|span) style="/, '<$1 style="color:#fff;') : active[k] ? K.icon(v, 21, '#fff', 1.9) : glyph(k, v)}</div>`).join('')}
      </div>`;
    }
    if (keyboard === 'system') html += K.systemKeyboard({ dark });
    if (formatCard) html += K.formatCard({ dark, active: formatActive });
    return html;
  };

  // The Format card the Aa button opens, as Notes' card: styles, then lists.
  K.formatCard = ({ dark = false, active = {} } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const bg = dark ? '#2c2c2e' : '#f2f2f6';
    const key = dark ? '#3a3a3c' : '#e3e3e8';
    const cell = (inner, on, w = 46) => `<div style="width:${w}px;height:40px;display:flex;align-items:center;justify-content:center;${on ? `background:${K.C.brand};color:#fff;border-radius:10px` : ''}">${inner}</div>`;
    const styles = [
      cell(`<b style="font-size:19px">B</b>`, active.b), cell(`<i style="font-size:19px;font-family:Georgia,serif">I</i>`, active.i),
      cell(`<span style="font-size:18px;text-decoration:underline">U</span>`, active.u), cell(`<span style="font-size:18px;text-decoration:line-through">S</span>`, active.s),
    ].join('');
    const marks = [cell(K.icon('highlighter', 20, active.hl ? '#fff' : fg, 1.8), active.hl), cell(K.icon('code', 20, active.code ? '#fff' : fg, 1.8), active.code), cell(K.icon('link', 20, active.link ? '#fff' : fg, 1.8), active.link)].join('');
    const lists = [cell(K.icon('listBullet', 20, active.bullet ? '#fff' : fg, 1.8), active.bullet, 60), cell(K.icon('listDash', 20, active.dash ? '#fff' : fg, 1.8), active.dash, 60), cell(K.icon('listNum', 20, active.num ? '#fff' : fg, 1.8), active.num, 60)].join('');
    return `<div style="${abs(0, 640, 440, 316)};border-radius:32px 32px 62px 62px;background:${bg};box-shadow:0 -6px 30px rgba(0,0,0,.12);color:${fg}">
      <div style="${abs(22, 22, 200, 26)};font-size:20px;font-weight:700">Format</div>
      <div style="${abs(378, 16, 40, 40)};border-radius:50%;background:${key};display:flex;align-items:center;justify-content:center">${K.icon('xmark', 17, fg, 2.2)}</div>
      <div style="${abs(18, 76, 404, 48)};display:flex;gap:10px">
        <div style="flex:none;display:flex;background:${key};border-radius:12px;padding:4px">${styles}</div>
        <div style="flex:none;display:flex;background:${key};border-radius:12px;padding:4px">${marks}</div>
      </div>
      <div style="${abs(18, 138, 404, 48)};display:flex;gap:10px">
        <div style="flex:none;display:flex;background:${key};border-radius:12px;padding:4px">${lists}</div>
      </div>
    </div>`;
  };

  // ---------- the setup guide (SetupFlows.swift, SetupPages.swift, AppleSheet.swift): title top left, rows, one green button ----------
  K.guidePage = ({ dark = false, title = '', subtitle = '', rows = [], button = 'Continue', link = '', inner = '', buttonPress = false } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const sec = dark ? K.C.secondaryDk : K.C.secondary;
    return `<div style="${abs(0, 0, 440, 956)};background:${dark ? '#1c1c1e' : '#fff'}">
      <div style="${abs(28, 92, 384, 80)};font-size:30px;font-weight:700;line-height:1.15;color:${fg}">${title}${subtitle ? `<div style="font-size:20px;font-weight:400;color:${sec};margin-top:6px;line-height:1.3">${subtitle}</div>` : ''}</div>
      ${inner}
      ${rows.map((r, i) => `<div style="${abs(28, (r.y || 200 + i * 112), 384, 100)};display:flex;gap:16px">
        <div style="flex:none;width:40px;display:flex;justify-content:center;padding-top:2px">${K.icon(r.icon, 32, K.C.brand, 1.7)}</div>
        <div><div style="font-size:17px;font-weight:600;color:${fg}">${r.title}</div><div style="font-size:16px;color:${sec};line-height:1.3;margin-top:3px">${r.text}</div></div></div>`).join('')}
      ${link ? `<div style="${abs(0, 812, 440, 22)};text-align:center;font-size:16px;color:${K.C.accent};font-weight:600">${link}</div>` : ''}
      ${button ? `<div style="${abs(40, 848, 360, 54)};border-radius:27px;background:${K.C.brand};${buttonPress ? 'filter:brightness(.85);' : ''}display:flex;align-items:center;justify-content:center;color:#fff;font-size:18px;font-weight:600">${button}</div>` : ''}
    </div>`;
  };

  // Settings > Cutling > Keyboards, as iOS 27 draws it (rows on a grouped page).
  K.settingsKeyboards = ({ dark = false, cutlingOn = false, fullOn = false, alert = false, alertPress = false } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const bg = dark ? '#000' : '#f2f2f7';
    const cell = dark ? '#1c1c1e' : '#fff';
    const sw = (on) => `<div style="width:51px;height:31px;border-radius:16px;background:${on ? '#34c759' : (dark ? '#39393d' : '#e9e9eb')};position:relative"><div style="position:absolute;top:2px;left:${on ? 22 : 2}px;width:27px;height:27px;border-radius:50%;background:#fff;box-shadow:0 2px 4px rgba(0,0,0,.2)"></div></div>`;
    let html = `<div style="${abs(0, 0, 440, 956)};background:${bg}">
      <div style="${abs(18, 62, 46, 46)};border-radius:50%;background:${dark ? '#2c2c2e' : '#fff'};box-shadow:0 1px 4px rgba(0,0,0,.1);display:flex;align-items:center;justify-content:center">${K.icon('chevL', 20, fg, 2.2)}</div>
      <div style="${abs(0, 76, 440, 22)};text-align:center;font-size:17px;font-weight:600;color:${fg}">Keyboards</div>
      <div style="${abs(20, 140, 400, 104)};border-radius:24px;background:${cell}">
        <div style="${abs(18, 0, 364, 52)};display:flex;align-items:center;justify-content:space-between;font-size:17px;color:${fg}"><span>Cutling</span>${sw(cutlingOn)}</div>
        <div style="${abs(18, 52, 364, 0.5)};background:${dark ? K.C.sepDk : K.C.sep}"></div>
        <div style="${abs(18, 52, 364, 52)};display:flex;align-items:center;justify-content:space-between;font-size:17px;color:${fg}"><span>Allow Full Access</span>${sw(fullOn)}</div>
      </div>
      <div style="${abs(38, 256, 364, 60)};font-size:13px;line-height:1.35;color:${dark ? K.C.secondaryDk : K.C.secondary}">When using one of these keyboards, the keyboard can access all the data you type. <span style="color:${K.C.blue}">About Third-Party Keyboards &amp; Privacy…</span></div>
    </div>`;
    if (alert) {
      html += `<div style="${abs(0, 0, 440, 956)};background:rgba(0,0,0,.25)"></div>
      <div style="${abs(60, 340, 320, 230)};border-radius:28px;background:${dark ? 'rgba(44,44,46,.97)' : 'rgba(250,250,252,.98)'};text-align:center;color:${fg};padding:22px 20px 0;box-sizing:border-box">
        <div style="font-size:17px;font-weight:600;line-height:1.3">Allow Full Access for “Cutling” Keyboards?</div>
        <div style="font-size:13px;line-height:1.35;margin-top:8px">Full access allows the developer of this keyboard to transmit anything you type…</div>
        <div style="${abs(16, 160, 136, 48)};border-radius:24px;background:${dark ? '#3a3a3c' : '#e9e9ee'};display:flex;align-items:center;justify-content:center;font-size:17px">Don’t Allow</div>
        <div style="${abs(168, 160, 136, 48)};border-radius:24px;background:${K.C.blue};${alertPress ? 'filter:brightness(.85);' : ''}display:flex;align-items:center;justify-content:center;font-size:17px;color:#fff;font-weight:600">Allow</div>
      </div>`;
    }
    return html;
  };

  // ---------- iPad Air 13-inch, 1032 x 1376 pt ----------
  K.ipadStatus = (dark, time = '9:41') => {
    const c = dark ? '#fff' : '#000';
    return `<div style="${abs(0, 0, 1032, 30)};color:${c};font:600 15px/30px -apple-system,system-ui;z-index:40">
      <div style="position:absolute;left:24px;top:0">${time}</div>
      <div style="position:absolute;right:24px;top:9px;display:flex;align-items:center;gap:6px">
        <svg width="16" height="12" viewBox="0 0 17 13"><path d="M8.5 12.2 6.2 9.7a3.4 3.4 0 0 1 4.6 0zM3.8 7.4a6.8 6.8 0 0 1 9.4 0l-1.5 1.6a4.6 4.6 0 0 0-6.4 0zM1.3 4.9a10.4 10.4 0 0 1 14.4 0l-1.5 1.6a8.2 8.2 0 0 0-11.4 0z" fill="${c}"/></svg>
        <div style="width:24px;height:12px;border:1.2px solid ${dark ? 'rgba(255,255,255,.45)' : 'rgba(0,0,0,.4)'};border-radius:4px;padding:1.4px;box-sizing:border-box"><div style="width:100%;height:100%;background:${c};border-radius:2px"></div></div></div></div>`;
  };
  K.ipad = ({ dark = false, time = '9:41', content = '', keyboard = '', over = '', radius = 30, bg } = {}) =>
    `<div style="position:relative;width:1032px;height:1376px;overflow:hidden;border-radius:${radius}px;background:${bg || (dark ? '#000' : '#fdfdfd')};font-family:-apple-system,system-ui;color:${dark ? '#fff' : '#000'};-webkit-font-smoothing:antialiased">
      ${content}${keyboard}${K.ipadStatus(dark, time)}${over}
      <div style="${abs(441, 1362, 150, 5)};border-radius:3px;background:${dark ? 'rgba(255,255,255,.7)' : 'rgba(0,0,0,.8)'}"></div></div>`;

  // Messages on iPad: a new message in the conversation pane, the keyboard across the bottom.
  K.ipadMessages = ({ dark = false, to = 'Maya', text = '', size = 17, kbTop = 860, list = true } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const sec = dark ? K.C.secondaryDk : K.C.secondary;
    const side = list ? 330 : 0;
    const rows = [['Maya', 'New Message'], ['Jonas', 'Thanks, see you then'], ['Aiko', 'Is the blue one back?'], ['Sam', 'Perfect!'], ['Lea', 'Got it, thank you']];
    let html = '';
    if (list) {
      html += `<div style="${abs(0, 0, side, 1376)};background:${dark ? '#1c1c1e' : '#f6f6f8'}">
        <div style="${abs(22, 50, 280, 40)};font-size:30px;font-weight:700;color:${fg}">Messages</div>
        ${rows.map((r, i) => `<div style="${abs(12, 112 + i * 74, 306, 66)};border-radius:14px;${i === 0 ? `background:${dark ? '#3a3a3c' : '#e5e5ea'}` : ''}">
          <div style="${abs(12, 12, 42, 42)};border-radius:50%;background:${['#f08a5d', '#6c8cf5', '#a77bd6', '#4fb3a9', '#e57fa8'][i]};color:#fff;font-weight:600;font-size:18px;display:flex;align-items:center;justify-content:center">${r[0][0]}</div>
          <div style="${abs(66, 12, 230, 20)};font-size:16px;font-weight:600;color:${fg}">${r[0]}</div>
          <div style="${abs(66, 34, 230, 20)};font-size:14px;color:${sec}">${r[1]}</div></div>`).join('')}
      </div>`;
    }
    const W = 1032 - side;
    const lineH = size * 1.3;
    const lines = text ? K.lineCount(text, size, W - 150) : 1;
    const fieldH = Math.max(40, lines * lineH + 14);
    html += `<div style="${abs(side, 0, W, 1376)}">
      <div style="${abs(0, 44, W, 26)};text-align:center;font-size:17px;font-weight:600;color:${fg}">New Message</div>
      <div style="${abs(24, 86, W - 48, 24)};font-size:17px;color:${sec}">To: <span style="color:${K.C.blue}">${K.esc(to)}</span></div>
      <div style="${abs(24, 122, W - 24, 0.5)};background:${dark ? K.C.sepDk : K.C.sep}"></div>
      <div style="${abs(20, kbTop - 12 - 40, 38, 38)};border-radius:50%;background:${dark ? '#2c2c2e' : '#ececf0'};display:flex;align-items:center;justify-content:center">${K.icon('plus', 20, dark ? '#bbb' : '#666', 2)}</div>
      <div style="${abs(68, kbTop - 12 - fieldH, W - 92, fieldH)};border-radius:20px;border:1.2px solid ${dark ? '#3a3a3c' : '#d4d4d8'};background:${dark ? '#1c1c1e' : '#fff'};box-sizing:border-box;overflow:hidden">
        <div style="position:absolute;left:14px;right:44px;bottom:6px;font-size:${size}px;line-height:${lineH}px;color:${text ? fg : sec};white-space:pre-wrap">${text || 'Message'}<span style="display:inline-block;width:2px;height:${size * 1.1}px;background:${K.C.blue};vertical-align:-${size * 0.18}px;margin-left:1px"></span></div>
        ${text ? `<div style="position:absolute;right:5px;bottom:5px;width:29px;height:29px;border-radius:50%;background:${K.C.blue};display:flex;align-items:center;justify-content:center">${K.icon('up', 17, '#fff', 2.6)}</div>` : ''}
      </div></div>`;
    return html;
  };

  // The Cutling keyboard on iPad: 64 pt keys, 80 pt cards at 180 pt minimum width (five across), 8 pt spacing.
  K.ipadCutlingKeyboard = ({ dark = false, mode = 'grid', cards = [], press = -1, inserted = -1, fill = null, kbTop = 860, scroll = 0, insertedLabel } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const keyBg = dark ? K.C.keyDk : K.C.key;
    const y0 = kbTop + 10;
    let html = `<div style="${abs(0, kbTop, 1032, 1376 - kbTop)};background:${dark ? K.C.kbDk : K.C.kb};border-radius:26px 26px 30px 30px"></div>`;
    if (mode === 'grid') {
      html += `<div style="${abs(8, y0 + 8, 1016, 64)};display:flex;align-items:center;justify-content:center;gap:8px;font-size:19px;color:${fg}">${K.icon('clip', 20, fg, 1.8)}<span>Add from Clipboard</span></div>
        <div style="${abs(960, y0 + 8, 64, 64)};display:flex;align-items:center;justify-content:center">${K.icon('open', 23, fg, 1.8)}</div>`;
      const cols = 5, W = (1016 - 8 * 4) / cols, H = 80;
      html += `<div style="${abs(0, y0 + 80, 1032, 252)};overflow:hidden">` + cards.map((c, i) => {
        const col = i % cols, row = Math.floor(i / cols);
        return `<div style="${abs(8 + col * (W + 8), 8 + row * (H + 8) - scroll, W, H)}">${K.card(c, W, H, dark, { pressed: i === press, inserted: i === inserted, nameSize: 17, previewSize: 15, insertedLabel })}</div>`;
      }).join('') + `</div>`;
    } else if (fill) {
      html += `<div style="${abs(20, y0 + 8, 920, 64)};display:flex;align-items:center;justify-content:center;font-size:20px;color:${fg};white-space:nowrap">${fill.sentence}</div>
        <div style="${abs(960, y0 + 8, 64, 64)};display:flex;align-items:center;justify-content:center">${K.icon('xmark', 22, fg, 2)}</div>
        <div style="${abs(8, y0 + 80, 1016, 72)};border-radius:12px;background:${keyBg};display:flex;align-items:center;justify-content:center;gap:10px;color:${K.C.brand};font-weight:600;font-size:20px">${K.icon('keyboard', 24, K.C.brand, 1.8)}Type with Your Keyboard</div>`;
      const kw = (1016 - 16) / 3;
      html += (fill.values || []).map((v, i) => {
        const col = i % 3, row = Math.floor(i / 3);
        const isPaste = v === '__paste';
        return `<div style="${abs(8 + col * (kw + 8), y0 + 160 + row * 72, kw, 64)};border-radius:12px;background:${keyBg};display:flex;align-items:center;justify-content:center;gap:8px;font-size:20px;color:${fg};${fill.press === i ? 'filter:brightness(.86)' : ''}">${isPaste ? `${K.icon('clip', 19, '#8a8a8e', 1.8)}Paste` : K.esc(v)}</div>`;
      }).join('');
    }
    const isAction = mode === 'fill';
    html += `<div style="${abs(8, 1376 - 84, 90, 64)};border-radius:12px;background:${keyBg};display:flex;align-items:center;justify-content:center">${K.icon('globe', 26, fg, 1.6)}</div>
      <div style="${abs(106, 1376 - 84, 90, 64)};border-radius:12px;background:${keyBg};display:flex;align-items:center;justify-content:center">${K.icon('del', 26, fg, 1.7)}</div>
      <div style="${abs(204, 1376 - 84, 640, 64)};border-radius:12px;background:${keyBg}"></div>
      <div style="${abs(852, 1376 - 84, 172, 64)};border-radius:12px;background:${isAction ? K.C.brand : keyBg};display:flex;align-items:center;justify-content:center">${K.icon(isAction ? (fill && fill.last ? 'check' : 'arrowR') : 'ret', 26, isAction ? '#fff' : fg, isAction ? 2.4 : 1.7)}</div>`;
    return html;
  };

  // ---------- Mac: desktop, menu bar, a window, and Cutling's ⌘⇧V picker (MacPickerView.swift) ----------
  K.macMenuBar = ({ dark = false, app = 'Mail', time = 'Tue 9:41 AM', cutlingActive = false } = {}) => {
    const c = dark ? '#fff' : '#000';
    return `<div style="${abs(0, 0, 1512, 30)};background:${dark ? 'rgba(30,30,30,.55)' : 'rgba(246,246,246,.6)'};backdrop-filter:blur(20px);font:13.5px/30px -apple-system,system-ui;color:${c};z-index:30">
      <div style="position:absolute;left:18px;top:0;display:flex;gap:20px"><span style="font-size:16px"></span><b>${app}</b><span>File</span><span>Edit</span><span>View</span><span>Window</span><span>Help</span></div>
      <div style="position:absolute;right:16px;top:0;display:flex;gap:16px;align-items:center">
        <span style="display:inline-flex;width:22px;height:22px;border-radius:6px;align-items:center;justify-content:center;${cutlingActive ? `background:${dark ? 'rgba(255,255,255,.2)' : 'rgba(0,0,0,.12)'}` : ''}">${K.icon('tag', 16, c, 1.8)}</span>
        ${K.icon('wifi', 16, c, 1.8)}${K.icon('search', 15, c, 2)}<span>${time}</span></div></div>`;
  };

  K.macDesktop = ({ dark = false, wall } = {}) =>
    `<div style="${abs(0, 0, 1512, 982)};background:${wall || (dark ? 'radial-gradient(120% 90% at 30% 20%,#1f4b5e 0%,#142c3d 45%,#0a1420 100%)' : 'radial-gradient(120% 90% at 30% 20%,#bfe3ee 0%,#8fc3d9 40%,#5f97b8 100%)')}"></div>`;

  // A Mail compose window. body: HTML (formatted text keeps its HTML).
  K.macMail = ({ dark = false, x = 300, y = 120, w = 760, h = 640, to = 'Maya', subject = 'Your order', body = '', caret = true } = {}) => {
    const fg = dark ? '#eee' : '#1d1d1f';
    const bg = dark ? '#1e1e1e' : '#fff';
    const bar = dark ? '#2a2a2a' : '#f3f3f3';
    const sep = dark ? '#3a3a3a' : '#e2e2e2';
    return `<div style="${abs(x, y, w, h)};border-radius:14px;background:${bg};box-shadow:0 30px 80px rgba(0,0,0,.35),0 0 0 .5px rgba(0,0,0,.25);overflow:hidden;font-family:-apple-system,system-ui;color:${fg}">
      <div style="${abs(0, 0, w, 52)};background:${bar};border-bottom:1px solid ${sep}">
        <div style="position:absolute;left:18px;top:19px;display:flex;gap:8px">${['#ff5f57', '#febc2e', '#28c840'].map((c) => `<div style="width:13px;height:13px;border-radius:50%;background:${c}"></div>`).join('')}</div>
        <div style="position:absolute;left:0;right:0;top:16px;text-align:center;font-size:14px;font-weight:600">${K.esc(subject)}</div></div>
      <div style="${abs(22, 64, w - 44, 26)};font-size:14px;color:${dark ? '#999' : '#888'}">To: <span style="color:${fg}">${K.esc(to)}</span></div>
      <div style="${abs(22, 96, w - 22, 1)};background:${sep}"></div>
      <div style="${abs(22, 106, w - 44, 26)};font-size:14px;color:${dark ? '#999' : '#888'}">Subject: <span style="color:${fg}">${K.esc(subject)}</span></div>
      <div style="${abs(22, 138, w - 22, 1)};background:${sep}"></div>
      <div style="${abs(26, 156, w - 52, h - 170)};font-size:15px;line-height:1.5">${body}${caret ? `<span style="display:inline-block;width:1.5px;height:17px;background:${fg};vertical-align:-3px"></span>` : ''}</div></div>`;
  };

  // A Notes window (On My Mac): the Mac takes paste into Notes, which a fresh macOS user can use without an account.
  // Same arguments as macMail so a cut can use either; `subject` names the folder's note.
  K.macNotes = ({ dark = false, x = 300, y = 120, w = 760, h = 640, subject = 'Note', body = '', caret = true } = {}) => {
    const fg = dark ? '#eee' : '#1d1d1f';
    const side = dark ? '#262626' : '#f0f0ef';
    const bg = dark ? '#1e1e1e' : '#fff';
    const sep = dark ? '#3a3a3a' : '#e2e2e2';
    const sec = dark ? '#9a9a9a' : '#8a8a8e';
    return `<div style="${abs(x, y, w, h)};border-radius:14px;background:${bg};box-shadow:0 30px 80px rgba(0,0,0,.35),0 0 0 .5px rgba(0,0,0,.25);overflow:hidden;font-family:-apple-system,system-ui;color:${fg}">
      <div style="${abs(0, 0, 210, h)};background:${side};border-right:1px solid ${sep}">
        <div style="position:absolute;left:18px;top:19px;display:flex;gap:8px">${['#ff5f57', '#febc2e', '#28c840'].map((c) => `<div style="width:13px;height:13px;border-radius:50%;background:${c}"></div>`).join('')}</div>
        <div style="position:absolute;left:18px;top:62px;font-size:12px;font-weight:600;color:${sec}">On My Mac</div>
        <div style="position:absolute;left:10px;right:10px;top:84px;height:30px;border-radius:7px;background:${dark ? '#3a3a3c' : '#e2e2e0'};display:flex;align-items:center;gap:8px;padding-left:10px;font-size:14px">${K.icon('doc', 16, '#e7a92a', 1.8)}Notes</div></div>
      <div style="${abs(210, 0, w - 210, 52)};border-bottom:1px solid ${sep};display:flex;align-items:center;justify-content:flex-end;gap:22px;padding-right:22px;box-sizing:border-box;color:${sec}"><b style="font-size:17px;color:${sec}">Aa</b>${K.icon('listBullet', 18, sec, 1.8)}${K.icon('link', 18, sec, 1.8)}${K.icon('search', 17, sec, 2)}</div>
      <div style="${abs(236, 70, w - 262, h - 90)};font-size:15px;line-height:1.5">${body}${caret ? `<span style="display:inline-block;width:1.5px;height:17px;background:${fg};vertical-align:-3px"></span>` : ''}</div></div>`;
  };

  // The picker panel (360 x 514 pt): list of saved cutlings, or the short form for a cutling's blanks.
  K.macPicker = ({ dark = false, x = 0, y = 0, mode = 'list', rows = [], hover = -1, query = '', count = 11, form = null, tab = 'saved' } = {}) => {
    const fg = dark ? '#eee' : '#1d1d1f';
    const sec = dark ? '#9a9a9a' : '#8a8a8e';
    const bg = dark ? 'rgba(40,40,40,.97)' : 'rgba(255,255,255,.98)';
    const sep = dark ? '#3a3a3a' : '#e5e5e5';
    let inner = `<div style="${abs(16, 12, 328, 30)};display:flex;align-items:center;gap:8px;font-size:16px;color:${query ? fg : sec}">${K.icon('search', 17, sec, 2)}${query ? K.esc(query) + `<span style="display:inline-block;width:1.5px;height:18px;background:${fg}"></span>` : 'Search cutlings'}</div>`;
    if (mode === 'list') {
      const on = `font-weight:600;padding:3px 10px;border-radius:13px;background:${dark ? '#14463a' : '#d9f3e9'}`, off = `padding:3px 6px;color:${fg}`;
      inner += `<div style="${abs(16, 46, 328, 26)};display:flex;align-items:center;gap:8px;font-size:14px"><span style="${tab === 'saved' ? on : off}">Saved <span style="color:${sec};font-weight:400">${count.toLocaleString('en-US')}</span></span><span style="${tab === 'history' ? on : off}">History</span></div>
        <div style="${abs(0, 80, 360, 0.5)};background:${sep}"></div>`;
      inner += rows.map((r, i) => `<div style="${abs(6, 86 + i * 44, 348, 40)};border-radius:8px;${i === hover ? `background:${dark ? 'rgba(0,190,134,.28)' : 'rgba(0,190,134,.16)'}` : ''};display:flex;align-items:center;gap:10px;padding-left:10px;box-sizing:border-box">
          ${K.icon(r.icon || 'doc', 18, r.color || K.C.brand, 1.9)}<div style="min-width:0"><div style="font-size:14px;font-weight:600;color:${fg};white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${K.esc(r.name)}</div><div style="font-size:12px;color:${sec};white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${r.preview || ''}</div></div></div>`).join('');
    } else if (form) {
      inner += `<div style="${abs(0, 48, 360, 0.5)};background:${sep}"></div>
        <div style="${abs(16, 62, 328, 24)};display:flex;align-items:center;gap:8px;font-size:16px;font-weight:700;color:${fg}">${K.icon(form.icon || 'envelope', 19, K.C.brand, 1.8)}${K.esc(form.name)}</div>`;
      let yy = 100;
      form.fields.forEach((f) => {
        inner += `<div style="${abs(16, yy, 328, 18)};font-size:13px;font-weight:600;color:${fg}">${K.esc(f.label)}</div>
          <div style="${abs(16, yy + 22, 328, 34)};border-radius:8px;background:${dark ? '#1b1b1b' : '#f2f2f4'};border:1px solid ${f.focus ? K.C.brand : sep};box-sizing:border-box;padding-left:10px;display:flex;align-items:center;font-size:15px;color:${fg}">${f.value ? `<span style="${f.selected ? `background:${dark ? '#245e4c' : '#bfe9d9'};` : ''}">${K.esc(f.value)}</span>` : ''}${f.focus ? `<span style="display:inline-block;width:1.5px;height:17px;background:${fg};margin-left:1px"></span>` : ''}</div>`;
        yy += 62;
        if (f.chips && f.chips.length) {
          inner += `<div style="${abs(16, yy - 2, 328, 30)};display:flex;gap:6px">${f.chips.map((c) => `<span style="padding:4px 12px;border-radius:14px;font-size:13px;background:${c === f.value ? K.C.brand : (dark ? '#3a3a3a' : '#ececef')};color:${c === f.value ? '#fff' : fg}">${K.esc(c)}</span>`).join('')}</div>`;
          yy += 36;
        }
      });
      inner += `<div style="${abs(16, yy + 4, 328, 64)};border-radius:8px;background:${dark ? '#2f2f2f' : '#f6f6f8'};padding:9px 10px;box-sizing:border-box;font-size:13px;line-height:1.4;color:${sec}">${form.preview || ''}</div>
        <div style="${abs(166, 432, 80, 30)};border-radius:8px;background:${dark ? '#3a3a3a' : '#ececef'};display:flex;align-items:center;justify-content:center;font-size:14px;color:${fg}">Cancel</div>
        <div style="${abs(254, 432, 90, 30)};border-radius:8px;background:${K.C.brand};${form.press ? 'filter:brightness(.85);' : ''}display:flex;align-items:center;justify-content:center;font-size:14px;font-weight:600;color:#fff">${form.button || 'Paste'}</div>`;
    }
    inner += `<div style="${abs(0, 474, 360, 0.5)};background:${sep}"></div>
      <div style="${abs(14, 482, 332, 24)};display:flex;align-items:center;gap:16px;color:${fg}">${['plus', 'gear', 'trash', 'question'].map((n) => K.icon(n, 17, fg, 1.8)).join('')}<span style="flex:1"></span>${K.icon('power', 17, fg, 1.8)}</div>`;
    return `<div style="${abs(x, y, 360, 514)};border-radius:16px;background:${bg};box-shadow:0 24px 70px rgba(0,0,0,.4),0 0 0 .5px rgba(0,0,0,.3);overflow:hidden;font-family:-apple-system,system-ui">${inner}</div>`;
  };

  // Keycaps drawn for a Mac hotkey (a graphic hotspot, as the 1.6 Mac preview drew them).
  K.keycaps = (keys, x, y, size, p = 1, dark = true) => `<div style="${abs(x, y, keys.length * (size + 14), size)};display:flex;gap:14px;opacity:${p}">${keys.map((k) => `<div style="width:${size}px;height:${size}px;border-radius:${size * 0.2}px;background:${dark ? 'rgba(255,255,255,.95)' : '#fff'};box-shadow:0 ${size * 0.06}px 0 rgba(0,0,0,.25),0 8px 24px rgba(0,0,0,.25);display:flex;align-items:center;justify-content:center;font:600 ${size * 0.46}px -apple-system,system-ui;color:#1d1d1f">${k}</div>`).join('')}</div>`;

  window.K = K;
})();
