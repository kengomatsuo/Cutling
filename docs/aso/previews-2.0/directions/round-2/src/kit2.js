// Round two's extra screens, on top of round one's kit (../../src/kit.js): the apps an overview visits (Maps,
// Calendar, Safari, Photos and the iOS share sheet), Cutling's grid, Cutling's own share sheet and the text page's
// Ask Each Time sheet. All in points on the 440 x 956 pt iPhone screen, drawn as stand-ins.
(function () {
  const K = window.K;
  const abs = K.abs;
  const sec = (d) => (d ? K.C.secondaryDk : K.C.secondary);

  // Cutling's grid (MainContentView): large title, the count under it, cards two across with a ⋯ button.
  K.mainGrid = ({ dark = false, count = '8 Cutlings', cards = [], scroll = 0, press = -1, highlight = -1 } = {}) => {
    const fg = dark ? '#fff' : '#000';
    const cardBg = dark ? '#1c1c1e' : '#fff';
    const W = 196, H = 140, G = 13;
    let html = `<div style="${abs(0, 0, 440, 956)};background:${dark ? '#000' : '#f2f2f7'}"></div>`;
    cards.forEach((c, i) => {
      const y = 207 + Math.floor(i / 2) * (H + G) - scroll;
      if (y < -H || y > 960) return;
      const hl = i === highlight ? `box-shadow:0 0 0 3px ${K.C.brand};` : '';
      html += `<div style="${abs(17 + (i % 2) * (W + G), y, W, H)};border-radius:24px;background:${cardBg};${hl}${i === press ? 'filter:brightness(.9);' : ''}">
        <div style="position:absolute;left:16px;top:16px">${c.image ? `<div style="width:36px;height:36px;border-radius:8px;background:linear-gradient(135deg,${c.image})"></div>` : K.icon(c.icon, 26, c.color, 2)}</div>
        <div style="position:absolute;right:12px;top:12px;width:32px;height:32px;border-radius:50%;background:${dark ? '#2c2c2e' : '#f0f0f3'};display:flex;align-items:center;justify-content:center">${K.icon('ellipsis', 18, dark ? '#ddd' : '#333')}</div>
        <div style="position:absolute;left:16px;right:12px;top:72px;font-size:17px;font-weight:600;color:${fg};white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${K.esc(c.name)}</div>
        <div style="position:absolute;left:16px;right:12px;top:98px;font-size:14px;color:${sec(dark)};white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${c.preview || ''}</div></div>`;
    });
    const titleO = 1 - K.seg(scroll, 20, 70);
    html += `<div style="${abs(0, 0, 440, Math.max(110, 190 - scroll))};background:linear-gradient(180deg,${dark ? '#000' : '#f2f2f7'} 80%,rgba(242,242,247,0))"></div>
      <div style="${abs(21, 107 - Math.min(scroll, 60), 300, 40)};font-size:34px;font-weight:700;color:${fg};opacity:${titleO}">Cutlings</div>
      <div style="${abs(22, 149 - Math.min(scroll, 60), 300, 16)};font-size:13px;color:${sec(dark)};opacity:${titleO}">${count}</div>
      <div style="${abs(254, 64, 165, 42)};border-radius:21px;background:${dark ? 'rgba(58,58,60,.9)' : 'rgba(255,255,255,.95)'};box-shadow:0 1px 6px rgba(0,0,0,.08);display:flex;justify-content:space-around;align-items:center">${K.icon('plus', 22, fg, 2)}${K.icon('keyboard', 22, fg, 1.7)}${K.icon('ellipsis', 22, fg)}</div>
      <div style="${abs(29, 877, 382, 48)};border-radius:24px;background:${dark ? 'rgba(44,44,46,.95)' : 'rgba(255,255,255,.95)'};box-shadow:0 1px 6px rgba(0,0,0,.08);display:flex;align-items:center;gap:8px;padding-left:16px;font-size:17px;color:${sec(dark)}">${K.icon('search', 18, sec(dark), 2)}Search cutlings</div>`;
    return html;
  };

  // Maps: the map, the search sheet risen with the keyboard, the typed query and the matching result.
  K.maps = ({ query = '', result = '' } = {}) => {
    const roads = [[0, 120, 440, 10, 8], [0, 230, 440, 14, -6], [90, 0, 12, 400, 0], [260, 0, 9, 400, 0], [0, 330, 440, 8, 4]];
    let map = `<div style="${abs(0, 0, 440, 420)};background:#efe9dc;overflow:hidden">
      <div style="${abs(-20, 250, 200, 140)};background:#cfe6c4;border-radius:40px"></div><div style="${abs(300, 40, 180, 120)};background:#cfe6c4;border-radius:30px"></div>
      <div style="${abs(190, 300, 300, 120)};background:#bcdcf0"></div>
      ${roads.map(([x, y, w, h, r]) => `<div style="${abs(x, y, w, h)};background:#fff;transform:rotate(${r}deg);box-shadow:0 0 0 1px #e2dccd"></div>`).join('')}
      ${result ? `<div style="${abs(196, 150, 34, 44)}">${K.icon('pin', 34, '#ea4335', 2.2)}</div>` : ''}</div>`;
    return map + `<div style="${abs(0, 360, 440, 600)};border-radius:28px 28px 0 0;background:#fff;box-shadow:0 -4px 20px rgba(0,0,0,.12)">
      <div style="${abs(200, 8, 40, 5)};border-radius:3px;background:#d4d4d8"></div>
      <div style="${abs(16, 26, 408, 44)};border-radius:22px;background:#eeeef0;display:flex;align-items:center;gap:8px;padding-left:14px;font-size:17px;color:${query ? '#000' : '#8a8a8e'}">${K.icon('search', 18, '#8a8a8e', 2)}<span>${query ? K.esc(query) : 'Search Maps'}</span>${query ? `<span style="display:inline-block;width:2px;height:20px;background:${K.C.blue}"></span>` : ''}</div>
      ${result ? `<div style="${abs(16, 86, 408, 56)};display:flex;align-items:center;gap:12px">${`<div style="width:36px;height:36px;border-radius:50%;background:#ea4335;display:flex;align-items:center;justify-content:center">${K.icon('pin', 20, '#fff', 2.2)}</div>`}<div><div style="font-size:17px;font-weight:600">${K.esc(result)}</div><div style="font-size:14px;color:#8a8a8e">Address</div></div></div>` : ''}
    </div>`;
  };

  // Calendar: a new event, its title and location rows above the keyboard (the date rows sit under the keyboard).
  K.calendarEvent = ({ title = 'Pottery class', location = '', focus = 'location' } = {}) => `
    <div style="${abs(0, 54, 440, 900)};background:#f2f2f7">
      <div style="${abs(18, 8, 44, 44)};border-radius:50%;background:#fff;box-shadow:0 1px 4px rgba(0,0,0,.1);display:flex;align-items:center;justify-content:center">${K.icon('xmark', 18, '#000', 2.2)}</div>
      <div style="${abs(0, 20, 440, 22)};text-align:center;font-weight:600;font-size:17px">New Event</div>
      <div style="${abs(376, 8, 44, 44)};border-radius:50%;background:#e8473f;display:flex;align-items:center;justify-content:center">${K.icon('check', 20, '#fff', 2.6)}</div>
      <div style="${abs(20, 76, 400, 104)};border-radius:24px;background:#fff">
        <div style="${abs(18, 0, 364, 52)};display:flex;align-items:center;font-size:17px">${K.esc(title)}</div>
        <div style="${abs(18, 52, 382, .5)};background:${K.C.sep}"></div>
        <div style="${abs(18, 52, 364, 52)};display:flex;align-items:center;font-size:17px;color:${location ? '#000' : '#8a8a8e'}">${location ? K.esc(location) : 'Location or Video Call'}${focus === 'location' ? `<span style="display:inline-block;width:2px;height:20px;background:#e8473f;margin-left:1px"></span>` : ''}</div>
      </div>
      <div style="${abs(20, 196, 400, 52)};border-radius:24px;background:#fff;display:flex;align-items:center;justify-content:space-between;padding:0 18px;box-sizing:border-box;font-size:17px">All-day<div style="width:51px;height:31px;border-radius:16px;background:#e9e9eb;position:relative"><div style="position:absolute;top:2px;left:2px;width:27px;height:27px;border-radius:50%;background:#fff;box-shadow:0 2px 4px rgba(0,0,0,.2)"></div></div></div>
    </div>`;

  // Safari: a page with a line selected and the edit menu over it.
  // the edit menu's four items sit 75 pt apart from x 70, so Share… is centred at x 332, y 290 on screen
  K.safariPage = ({ body = '', menu = false, menuPress = -1, addr = 'Your order' } = {}) => `
    <div style="${abs(0, 54, 440, 902)};background:#fff">
      <div style="${abs(24, 30, 392, 600)};font-size:17px;line-height:1.5;color:#1d1d1f">${body}</div>
      ${menu ? `<div style="${abs(70, 214, 300, 44)};border-radius:22px;background:rgba(30,30,32,.92);color:#fff;display:flex;align-items:center;font-size:15px">${['Copy', 'Look Up', 'Translate', 'Share…'].map((m, i) => `<span style="width:75px;text-align:center;${i === menuPress ? 'opacity:.55' : ''}">${m}</span>`).join('')}</div>` : ''}
      <div style="${abs(12, 820, 416, 52)};border-radius:26px;background:rgba(245,245,247,.96);box-shadow:0 2px 12px rgba(0,0,0,.12);display:flex;align-items:center;justify-content:center;font-size:15px;color:#3c3c43">${K.icon('lock', 14, '#3c3c43', 2)}<span style="margin-left:6px">${K.esc(addr)}</span></div>
    </div>`;

  // Photos: one photo full screen; the share sheet with Cutling in its row of apps.
  K.photo = (grad) => `<div style="${abs(0, 0, 440, 956)};background:#000"><div style="${abs(0, 230, 440, 440)};background:linear-gradient(135deg,${grad})"></div></div>`;
  K.shareSheet = ({ press = false, p = 1, head = '1 Photo Selected', sub = 'Options ›', thumb = 'linear-gradient(135deg,#2b5876,#4e4376)' } = {}) => {
    const apps = [['Messages', '#34c759', 'envelope'], ['Mail', '#0a84ff', 'envelope'], ['Notes', '#ffd60a', 'doc'], ['Cutling', null, null], ['Reminders', '#ff9f0a', 'doc']];
    return `<div style="${abs(0, 956 - 470 * p, 440, 470)};border-radius:34px 34px 0 0;background:#f2f2f7;color:#000;box-shadow:0 -8px 30px rgba(0,0,0,.25)">
      <div style="${abs(200, 8, 40, 5)};border-radius:3px;background:#c7c7cc"></div>
      <div style="${abs(20, 30, 400, 60)};display:flex;align-items:center;gap:12px"><div style="flex:none;width:52px;height:52px;border-radius:10px;background:${thumb}"></div><div style="min-width:0"><div style="font-size:16px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">${K.esc(head)}</div><div style="font-size:14px;color:#8a8a8e">${K.esc(sub)}</div></div></div>
      <div style="${abs(12, 120, 416, 100)};display:flex;justify-content:space-around">${apps.map(([n, c, ic]) => `<div style="width:70px;text-align:center;font-size:12px">${c ? `<div style="width:60px;height:60px;margin:0 auto;border-radius:14px;background:${c};display:flex;align-items:center;justify-content:center">${K.icon(ic, 28, '#fff', 2)}</div>` : `<img src="assets/icon.png" style="width:60px;height:60px;border-radius:14px;display:block;margin:0 auto;${press ? 'filter:brightness(.8);' : ''}">`}<div style="margin-top:6px">${n}</div></div>`).join('')}</div>
      <div style="${abs(20, 240, 400, 150)};border-radius:20px;background:#fff">${['Copy', 'Add to Shared Album', 'Save to Files'].map((r, i) => `<div style="${abs(18, i * 50, 364, 50)};display:flex;align-items:center;font-size:17px;${i ? 'border-top:.5px solid rgba(60,60,67,.18)' : ''}">${r}</div>`).join('')}</div></div>`;
  };

  // Cutling's own share sheet (CutlingShare/ShareView.swift): Cancel, the title Cutling, Done; the cutling's
  // icon and name, what it holds, then Change Icon and Color. Done is centred at x 379, y 102.
  K.cutlingShare = ({ name = '', text = '', image = null, icon = 'pin', color = '#f08a24', p = 1, donePress = false } = {}) => {
    const y = 60 + (1 - p) * 900;
    const body = image ? `<div style="${abs(20, 168, 400, 240)};border-radius:20px;background:${image}"></div>`
      : `<div style="${abs(36, 168, 300, 20)};font-size:15px;font-weight:600;color:#8a8a8e">Text</div>
         <div style="${abs(20, 194, 400, 120)};border-radius:20px;background:#fff;padding:14px 16px;box-sizing:border-box;font-size:17px;line-height:1.35">${K.esc(text)}</div>`;
    const rowsY = image ? 426 : 332;
    return `<div style="${abs(0, y, 440, 900)};border-radius:34px 34px 0 0;background:#f2f2f7;color:#000;box-shadow:0 -8px 30px rgba(0,0,0,.22)">
      <div style="${abs(200, 8, 40, 5)};border-radius:3px;background:#c7c7cc"></div>
      <div style="${abs(16, 22, 96, 40)};border-radius:20px;background:#fff;box-shadow:0 1px 4px rgba(0,0,0,.08);display:flex;align-items:center;justify-content:center;font-size:17px">Cancel</div>
      <div style="${abs(0, 31, 440, 22)};text-align:center;font-size:17px;font-weight:600">Cutling</div>
      <div style="${abs(334, 22, 90, 40)};border-radius:20px;background:${K.C.brand};${donePress ? 'filter:brightness(.85);' : ''}display:flex;align-items:center;justify-content:center;font-size:17px;font-weight:600;color:#fff">Done</div>
      <div style="${abs(20, 86, 400, 64)};border-radius:20px;background:#fff;display:flex;align-items:center;gap:14px;padding:0 16px;box-sizing:border-box">
        <div style="width:40px;height:40px;border-radius:10px;background:${color}22;display:flex;align-items:center;justify-content:center">${K.icon(icon, 22, color, 2)}</div>
        <div style="font-size:17px">${K.esc(name)}</div></div>
      ${body}
      <div style="${abs(20, rowsY, 400, 104)};border-radius:20px;background:#fff">
        <div style="${abs(16, 0, 368, 52)};display:flex;align-items:center;font-size:17px;color:${K.C.brand}">Change Icon</div>
        <div style="${abs(16, 52, 384, .5)};background:${K.C.sep}"></div>
        <div style="${abs(16, 52, 368, 52)};display:flex;align-items:center;font-size:17px">Color</div></div>
    </div>`;
  };

  // The sheet the text page's Ask Each Time button opens (FillInSheets.swift, medium height): ✕, Ask Each Time, ✓;
  // the blank's name, already Name; Choices. ✓ is centred at x 400, y 520.
  K.blankSheet = ({ p = 1, okPress = false } = {}) => {
    const y = 478 + (1 - p) * 500;
    return `<div style="${abs(0, y, 440, 480)};border-radius:34px 34px 0 0;background:#f2f2f7;box-shadow:0 -8px 30px rgba(0,0,0,.18)">
      <div style="${abs(200, 8, 40, 5)};border-radius:3px;background:#c7c7cc"></div>
      <div style="${abs(18, 20, 44, 44)};border-radius:50%;background:#fff;box-shadow:0 1px 4px rgba(0,0,0,.08);display:flex;align-items:center;justify-content:center">${K.icon('xmark', 18, '#000', 2.2)}</div>
      <div style="${abs(0, 32, 440, 22)};text-align:center;font-size:17px;font-weight:600">Ask Each Time</div>
      <div style="${abs(378, 20, 44, 44)};border-radius:50%;background:${K.C.brand};${okPress ? 'filter:brightness(.85);' : ''}display:flex;align-items:center;justify-content:center">${K.icon('check', 20, '#fff', 2.6)}</div>
      <div style="${abs(40, 86, 300, 20)};font-size:15px;font-weight:600;color:#8a8a8e">Name</div>
      <div style="${abs(20, 112, 400, 52)};border-radius:20px;background:#fff;display:flex;align-items:center;padding-left:16px;font-size:17px">Name</div>
      <div style="${abs(40, 186, 300, 20)};font-size:15px;font-weight:600;color:#8a8a8e">Choices</div>
      <div style="${abs(20, 212, 400, 52)};border-radius:20px;background:#fff;display:flex;align-items:center;gap:10px;padding-left:16px;font-size:17px;color:${K.C.brand}"><div style="width:22px;height:22px;border-radius:50%;background:${K.C.brand};display:flex;align-items:center;justify-content:center">${K.icon('plus', 14, '#fff', 2.8)}</div>Add Choice</div>
      <div style="${abs(40, 274, 360, 20)};font-size:13px;color:#8a8a8e">The ticked choice is filled in first.</div>
    </div>`;
  };

  // The text page's keyboard bar as TextPageView.swift orders it, first eight: Aa, Ask Each Time, Today's Date,
  // Variables, Clipboard Text, B, I, U. Ask Each Time is centred at x 92.5, y 533.
  K.pageBar = [['aa', 'Aa'], ['ask', 'textbox'], ['today', 'cal'], ['vars', 'braces'], ['clip', 'clip'], ['b', 'B'], ['i', 'I'], ['u', 'U']];

  window.K = K;
})();

