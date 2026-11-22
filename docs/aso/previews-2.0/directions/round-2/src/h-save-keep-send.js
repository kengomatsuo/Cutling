// Direction H, "Save, keep, send": an overview of what Cutling is by how it works, in three chapters, each with
// its real control. Save: share the studio's address from a page in Safari to Cutling, and name it. Keep: Cutling's
// grid, and a reply shaped like a note, given a blank for the name with the page's own Ask Each Time button (2.0).
// Send: one tap in Messages, the keyboard asking the name. Chapter words set huge on the brand's three grounds.
// (The keyboard's Add from Clipboard would name the key "Clip:" with today's date, which a preview must not show.)
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 10 * B;
  const T = { save: 1 * B, hold: 1 * B + 0.1, menu: 1 * B + 0.65, share: 1 * B + 1.1, sheet: 1 * B + 1.25, cutling: 1 * B + 1.9, ours: 1 * B + 2.05, done: 1 * B + 3.2, gone: 1 * B + 3.35,
    keep: 3 * B, tapOrder: 3 * B + 0.6, page: 3 * B + 0.8, ask: 3 * B + 1.7, blank: 3 * B + 1.8, ok: 3 * B + 2.9, pill: 3 * B + 3.05,
    send: 5 * B, sendOrder: 5 * B + 0.55, maya: 5 * B + 1.5, end: 7 * B };
  // what Save adds: the studio's address, named by hand in Cutling's sheet; a new cutling goes to the end of the list
  const studio = { name: 'Studio address', icon: 'pin', color: '#f08a24', preview: '22 Mill Lane, Studio 4' };
  const base = K.everyday(false).filter((c) => c.name !== 'Studio address');
  const after = base.concat([studio]);   // Home, Order update, Bank details, Wi-Fi, Thank you, Studio address

  function saveScreen(t) {
    const sel = t >= T.hold + 0.4;
    const body = `<div style="font-size:24px;font-weight:700;margin-bottom:14px">Pottery class</div>
      <div>Thanks for booking. We start at 10 and finish by 1, with coffee at half time.</div>
      <div style="margin-top:14px">Where: <span style="${sel ? 'background:rgba(10,124,255,.22);' : ''}padding:1px 2px">22 Mill Lane, Studio 4</span></div>
      <div style="margin-top:14px;color:#6e6e73">Bring nothing; we have aprons.</div>`;
    let content = K.safariPage({ body, addr: 'Pottery class', menu: t >= T.menu && t < T.sheet, menuPress: t >= T.share && t < T.share + 0.12 ? 3 : -1 });
    // iOS's share sheet, then Cutling's own sheet over it
    if (t >= T.sheet && t < T.ours + 0.3) content += K.shareSheet({ head: '22 Mill Lane, Studio 4', sub: 'Plain Text · Options ›', thumb: '#e9e9ee', press: t >= T.cutling && t < T.cutling + 0.12, p: K.ease.out(K.seg(t, T.sheet, T.sheet + 0.3)) });
    if (t >= T.ours && t < T.gone + 0.3) {
      const up = K.ease.out(K.seg(t, T.ours, T.ours + 0.3)) * (1 - K.ease.inOut(K.seg(t, T.gone, T.gone + 0.3)));
      content += `<div style="position:absolute;inset:0;background:rgba(0,0,0,${0.25 * up})"></div>` + K.cutlingShare({ name: 'Studio address', text: '22 Mill Lane, Studio 4', p: up, donePress: t >= T.done && t < T.done + 0.12 });
    }
    const over = K.touch(167, 212, t, T.hold, 0.45) + K.touch(332, 290, t, T.share, 0.1) + K.touch(303, 636, t, T.cutling, 0.1) + K.touch(379, 102, t, T.done, 0.1);
    return K.iphone({ content, over });
  }

  function keepScreen(t) {
    if (t < T.page) {
      return K.iphone({ content: K.mainGrid({ count: '6 Cutlings', cards: after, press: t >= T.tapOrder && t < T.tapOrder + 0.12 ? 1 : -1 }), over: K.touch(324, 277, t, T.tapOrder, 0.1) });
    }
    const pill = t >= T.pill;
    const caret = `<span style="display:inline-block;width:2px;height:22px;background:${K.C.brand};vertical-align:-4px"></span>`;
    const body = `<div style="font-weight:700;font-size:24px">Order update</div><div style="height:8px"></div>Hi ${pill ? K.pill('Name', false, 19) : ''}${caret}, your order ships ${K.pill('Friday', false, 19)}.`;
    let content = K.textPage({ body, barItems: K.pageBar, active: { ask: t >= T.ask && t < T.ask + 0.14 } });
    if (t >= T.blank && t < T.pill + 0.3) {
      const up = K.ease.out(K.seg(t, T.blank, T.blank + 0.3)) * (1 - K.ease.inOut(K.seg(t, T.pill, T.pill + 0.3)));
      content += K.blankSheet({ p: up, okPress: t >= T.ok && t < T.ok + 0.12 });
    }
    return K.iphone({ content, over: K.touch(92.5, 533, t, T.ask, 0.1) + K.touch(400, 520, t, T.ok, 0.1) });
  }

  function sendScreen(t) {
    const text = t >= T.maya + 0.1 ? 'Hi Maya, your order ships Friday.' : '';
    const kb = t >= T.sendOrder + 0.14 && t < T.maya + 0.1 ? K.orderFill(t >= T.maya && t < T.maya + 0.12 ? 0 : -1)
      : K.cutlingKeyboard({ cards: after, press: t >= T.sendOrder && t < T.sendOrder + 0.12 ? 1 : -1, inserted: t >= T.maya + 0.1 && t < T.maya + 0.8 ? 1 : -1 });
    return K.iphone({ content: K.messagesNew({ to: 'Maya', text }), keyboard: kb, over: K.touch(K.cardXY(1).x, K.cardXY(1).y, t, T.sendOrder, 0.1) + K.touch(K.valueXY(0).x, K.valueXY(0).y, t, T.maya, 0.1) });
  }

  const chapters = [
    { at: T.save, word: 'Save', sub: 'Share it to Cutling wherever you find it', bg: K.C.tint, fg: K.C.bandFrom, subFg: K.C.accent, screen: saveScreen },
    { at: T.keep, word: 'Keep', sub: 'Shape it like a note, with a blank for the name', bg: '#ffffff', fg: K.C.bandFrom, subFg: K.C.accent, screen: keepScreen },
    { at: T.send, word: 'Send', sub: 'One tap puts it in any app', bg: K.C.bandFrom, fg: '#ffffff', subFg: K.C.accentDk, screen: sendScreen },
  ];

  function chapterFrame(t, c, d) {
    let h = `<div style="position:absolute;inset:0;background:${c.bg}"></div>`;
    h += S.text(c.word, { x: d.x, y: d.y, w: d.w, size: d.word, weight: 800, color: c.fg, lh: 1, ls: '-0.04em' });
    h += S.text(c.sub, { x: d.x + 4, y: d.y + d.word * 1.02, w: d.w, size: d.sub, weight: 600, color: c.subFg, lh: 1.18 });
    h += S.place(c.screen(t), { x: d.sx, y: d.sy, s: d.s, radius: `${62 * d.s}px`, shadow: '0 30px 80px rgba(0,0,0,.18)' });
    return h;
  }
  function poster(d, o = 1) {
    return `<div style="position:absolute;inset:0;background:${K.C.tint};opacity:${o}">` +
      ['Save', 'Keep', 'Send'].map((w, i) => S.text(w, { x: d.x, y: d.py + i * d.pword * 0.98, w: d.w, size: d.pword, weight: 800, color: i === 2 ? K.C.brand : K.C.bandFrom, lh: 1, ls: '-0.045em' })).join('') +
      S.text('Everything you type twice, kept in Cutling', { x: d.x + 6, y: d.py + 3 * d.pword * 0.98 + 30, w: d.w - 40, size: d.sub, weight: 600, color: K.C.accent, lh: 1.2 }) + `</div>`;
  }

  function frame(t, d) {
    const idx = t < T.save ? -1 : t < T.keep ? 0 : t < T.send ? 1 : t < T.end ? 2 : 3;
    let h = '';
    if (idx === -1) h += poster(d);
    else if (idx < 3) {
      h += chapterFrame(t, chapters[idx], d);
      const a = chapters[idx].at, p = K.seg(t, a, a + 0.35);
      if (p < 1) h = `<div style="position:absolute;inset:0">${idx === 0 ? poster(d) : chapterFrame(a - 0.01, chapters[idx - 1], d)}</div><div style="position:absolute;inset:0;opacity:${K.ease.inOut(p)}">${h}</div>`;
    } else {
      const p = K.ease.inOut(K.seg(t, T.end, T.end + 0.4));
      h += `<div style="position:absolute;inset:0">${chapterFrame(T.end - 0.01, chapters[2], d)}</div><div style="position:absolute;inset:0;opacity:${p}">` +
        `<div style="position:absolute;inset:0;background:${K.C.bandFrom}"></div>` +
        S.text('Save · Keep · Send', { x: d.x, y: d.ey, w: d.w, size: d.endSize, color: '#fff', lh: 1.02 }) +
        S.text('On iPhone, iPad and Mac, with one purchase', { x: d.x + 4, y: d.ey + d.endSize * 1.25, w: d.w, size: d.sub, weight: 600, color: K.C.accentDk, lh: 1.2 }) +
        S.brand({ x: d.x, y: d.ey + d.endSize * 1.25 + d.sub * 2.9, icon: d.icon, size: d.brand }) + `</div>`;
    }
    return h;
  }

  const iphone = {
    W: 886, H: 1920, L, loopDissolve: 0.6,
    draw: (t) => frame(t, { x: 72, y: 70, w: 760, word: 190, sub: 46, sx: (886 - 440 * 1.4) / 2, sy: 560, s: 1.4, py: 300, pword: 300, ey: 640, endSize: 96, icon: 104, brand: 54 }),
    stills: [
      { t: 0, name: 'iphone-01', note: 'Frame 0 and poster: Save, Keep, Send' },
      { t: 3.0, name: 'iphone-02', note: 'Save: the studio’s address selected in Safari, Share…' },
      { t: 5.0, name: 'iphone-03', note: 'Save: Cutling’s sheet, named Studio address' },
      { t: 9.4, name: 'iphone-04', note: 'Keep: the reply as a page; Ask Each Time' },
      { t: 10.4, name: 'iphone-05', note: 'Keep: a blank for the name' },
      { t: 12.8, name: 'iphone-06', note: 'Send: the keyboard asks the name' },
      { t: 18.5, name: 'iphone-07', note: 'End: Save · Keep · Send, on iPhone, iPad and Mac' },
    ],
    poster: 0,
    seam: { kind: 'dissolve', signals: { 'end card (opacity)': (t) => (t >= T.end ? K.ease.inOut(K.seg(t, T.end, T.end + 0.4)) : 0) } },
  };

  // iPad: Keep, the reply as a page at full size with Variables open
  const ipad = {
    W: 1200, H: 1600, L,
    draw() {
      const body = `<div style="font-weight:700;font-size:34px">Order update</div><div style="height:10px"></div><div style="font-size:28px;line-height:1.5">Hi ${K.pill('Name', false, 27)}, your order ships ${K.pill('Friday', false, 27)}.</div>`;
      const page = `<div style="position:absolute;left:70px;top:130px;width:880px">${body}</div><div style="position:absolute;left:380px;top:36px;width:280px;height:48px;border-radius:24px;background:#fff;box-shadow:0 2px 10px rgba(0,0,0,.12);display:flex;justify-content:space-around;align-items:center;font-size:20px"><b>Aa</b>${K.icon('textbox', 22, '#000')}${K.icon('braces', 22, K.C.brand)}${K.icon('cal', 21, '#000')}</div>`;
      const scr = K.ipad({ content: page });
      return `<div style="position:absolute;inset:0;background:#fff"></div>` + S.text('Keep', { x: 84, y: 60, w: 1000, size: 170, weight: 800, color: K.C.bandFrom, lh: 1, ls: '-0.04em' }) +
        S.text('Shape it like a note, with a blank for the name', { x: 88, y: 240, w: 1000, size: 44, weight: 600, color: K.C.accent }) +
        S.place(scr, { x: 84, y: 360, s: 1032 / 1032, w: 1032, h: 1376, clipBottom: 1376 - 1180, radius: '30px', shadow: '0 30px 80px rgba(0,0,0,.16)' });
    },
    stills: [{ t: 0, name: 'ipad-01', note: 'iPad: Keep, the reply as a page with its blank' }],
  };

  // Mac: Save from the clipboard history, the Mac's own way in
  const mac = {
    W: 1920, H: 1080, L,
    draw() {
      const rows = [
        { name: '22 Mill Lane, Studio 4', icon: 'clip', color: K.C.brand, preview: '' },
        { name: 'Back in stock on Friday', icon: 'clip', color: K.C.brand, preview: '' },
        { name: 'Thanks, see you at ten!', icon: 'clip', color: K.C.brand, preview: '' },
      ];
      let picker = K.macPicker({ x: 620, y: 230, rows, hover: 0, tab: 'history', count: 7 });
      // the row's menu (MacPickerView.swift): Copy, Save as Cutling, then Remove from History
      picker += `<div style="position:absolute;left:880px;top:300px;width:210px;border-radius:10px;background:rgba(250,250,250,.98);box-shadow:0 10px 30px rgba(0,0,0,.25);font:14px -apple-system,system-ui;overflow:hidden;padding:5px 0"><div style="padding:6px 12px">Copy</div><div style="padding:6px 12px;margin:0 5px;border-radius:6px;background:${K.C.brand};color:#fff">Save as Cutling</div><div style="height:1px;background:rgba(0,0,0,.1);margin:5px 12px"></div><div style="padding:6px 12px;color:#e5443b">Remove from History</div></div>`;
      const desk = K.macDesktop({}) + K.macMenuBar({ app: 'Safari', cutlingActive: true }) + picker;
      return S.place(desk, { x: 0, y: 0, s: 1920 / 1512, w: 1512, h: 982, clipBottom: 982 - 1080 / (1920 / 1512) }) +
        `<div style="position:absolute;left:0;top:0;width:720px;height:1080px;background:linear-gradient(90deg,rgba(232,246,240,.98) 70%,rgba(232,246,240,0))"></div>` +
        S.text('Save', { x: 80, y: 300, w: 600, size: 190, weight: 800, color: K.C.bandFrom, lh: 1, ls: '-0.04em' }) +
        S.text('What you copy on the Mac waits in History; keep the ones you reuse', { x: 86, y: 520, w: 520, size: 38, weight: 600, color: K.C.accent, lh: 1.2 });
    },
    stills: [{ t: 0, name: 'mac-01', note: 'Mac: Save, from the clipboard history' }],
  };

  window.FILMS['h-save-keep-send'] = { iphone, ipad, mac };
})();
