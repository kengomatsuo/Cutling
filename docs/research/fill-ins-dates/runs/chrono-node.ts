// chrono-node 2.10.3: what it reads from each phrase, with "now" = Wed 2026-11-25 09:00 (+07:00).
import * as chrono from "chrono-node";
const ref = { instant: new Date("2026-11-25T09:00:00+07:00"), timezone: 420 };
const fmt = (d: Date) => new Date(d.getTime() + 7 * 3600e3).toISOString().slice(0, 10) + " " + ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][new Date(d.getTime() + 7 * 3600e3).getUTCDay()];
const run = (label: string, parser: any, phrases: string[]) => {
  console.log("== " + label);
  for (const p of phrases) {
    const r = parser.parse(p, ref, { forwardDate: true });
    if (!r.length) { console.log(`  ${p.padEnd(32)} -> (none)`); continue; }
    const x = r[0];
    const known = Object.keys((x.start as any).knownValues).join(",");
    console.log(`  ${p.padEnd(32)} -> "${x.text}" = ${fmt(x.start.date())}  known:[${known}]${x.end ? " to " + fmt(x.end.date()) : ""}`);
  }
};
run("en", chrono.en, ["tomorrow", "the day after tomorrow", "in 3 days", "3 days from now", "two weeks from today", "this Friday", "next Friday", "Friday", "Monday next week", "next week Thursday", "the Friday after next", "next week", "next month", "end of the month", "end of month", "start of next month", "last day of next month", "first Monday of next month", "last Friday of the month", "last working day of the month", "in 2 months", "end of the week", "this weekend", "Christmas", "12/05/2026"]);
run("en.GB", chrono.en.GB, ["12/05/2026"]);
run("de", chrono.de, ["morgen", "übermorgen", "in 3 Tagen", "nächsten Freitag", "Freitag", "Ende des Monats", "am 5. Dezember"]);
run("fr", chrono.fr, ["demain", "dans 3 jours", "vendredi prochain", "fin du mois", "le 5 décembre"]);
run("es", chrono.es, ["mañana", "en 3 días", "el próximo viernes", "fin de mes"]);
run("ja", chrono.ja, ["明日", "3日後", "来週の金曜日", "月末"]);
run("id", (chrono as any).id, ["besok", "lusa", "3 hari lagi", "Jumat depan", "akhir bulan"]);
run("zh", chrono.zh, ["明天", "下周五", "月底"]);