// The everyday keyboard the overviews share: one person's things, a shop's reply, a photo.
(function () {
  const K = window.K;
  K.everyday = (dark = false) => {
    const p = (s) => K.pill(s, dark);
    return [
      { name: 'Home address', icon: 'house', color: '#2f7cf6', preview: '14 Linden Road, Flat 3' },
      { name: 'Order update', icon: 'box', color: K.C.brand, preview: `Hi ${p('Name')}, your order ships ${p('Friday')}.` },
      { name: 'Bank details', icon: 'bank', color: '#30a46c', preview: 'Account 0441 2290 18' },
      { name: 'Studio address', icon: 'pin', color: '#f08a24', preview: '22 Mill Lane, Studio 4' },
      { name: 'Wi-Fi', icon: 'wifi', color: '#16a5b8', preview: 'studio-guest · fern2291' },
      { name: 'Thank you', icon: 'sparkle', color: '#e0559b', preview: 'Thank you so much for your order!' },
    ];
  };
  // where a card's centre sits on the iPhone keyboard (two across, 64 pt cards, 6 pt apart, grid at 655 pt)
  K.cardXY = (i) => ({ x: 6 + (i % 2) * 217 + 105.5, y: 655 + Math.floor(i / 2) * 70 + 32 });
  // where a value key's centre sits on the fill-in screen (three across, under Type with Your Keyboard)
  K.valueXY = (i) => ({ x: 6 + (i % 3) * 148.67 + 71.3, y: 587 + 62 + 52 + 6 + Math.floor(i / 3) * 50 + 22 });
  // holding the globe and sliding to Cutling: the touch moves from the globe to the list's Cutling row
  K.globeTouch = (t, down, up, slideAt, dark = false) => {
    const p = K.ease.inOut(K.seg(t, slideAt, slideAt + 0.25));
    return K.touch(K.lerp(44, 80, p), K.lerp(915, 806, p), t, down, up - down, dark);
  };
  K.orderFill = (press = -1, dark = false) => K.cutlingKeyboard({ dark, mode: 'fill', fill: { sentence: K.fillSentence(['Hi ', { label: 'Name', active: true }, ', your order ships Friday.'], dark), values: ['Maya', 'Jonas', 'Aiko', 'Sam', 'Lea', '__paste'], press, last: true } });
})();
