// What sits outside the device in every direction: placing a screen, type, captions, the end card,
// and the seed cutlings the takes are recorded with (docs/aso/previews-2.0/directions.md, "Seed").
(function () {
  window.FILMS = {};
  const S = {};
  const K = window.K;

  // Shows a device screen's region from `clipTop` to its height less `clipBottom` (points), at (x, y), scaled by s.
  S.place = (html, { x, y, s, w = 440, h = 956, clipTop = 0, clipBottom = 0, radius = 0, shadow = '', opacity = 1, extra = '' }) => {
    const vh = h - clipTop - clipBottom;
    return `<div style="position:absolute;left:${x}px;top:${y}px;width:${w * s}px;height:${vh * s}px;overflow:hidden;border-radius:${radius};${shadow ? `box-shadow:${shadow};` : ''}opacity:${opacity};${extra}">
      <div style="position:absolute;left:0;top:${-clipTop * s}px;width:${w}px;height:${h}px;transform:scale(${s});transform-origin:0 0">${html}</div></div>`;
  };

  // Text blocks in frame pixels.
  S.text = (html, { x, y, w, size, weight = 700, color = '#fff', lh = 1.08, ls = '-0.02em', align = 'left', opacity = 1, extra = '' }) =>
    `<div style="position:absolute;left:${x}px;top:${y}px;width:${w}px;font:${weight} ${size}px/${lh} -apple-system,system-ui;letter-spacing:${ls};color:${color};text-align:${align};opacity:${opacity};${extra}">${html}</div>`;

  // A crossfade between named states: returns each state's opacity at t given the times it starts.
  S.fades = (t, marks, dur = 0.3) => {
    // marks: [[t0, 'a'], [t1, 'b'], ...] sorted; returns {a: op, b: op}
    const out = {};
    marks.forEach(([t0, k], i) => {
      const next = marks[i + 1];
      const fin = K.ease.inOut(K.seg(t, t0 - dur / 2, t0 + dur / 2));
      const fout = next ? K.ease.inOut(K.seg(t, next[0] - dur / 2, next[0] + dur / 2)) : 0;
      const v = i === 0 ? 1 - fout : fin * (1 - fout);
      out[k] = Math.max(out[k] || 0, v);
    });
    return out;
  };

  // The app icon (Icon Composer render) and the name, for an end card.
  S.brand = ({ x, y, icon = 120, size = 54, color = '#fff', gap = 26, opacity = 1 }) =>
    `<div style="position:absolute;left:${x}px;top:${y}px;display:flex;align-items:center;gap:${gap}px;opacity:${opacity}">
      <img src="assets/icon.png" style="width:${icon}px;height:${icon}px;display:block;filter:drop-shadow(0 10px 24px rgba(0,0,0,.25))">
      <div style="font:700 ${size}px/1 -apple-system,system-ui;letter-spacing:-0.02em;color:${color}">Cutling</div></div>`;

  // Seed cutlings (English). The take list names them; id and ja seeds are written from the same meanings.
  const pill = (s) => K.pill(s, false);
  const pillD = (s) => K.pill(s, true);
  S.seed = {
    shop: (dark) => {
      const p = dark ? pillD : pill;
      return [
        { name: 'Order update', icon: 'box', color: K.C.brand, preview: `Hi ${p('Name')}, your order ships ${p('Friday')}.` },
        { name: 'Home address', icon: 'house', color: '#2f7cf6', preview: '14 Linden Road, Flat 3' },
        { name: 'Bank details', icon: 'bank', color: '#30a46c', preview: 'Account 0441 2290 18' },
        { name: 'Booking', icon: 'cal', color: '#f08a24', preview: `Your table for ${p('Guests ▾')} is booked` },
        { name: 'Wi-Fi', icon: 'wifi', color: '#16a5b8', preview: 'studio-guest · fern2291' },
        { name: 'Thank you', icon: 'sparkle', color: '#e0559b', preview: 'Thank you so much for your order!' },
      ];
    },
    names: ['Maya', 'Jonas', 'Aiko', 'Sam', 'Lea'],
  };

  window.S = S;
})();
