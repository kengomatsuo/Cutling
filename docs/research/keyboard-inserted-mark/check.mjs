// Prints every number in the mock's drawing code, and in the Swift blocks of keyboard-inserted-mark.md,
// that spec.json does not hold. Exits 1 when any is found.
// Allowed without the spec: 0, 1 and 2 (arithmetic), numbers inside a #hex colour, and numbers that are part of a name
// (iOS 26, Color(hex:), v1, UIImpactFeedbackGenerator…). Run: node check.mjs
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const spec = JSON.parse(readFileSync(join(here, "spec.json"), "utf8"));

const known = new Set(["0", "1", "2"]);
(function walk(v) {
  if (typeof v === "number") known.add(String(v));
  else if (typeof v === "string") for (const m of v.matchAll(/\d+(?:\.\d+)?/g)) known.add(String(Number(m[0])));
  else if (v && typeof v === "object") Object.values(v).forEach(walk);
})(spec);

function scan(label, text, firstLine = 1) {
  const misses = [];
  text.split("\n").forEach((line, i) => {
    const code = line.replace(/\/\/.*$/, "").replace(/#[0-9A-Fa-f]{3,8}\b/g, "");
    for (const m of code.matchAll(/(?<![\w.])(\d+(?:\.\d+)?)(?![\w])/g)) {
      const n = String(Number(m[1]));
      if (!known.has(n)) misses.push(`${label}:${firstLine + i}: ${m[1]}  in  ${line.trim()}`);
    }
  });
  return misses;
}

let misses = scan("mock.mjs", readFileSync(join(here, "mock.mjs"), "utf8"));

const doc = readFileSync(join(here, "..", "keyboard-inserted-mark.md"), "utf8");
const lines = doc.split("\n");
let inSwift = false, start = 0, block = [], swiftBlocks = 0;
lines.forEach((line, i) => {
  if (!inSwift && line.trim().startsWith("```swift")) { inSwift = true; start = i + 2; block = []; return; }
  if (inSwift && line.trim() === "```") { inSwift = false; swiftBlocks++; misses = misses.concat(scan("keyboard-inserted-mark.md", block.join("\n"), start)); return; }
  if (inSwift) block.push(line);
});

console.log(`spec numbers: ${known.size}; swift blocks scanned: ${swiftBlocks}`);
if (misses.length) {
  console.log(`${misses.length} number(s) not in spec.json:`);
  misses.forEach((m) => console.log("  " + m));
  process.exit(1);
}
console.log("every number in mock.mjs and the doc's Swift is in spec.json");
