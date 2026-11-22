// Direction B, "Like a note": a cutling is written the way a note is (bold, a list, a highlight) on the
// new Text page, and one tap on the keyboard types all of it. White paper, small editorial type, and a
// camera that pushes in on the real controls and pulls back. Native capture is 3 px per point; the
// closest push here is 2.4 px per point, so nothing is enlarged past the recording.
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 11 * B;
  const T = {
    selTitle: 0.62, tapB: 1.2, selList: 2.55, tapAa: 3.15, card: 3.3, tapBullet: 3.95, closeCard: 4.55, cardOut: 4.7,
    selCode: 5.2, tapHl: 5.8, done: 7.15, toMessages: 7.6, tapCard: 4 * B, holdCard: 5.6 * B, copyMenu: 5.6 * B + 0.55, tapCopy: 6.3 * B, endCard: 8 * B,
  };
  const pushIn = [[0.35, 1.35, 1], [6.6, 7.3, 0], [9.3, 10.3, 2], [12.6, 13.3, 0]];
  // camera: 0 = whole screen floating, 1 = on the page's text, 2 = on the message field
  function camera(t) {
    const poses = [
      { s: 1.56, cx: 220, cy: 478 },
      { s: 2.1, cx: 220, cy: 470 },
      { s: 2.32, cx: 230, cy: 420 },
    ];
    let from = poses[0], to = poses[0], p = 1;
    let cur = 0;
    for (const [a, b, target] of pushIn) {
      if (t >= a) { from = poses[cur]; to = poses[target]; p = K.ease.inOut(K.seg(t, a, b)); if (t >= b) { cur = target; from = to = poses[cur]; p = 1; } else break; }
    }
    return { s: K.lerp(from.s, to.s, p), cx: K.lerp(from.cx, to.cx, p), cy: K.lerp(from.cy, to.cy, p) };
  }

  const ink = '#1c1c1e';
  function pageBody(t) {
    const bold = t >= T.tapB + 0.08;
    const selTitle = t >= T.selTitle && t < T.tapB + 0.4;
    const bullets = t >= T.tapBullet + 0.08;
    const selList = t >= T.selList && t < T.closeCard;
    const hl = t >= T.tapHl + 0.08;
    const selCode = t >= T.selCode && t < T.tapHl + 0.35;
    const sel = (on, html) => (on ? `<span style="background:rgba(10,124,255,.22)">${html}</span>` : html);
    const title = sel(selTitle, `<span style="font-weight:${bold ? 700 : 400};font-size:${bold ? 23 : 19}px">Welcome to the studio!</span>`);
    const code = hl ? `<span style="background:${K.C.highlight};border-radius:3px;padding:0 2px">4815</span>` : sel(selCode, '4815');
    const items = [`Door code ${code}`, 'Wi-Fi: studio-guest', 'Parking behind the bakery'];
    const list = items.map((it) => (bullets ? `<div style="padding-left:22px;text-indent:-16px">•&nbsp;&nbsp;${it}</div>` : `<div>${it}</div>`)).join('');
    return `${title}<div style="height:6px"></div><div>Everything for your first visit:</div>${sel(selList, `<div>${list}</div>`)}<div style="height:6px"></div><div>See you soon!</div>`;
  }

  function pageScreen(t) {
    const active = { b: t >= T.tapB + 0.08 && t < T.selList, hl: t >= T.tapHl + 0.08 && t < T.tapHl + 0.6 };
    const cardP = t >= T.card && t < T.cardOut ? K.ease.out(K.seg(t, T.card, T.card + 0.25)) * (1 - K.seg(t, T.closeCard, T.cardOut)) : 0;
    let content = K.textPage({ body: pageBody(t), active });
    if (cardP > 0) content += `<div style="position:absolute;inset:0;transform:translateY(${(1 - cardP) * 320}px)">${K.formatCard({ active: { bullet: t >= T.tapBullet + 0.05 } })}</div>`;
    const over = K.touch(98, 532, t, T.tapB, 0.1) + K.touch(36, 532, t, T.tapAa, 0.1) + K.touch(66, 802, t, T.tapBullet, 0.1) + K.touch(398, 676, t, T.closeCard, 0.1)
      + K.touch(268, 532, t, T.tapHl, 0.1) + K.touch(399, 85, t, T.done, 0.1);
    // Aa sits where the clipboard key is drawn when the bar shows its first page; the take's bar scrolls.
    return K.iphone({ content, over });
  }

  const card = { name: 'Studio welcome', icon: 'sparkle', color: K.C.brand, preview: '<b>Welcome to the studio!</b> Everything for your…' };
  const typed = 'Welcome to the studio!\nEverything for your first visit:\n•  Door code 4815\n•  Wi-Fi: studio-guest\n•  Parking behind the bakery\nSee you soon!';
  function messagesScreen(t) {
    const cards = [card].concat(S.seed.shop(false).slice(1, 6));
    const landed = t >= T.tapCard + 0.12;
    const copied = t >= T.tapCopy + 0.1 && t < T.tapCopy + 1.4;
    const hold = t >= T.holdCard && t < T.tapCopy;
    let kb = K.cutlingKeyboard({ cards, press: (t >= T.tapCard && t < T.tapCard + 0.12) || hold ? 0 : -1, inserted: copied ? 0 : (landed && t < T.tapCard + 0.8 ? 0 : -1), insertedLabel: copied ? 'Copied with formatting' : 'Inserted' });
    if (t >= T.copyMenu && t < T.tapCopy + 0.1) {
      kb += `<div style="position:absolute;left:30px;top:520px;width:250px;border-radius:16px;background:rgba(250,250,252,.98);box-shadow:0 10px 36px rgba(0,0,0,.22);font-size:17px;overflow:hidden">
        <div style="padding:12px 16px;display:flex;justify-content:space-between;align-items:center">Copy ${K.icon('clip', 18, '#000', 1.8)}</div></div>`;
    }
    const content = K.messagesNew({ to: 'Maya', text: landed ? K.esc(typed).replace(/\n/g, '<br>') : '' });
    const over = K.touch(112, 687, t, T.tapCard, 0.1) + K.touch(112, 687, t, T.holdCard, T.tapCopy - T.holdCard - 0.6) + K.touch(150, 543, t, T.tapCopy, 0.1);
    return K.iphone({ content, keyboard: kb, over });
  }

  const LINES = { c1: 'Write it like a note', c2: 'Bold the title, list the details', c3: 'Then one tap types all of it', c4: 'Hold it to copy the formatting too' };
  const caps = (t) => S.fades(t, [[0, 'c1'], [2.45, 'c2'], [T.toMessages + 0.6, 'c3'], [T.holdCard - 0.2, 'c4'], [T.endCard, 'end']], 0.34);

  const iphone = {
    W: 886, H: 1920, L, loopDissolve: 0.6,
    draw(t) {
      const f = caps(t);
      let h = `<div style="position:absolute;inset:0;background:${K.C.paper}"></div>`;
      // the end card holds the finished page, so the camera is back at rest
      const cam = camera(t);
      const screen = t < T.toMessages ? pageScreen(t) : (t < T.endCard ? messagesScreen(t) : pageScreen(T.done - 0.2));
      const mix = K.seg(t, T.toMessages - 0.25, T.toMessages + 0.15);
      const mix2 = K.seg(t, T.endCard - 0.3, T.endCard + 0.1);
      const place = (html, op) => {
        const x = 443 - cam.cx * cam.s, y = 1120 - cam.cy * cam.s;
        return S.place(html, { x, y, s: cam.s, radius: `${62 * cam.s}px`, shadow: '0 30px 80px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.06)', opacity: op });
      };
      if (t < T.toMessages + 0.15) h += place(pageScreen(Math.min(t, T.toMessages)), 1 - (t >= T.toMessages - 0.25 ? mix : 0));
      if (t >= T.toMessages - 0.25 && t < T.endCard + 0.1) h += place(messagesScreen(t), t < T.endCard - 0.3 ? mix : 1 - mix2);
      if (t >= T.endCard - 0.3) h += place(pageScreen(T.done - 0.2), mix2);
      // caption band
      h += `<div style="position:absolute;left:0;top:0;width:886px;height:380px;background:linear-gradient(180deg,${K.C.paper} 70%,rgba(251,251,250,0))"></div>`;
      for (const k of ['c1', 'c2', 'c3', 'c4']) if (f[k] > 0.001) h += S.text(LINES[k], { x: 72, y: 130, w: 760, size: 80, weight: 700, color: ink, lh: 1.08, opacity: f[k] });
      if ((f.end || 0) > 0.001) {
        h += `<div style="position:absolute;left:0;top:0;width:886px;height:520px;background:${K.C.paper};opacity:${f.end}"></div>`;
        h += S.text('Written like a note.<br>Typed in one tap.', { x: 72, y: 130, w: 760, size: 80, color: ink, opacity: f.end, lh: 1.08 });
        h += S.brand({ x: 72, y: 360, icon: 96, size: 50, color: ink, opacity: f.end });
      }
      return h;
    },
    stills: [
      { t: 0, name: 'iphone-01', note: 'Frame 0: the cutling as plain text, Write it like a note' },
      { t: 1.6, name: 'iphone-02', note: 'Bold, from the bar above the keyboard' },
      { t: 4.1, name: 'iphone-03', note: 'A bulleted list from the Format card' },
      { t: 6.2, name: 'iphone-04', note: 'The door code highlighted' },
      { t: 10.6, name: 'iphone-05', note: 'One tap types all of it into Messages' },
      { t: 14.3, name: 'iphone-06', note: 'Hold it to copy it with the formatting' },
      { t: 21.5, name: 'iphone-07', note: 'End: Write it once, like a note' },
    ],
    poster: 6.2,
    seam: {
      kind: 'dissolve',
      signals: {
        'camera scale': (t) => camera(t).s,
        'camera centre y (pt)': (t) => camera(t).cy,
        'end card (opacity)': (t) => caps(t).end || 0,
      },
    },
  };

  // ---------- iPad: the same page at full size, the Format card as the iPad's popover ----------
  const ipad = {
    W: 1200, H: 1600, L,
    draw(t) {
      const tt = 4.2;
      const body = pageBody(tt).replace(/font-size:23px/g, 'font-size:36px').replace(/font-size:19px/g, 'font-size:29px');
      const top = `<div style="position:absolute;left:24px;top:44px;display:flex;gap:16px;align-items:center">${K.icon('chevL', 24, '#000', 2.2)}</div>
        <div style="position:absolute;left:380px;top:36px;width:280px;height:48px;border-radius:24px;background:#fff;box-shadow:0 2px 10px rgba(0,0,0,.12);display:flex;justify-content:space-around;align-items:center;font-size:20px"><b>Aa</b>${K.icon('textbox', 22, '#000')}${K.icon('braces', 22, '#000')}${K.icon('cal', 21, '#000')}</div>
        <div style="position:absolute;right:28px;top:36px;width:48px;height:48px;border-radius:50%;background:${K.C.brand};display:flex;align-items:center;justify-content:center">${K.icon('check', 24, '#fff', 2.6)}</div>`;
      const page = `<div style="position:absolute;left:70px;top:130px;width:470px;font-size:29px;line-height:1.5;color:#000">${body}</div>`;
      const pop = `<div style="position:absolute;left:560px;top:96px;width:330px;transform:scale(1.15);transform-origin:50% 0">${K.formatCard({ active: { bullet: true } }).replace('left:0px;top:640px;width:440px;height:316px', 'left:0px;top:0px;width:440px;height:210px').replace('border-radius:32px 32px 62px 62px', 'border-radius:26px')}</div>`;
      const screen = K.ipad({ content: top + page + pop });
      return `<div style="position:absolute;inset:0;background:${K.C.paper}"></div>` +
        S.text('Write it like a note', { x: 84, y: 92, w: 1032, size: 64, color: ink }) +
        S.place(screen, { x: 84, y: 250, s: 1032 / 1032 * 1.0, w: 1032, h: 1376, radius: '34px', shadow: '0 30px 80px rgba(0,0,0,.16), 0 0 0 1px rgba(0,0,0,.06)', clipBottom: 1376 - 1310 });
    },
    stills: [{ t: 4.2, name: 'ipad-01', note: 'iPad: the page and the Format card, at full width' }],
  };

  // ---------- Mac: ⌘⇧V pastes the formatted cutling into Mail with its bold, list and highlight ----------
  const mac = {
    W: 1920, H: 1080, L,
    draw(t) {
      const body = `<div style="font-weight:700;font-size:19px;margin-bottom:6px">Welcome to the studio!</div><div>Everything for your first visit:</div>
        <ul style="margin:4px 0 6px 0;padding-left:22px"><li>Door code <span style="background:${K.C.highlight};padding:0 2px">4815</span></li><li>Wi-Fi: studio-guest</li><li>Parking behind the bakery</li></ul><div>See you soon!</div>`;
      const desk = K.macDesktop({}) + K.macMenuBar({ app: 'Notes' }) + K.macNotes({ x: 640, y: 110, w: 780, h: 640, to: 'Maya', subject: 'Welcome', body, caret: false });
      return S.place(desk, { x: 0, y: 0, s: 1920 / 1512, w: 1512, h: 982, clipBottom: 982 - 1080 / (1920 / 1512) }) +
        `<div style="position:absolute;left:0;top:0;width:1920px;height:1080px;background:linear-gradient(90deg,rgba(251,251,250,.97) 0%,rgba(251,251,250,.97) 30%,rgba(251,251,250,0) 42%)"></div>` +
        S.text('⌘⇧V pastes it with the formatting', { x: 90, y: 400, w: 540, size: 64, color: ink, lh: 1.1 });
    },
    stills: [{ t: 1, name: 'mac-01', note: 'Mac: the formatted cutling pasted into Mail' }],
  };

  window.FILMS['b-note'] = { iphone, ipad, mac };
})();
