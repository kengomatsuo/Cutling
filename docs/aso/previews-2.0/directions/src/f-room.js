// Direction F, "Room for everything": the numbers 2.0 raised, each proved on the next screen. Black type
// cards with one green word (5,000 texts, 10,000 characters, 500 images), and between them the real
// app in dark mode: the grid's own count reading 5,000 Cutlings, a whole email typed by one key, the photos.
(function () {
  const K = window.K, S = window.S;
  const B = K.BAR, L = 13 * B;
  const T = { gridIn: 1 * B, msgIn: 3 * B, tapPolicy: 3 * B + 0.9, card2: 5 * B, pageIn: 6 * B, card3: 8 * B, imgIn: 9 * B, tapImg: 9 * B + 0.8, paste: 9 * B + 2.0, endCard: 11 * B };
  const names = ['Refund policy', 'Shipping times', 'Size guide', 'Care instructions', 'Opening hours', 'Directions', 'Bank details', 'Invoice reminder', 'Thank you', 'Order update',
    'Back in stock', 'Gift wrap', 'Wholesale terms', 'Press kit', 'Short bio', 'Portfolio link', 'Meeting link', 'Wi-Fi', 'Door code', 'Parking', 'Allergies', 'Booking', 'Cancellation',
    'Deposit', 'Review request', 'Follow-up', 'Intro email', 'Out of office', 'Signature', 'Home address', 'Delivery note', 'Collection times', 'Repair form', 'Warranty', 'Sizing help',
    'Returns label', 'Late delivery', 'Apology', 'Welcome', 'Lost parcel', 'Exchange', 'Custom order', 'Lead times', 'Fabric care', 'Pickup point', 'Holiday hours', 'Price on request',
    'Bulk order', 'Sample request', 'Studio rules', 'Workshop info', 'Waiting list', 'Gift card', 'Feedback', 'Invoice details', 'Tax number', 'Company number', 'Bank transfer', 'Phone', 'Email'];
  const icons = ['return', 'box', 'ruler', 'sparkle', 'clock', 'pin', 'bank', 'doc', 'sparkle', 'box', 'tag', 'ticket', 'doc', 'photo', 'person', 'link', 'cal', 'wifi', 'lock', 'car'];
  const colors = ['#e0559b', K.C.brand, '#16a5b8', '#f0a020', '#7a5af5', '#f08a24', '#30a46c', '#2f7cf6'];
  const previews = ['Send it back within 30 days and we refund…', 'Orders leave the studio within two working days…', 'S 36–38 · M 40–42 · L 44–46', 'Wash cold, dry flat, no tumble dryer.', 'Mon–Sat 10–6, Sun closed', 'Second floor, above the bakery'];
  const grid = names.map((n, i) => ({ name: n, icon: icons[i % icons.length], color: colors[i % colors.length], preview: previews[i % previews.length] }));

  // The app's own grid (MainContentView): the large title, the count under it, cards two across.
  function mainGrid(t) {
    const dark = true, fg = '#fff', sec = K.C.secondaryDk;
    const sp = K.seg(t, T.gridIn + 0.9, T.msgIn - 0.4);
    const scroll = 5200 * K.ease.inOut(sp);   // a long, fast scroll that slows to a stop
    let cards = '';
    const W = 196, H = 140, G = 13;
    for (let i = 0; i < 120; i++) {
      const c = grid[i % grid.length];
      const y = 207 + Math.floor(i / 2) * (H + G) - scroll;
      if (y < -H || y > 960) continue;
      cards += `<div style="position:absolute;left:${17 + (i % 2) * (W + G)}px;top:${y}px;width:${W}px;height:${H}px;border-radius:24px;background:#1c1c1e">
        <div style="position:absolute;left:16px;top:16px">${K.icon(c.icon, 26, c.color, 2)}</div>
        <div style="position:absolute;right:12px;top:12px;width:32px;height:32px;border-radius:50%;background:#2c2c2e;display:flex;align-items:center;justify-content:center">${K.icon('ellipsis', 18, '#ddd')}</div>
        <div style="position:absolute;left:16px;right:12px;top:72px;font-size:17px;font-weight:600;color:${fg};white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${c.name}</div>
        <div style="position:absolute;left:16px;right:12px;top:98px;font-size:14px;color:${sec};white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${c.preview}</div></div>`;
    }
    const titleY = 143 - Math.min(scroll, 60), titleO = 1 - K.seg(scroll, 20, 70);
    const content = `<div style="position:absolute;inset:0;background:#000"></div>${cards}
      <div style="position:absolute;left:0;top:0;width:440px;height:${Math.max(110, 190 - scroll)}px;background:linear-gradient(180deg,#000 80%,rgba(0,0,0,0))"></div>
      <div style="position:absolute;left:21px;top:${titleY - 36}px;font-size:34px;font-weight:700;color:${fg};opacity:${titleO}">Cutlings</div>
      <div style="position:absolute;left:22px;top:${titleY + 6}px;font-size:13px;color:${sec};opacity:${titleO}">5,000 Cutlings</div>
      <div style="position:absolute;left:254px;top:64px;width:165px;height:42px;border-radius:21px;background:rgba(58,58,60,.9);display:flex;justify-content:space-around;align-items:center">${K.icon('plus', 22, fg, 2)}${K.icon('keyboard', 22, fg, 1.7)}${K.icon('ellipsis', 22, fg)}</div>
      <div style="position:absolute;left:29px;top:877px;width:382px;height:48px;border-radius:24px;background:rgba(44,44,46,.95);display:flex;align-items:center;gap:8px;padding-left:16px;font-size:17px;color:${sec}">${K.icon('search', 18, sec, 2)}Search cutlings</div>`;
    return K.iphone({ dark, content });
  }

  const policy = 'Send it back within 30 days and we refund the full amount to the card you paid with. Items need their tags and the original box. We pay for the return label inside the UK and the EU; anywhere else, send it tracked and keep the receipt. Refunds reach your bank in five to ten working days after the parcel arrives here. Made-to-order pieces and gift cards can’t be refunded, but we will always repair or exchange anything that arrives damaged. Sale items can be exchanged for a different size within 14 days. If something is wrong with your order, reply to this message with a photo and your order number and we will sort it out the same day. ';
  function messages(t) {
    const dark = true;
    const landed = t >= T.tapPolicy + 0.12;
    const text = landed ? policy.repeat(3) : '';
    // the field holds the whole policy; it scrolls back up through it to show how much one key typed
    const scrollLines = landed ? 40 * K.ease.inOut(K.seg(t, T.tapPolicy + 0.7, T.card2 - 0.4)) : 0;
    const kb = K.cutlingKeyboard({ dark, cards: grid.slice(0, 6), press: t >= T.tapPolicy && t < T.tapPolicy + 0.12 ? 0 : -1, inserted: landed && t < T.tapPolicy + 0.9 ? 0 : -1 });
    const content = K.messagesNew({ dark, to: 'Leo', text: K.esc(text), size: 17, maxLines: 17, scrollLines });
    return K.iphone({ dark, content, keyboard: kb, over: K.touch(112, 687, t, T.tapPolicy, 0.1, true) });
  }

  // the same policy as its own page, long enough to scroll (Text page, dark)
  function page(t) {
    const sc = 1400 * K.ease.inOut(K.seg(t, T.pageIn + 0.3, T.card3 - 0.3));
    const body = `<div style="transform:translateY(${-sc}px)"><div style="font-weight:700;font-size:24px;margin-bottom:8px">Refunds and returns</div>` +
      [0, 1, 2, 3, 4, 5].map((i) => `<div style="font-weight:600;margin:10px 0 4px">${['Within 30 days', 'Return labels', 'When the money arrives', 'What can’t be refunded', 'Damaged items', 'Sale items'][i]}</div><div>${policy}</div>`).join('') + '</div>';
    return K.iphone({ dark: true, content: K.textPage({ dark: true, body, bar: null, keyboard: 'none' }) });
  }

  // images: the keyboard's image keys, one copied and pasted into the message
  function images(t) {
    const dark = true;
    const tiles = [['Size chart', '#2b5876,#4e4376'], ['Shop front', '#c06c84,#6c5b7b'], ['Gift wrap', '#f8b195,#c06c84'], ['Fabric swatch', '#355c7d,#6c5b7b'], ['Map', '#11998e,#38ef7d'], ['QR for Wi-Fi', '#232526,#414345']];
    const copied = t >= T.tapImg + 0.1 && t < T.tapImg + 1.2;
    let kb = K.cutlingKeyboard({ dark, cards: [] });
    kb += tiles.map(([n, g], i) => `<div style="position:absolute;left:${6 + (i % 2) * 217}px;top:${655 + Math.floor(i / 2) * 70}px;width:211px;height:64px;border-radius:10px;overflow:hidden;background:linear-gradient(135deg,${g});${t >= T.tapImg && t < T.tapImg + 0.12 && i === 0 ? 'filter:brightness(1.3);' : ''}">
      <div style="position:absolute;left:10px;bottom:7px;font-size:13px;font-weight:600;color:#fff;text-shadow:0 1px 3px rgba(0,0,0,.5)">${n}</div>
      ${copied && i === 0 ? `<div style="position:absolute;inset:0;background:rgba(20,70,58,.9);display:flex;align-items:center;justify-content:center;gap:6px;color:${K.C.pillTextDk};font-weight:600">${K.icon('check', 17, K.C.pillTextDk, 2.4)}Copied</div>` : ''}</div>`).join('');
    const pasted = t >= T.paste;
    let content = K.messagesNew({ dark, to: 'Leo', text: pasted ? ' ' : '' });
    if (pasted) content += `<div style="position:absolute;left:72px;top:330px;width:200px;height:200px;border-radius:14px;background:linear-gradient(135deg,#2b5876,#4e4376);box-shadow:0 2px 10px rgba(0,0,0,.4)"><div style="position:absolute;left:12px;bottom:10px;color:#fff;font-weight:600;font-size:15px">Size chart</div></div>`;
    return K.iphone({ dark, content, keyboard: kb, over: K.touch(112, 687, t, T.tapImg, 0.1, true) + K.touch(160, 552, t, T.paste - 0.15, 0.1, true) });
  }

  function typeCard(num, line, op) {
    return `<div style="position:absolute;inset:0;background:#050505;opacity:${op}">` +
      S.text(num, { x: 64, y: 560, w: 800, size: num.length > 5 ? 238 : 300, weight: 800, color: '#fff', ls: '-0.045em', lh: 1 }) +
      S.text(line, { x: 72, y: 900, w: 760, size: 66, weight: 700, color: '#8e8e93', lh: 1.1 }) + `</div>`;
  }
  const g = (w) => `<span style="color:${K.C.accentDk}">${w}</span>`;
  const iphone = {
    W: 886, H: 1920, L, loopDissolve: 0.6,
    draw(t) {
      const s = 886 / 440;
      let h = `<div style="position:absolute;inset:0;background:#050505"></div>`;
      const seg = (a, b) => K.seg(t, a - 0.2, a + 0.2) * (1 - K.seg(t, b - 0.2, b + 0.2));
      const place = (html, op) => (op > 0.001 ? S.place(html, { x: 0, y: -2.5, s, opacity: op }) : '');
      h += place(mainGrid(t), seg(T.gridIn, T.msgIn));
      h += place(messages(t), seg(T.msgIn, T.card2));
      h += place(page(t), seg(T.pageIn, T.card3));
      h += place(images(t), seg(T.imgIn, T.endCard));
      const c1 = 1 - K.seg(t, T.gridIn - 0.2, T.gridIn + 0.2);
      if (c1 > 0.001) h += typeCard('5,000', `${g('texts')} in one keyboard`, c1);
      const c2 = seg(T.card2, T.pageIn);
      if (c2 > 0.001) h += typeCard('10,000', `${g('characters')} in each one`, c2);
      const c3 = seg(T.card3, T.imgIn);
      if (c3 > 0.001) h += typeCard('500', `${g('images')} too`, c3);
      const e = K.seg(t, T.endCard - 0.2, T.endCard + 0.2);
      if (e > 0.001) h += `<div style="position:absolute;inset:0;background:#050505;opacity:${e}">` + S.text(`Keep every<br>reply you ${g('send')}.`, { x: 72, y: 640, w: 760, size: 112, lh: 1.04 }) + S.brand({ x: 72, y: 960, icon: 110, size: 56 }) + `</div>`;
      // the cut back to 5,000 at the seam: the end card fades out over the film's last 0.25 s
      return h;
    },
    stills: [
      { t: 0, name: 'iphone-01', note: 'Frame 0: 5,000 texts in one keyboard' },
      { t: 2.9, name: 'iphone-02', note: 'The grid’s own count: 5,000 Cutlings, then a long scroll' },
      { t: 9.6, name: 'iphone-03', note: 'One key types a whole refund policy' },
      { t: 12.4, name: 'iphone-04', note: '10,000 characters in each one' },
      { t: 16.4, name: 'iphone-05', note: 'The policy as a page, long enough to scroll' },
      { t: 22.9, name: 'iphone-06', note: '500 images: a photo copied from the keyboard and pasted' },
      { t: 27.0, name: 'iphone-07', note: 'End: Keep every reply you send' },
    ],
    poster: 0,
    seam: { kind: 'dissolve', signals: { 'end card (opacity)': (t) => K.seg(t, T.endCard - 0.2, T.endCard + 0.2), 'first card (opacity)': (t) => 1 - K.seg(t, T.gridIn - 0.2, T.gridIn + 0.2) } },
  };

  // iPad: the keyboard is five cards across, so the wall of texts is the picture
  const ipad = {
    W: 1200, H: 1600, L,
    draw() {
      const cards = grid.slice(0, 15);
      const scr = K.ipad({ dark: true, content: K.ipadMessages({ dark: true, to: 'Leo', text: '' }), keyboard: K.ipadCutlingKeyboard({ dark: true, cards }) });
      return `<div style="position:absolute;inset:0;background:#050505"></div>` +
        S.text('5,000', { x: 84, y: 70, w: 1000, size: 230, weight: 800, color: '#fff', ls: '-0.045em', lh: 1 }) +
        S.text(`${g('texts')} in one keyboard`, { x: 90, y: 320, w: 1000, size: 56, color: '#8e8e93' }) +
        S.place(scr, { x: 0, y: 470, s: 1200 / 1032, w: 1032, h: 1376, clipTop: 1376 - 1130 / (1200 / 1032), radius: '36px 36px 0 0' });
    },
    stills: [{ t: 0, name: 'ipad-01', note: 'iPad: fifteen texts across the keyboard, 5,000 in all' }],
  };

  // Mac: the picker's own count, and three letters finding one in 5,000
  const mac = {
    W: 1920, H: 1080, L,
    draw() {
      const rows = [
        { name: 'Refund policy', icon: 'return', color: '#e0559b', preview: 'Send it back within 30 days and we refund…' },
        { name: 'Damaged items', icon: 'box', color: K.C.brand, preview: 'A full refund or a repair, your choice…' },
        { name: 'Sale items', icon: 'tag', color: '#f08a24', preview: 'No refunds on sale items, but exchanges…' },
      ];
      const desk = K.macDesktop({ dark: true }) + K.macMenuBar({ dark: true, app: 'Notes', cutlingActive: true }) +
        K.macNotes({ dark: true, x: 560, y: 120, w: 780, h: 600, to: 'Leo', subject: 'Your return', body: '' }) +
        K.macPicker({ dark: true, x: 700, y: 250, rows, hover: 0, query: 'ref', count: 5000 });
      return S.place(desk, { x: 0, y: 0, s: 1920 / 1512, w: 1512, h: 982, clipBottom: 982 - 1080 / (1920 / 1512) }) +
        `<div style="position:absolute;left:0;top:0;width:760px;height:1080px;background:linear-gradient(90deg,rgba(5,5,5,.97) 70%,rgba(5,5,5,0))"></div>` +
        S.text('5,000', { x: 80, y: 330, w: 640, size: 200, weight: 800, color: '#fff', ls: '-0.045em', lh: 1 }) +
        S.text(`${g('texts')}, and three letters find one`, { x: 86, y: 560, w: 560, size: 48, color: '#8e8e93', lh: 1.15 });
    },
    stills: [{ t: 0, name: 'mac-01', note: 'Mac: Saved 5,000, and “ref” finds the refund policy' }],
  };

  window.FILMS['f-room'] = { iphone, ipad, mac };
})();
