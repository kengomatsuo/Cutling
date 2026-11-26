// Compares UnlockMotion (Cutling/UnlockCelebrationMotion.swift) with the reference's fixtures.json, frame by frame.
// Run through scripts/check-celebration.sh.
import Foundation

let fixtures = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [String: Any]
let tol = fixtures["tolerance"] as! [String: Double]
let geom = fixtures["geom"] as! [String: Double]
let expectedLayout = fixtures["layout"] as! [String: Any]
let room = UnlockMotion.Room(capacity: 5000, limit: 5, sixth: true, width: geom["W"]!, height: geom["H"]!)

var failures = 0
var checked = 0
func check(_ name: String, _ got: Double, _ want: Double, _ tolerance: Double, _ t: Double) {
    checked += 1
    if abs(got - want) > tolerance { failures += 1; if failures <= 40 { print("FAIL t=\(t) \(name): got \(got), want \(want)") } }
}
func num(_ any: Any?) -> Double { (any as! NSNumber).doubleValue }

check("cols", Double(room.cols), num(expectedLayout["cols"]), 0, -1)
check("rows", Double(room.rows), num(expectedLayout["rows"]), 0, -1)
check("lastRow", Double(room.lastRow), num(expectedLayout["lastRow"]), 0, -1)
check("p1", room.p1, num(expectedLayout["p1"]), 0.0001, -1)
check("last reveal", Double(room.orderMs.last!), num(expectedLayout["lastRevealMs"]), tol["ms"]!, -1)
let firstWant = (expectedLayout["firstRevealMs"] as! [Double])
for (k, want) in firstWant.enumerated() { check("first reveal \(k)", Double(room.orderMs[k]), want, tol["ms"]!, -1) }
for probe in fixtures["probeCells"] as! [[String: Any]] {
    let index = Int(num(probe["j"])) * room.cols + Int(num(probe["i"]))
    check("probe T \(index)", Double(room.revealMs[index]), num(probe["T"]), tol["ms"]!, -1)
}

let ask = UnlockMotion.Frame.ask, before = room.frame(at: -1)
check("ask pitch", ask.pitch, before.pitch, 0.0001, -1)
check("ask tileRatio", ask.tileRatio, before.tileRatio, 0.0001, -1)
check("ask rotation", ask.sixthRotation, before.sixthRotation, 0.0001, -1)
check("ask extras", ask.extras, before.extras, 0.0001, -1)
check("ask exit", ask.exit.reduce(0, +), before.exit.reduce(0, +), 0.0001, -1)
check("ask button", ask.buttonBuyLabel - ask.buttonDoneLabel, before.buttonBuyLabel - before.buttonDoneLabel, 0.0001, -1)
check("ask words", ask.titleDY, before.titleDY, 0.0001, -1)

let exitKeys = ["title", "subtitle", "row1", "row2", "row3", "restore"]
for fx in fixtures["frames"] as! [[String: Any]] {
    let t = num(fx["t"])
    let f = room.frame(at: t)
    check("pitch", f.pitch, num(fx["pitch"]), tol["points"]!, t)
    check("tileRatio", f.tileRatio, num(fx["tileRatio"]), tol["unit"]!, t)
    check("u", f.zoom, num(fx["u"]), tol["unit"]!, t)
    let sixth = fx["sixth"] as! [String: Any]
    check("sixth.x", 5 * f.pitch, num(sixth["x"]), tol["points"]!, t)
    check("sixth.size", f.tileSize, num(sixth["size"]), tol["points"]!, t)
    check("sixth.rotation", f.sixthRotation, num(sixth["rotation"]), tol["degrees"]!, t)
    check("sixth.scale", f.sixthScale, num(sixth["scale"]), tol["unit"]!, t)
    check("sixth.dash", f.sixthDash, num(sixth["dash"]), tol["unit"]!, t)
    check("sixth.lift", f.sixthLift, num(sixth["lift"]), tol["unit"]!, t)
    check("sixth.wash", f.sixthWash, num(sixth["washToTile"]), tol["unit"]!, t)
    check("sixth.dot", f.dot, num(sixth["dot"]), tol["unit"]!, t)
    check("icon", 1 - f.dot, num((fx["first"] as! [String: Any])["iconOpacity"]), tol["unit"]!, t)
    check("ring", room.ring(at: t), num(fx["ring"]), tol["points"]!, t)
    check("count", Double(f.count), num(fx["count"]), tol["count"]!, t)
    let r = fx["room"] as! [String: Any]
    check("room.opacity", f.roomOpacity, num(r["opacity"]), tol["unit"]!, t)
    check("room.scale", f.roomScale, num(r["scale"]), tol["unit"]!, t)
    let title = fx["title"] as! [String: Any], subtitle = fx["subtitle"] as! [String: Any]
    check("title.opacity", f.titleOpacity, num(title["opacity"]), tol["unit"]!, t)
    check("title.dy", f.titleDY, num(title["dy"]), tol["points"]!, t)
    check("subtitle.opacity", f.subtitleOpacity, num(subtitle["opacity"]), tol["unit"]!, t)
    check("subtitle.dy", f.subtitleDY, num(subtitle["dy"]), tol["points"]!, t)
    let exit = fx["exit"] as! [String: Any]
    for (k, key) in exitKeys.enumerated() { check("exit.\(key)", f.exit[k], num(exit[key]), tol["unit"]!, t) }
    check("extras", f.extras, num(fx["extras"]), tol["unit"]!, t)
    let b = fx["button"] as! [String: Any]
    check("button.fill", f.buttonFill, num(b["fill"]), tol["unit"]!, t)
    check("button.out", f.buttonBuyLabel, num(b["out"]), tol["unit"]!, t)
    check("button.in", f.buttonDoneLabel, num(b["in"]), tol["unit"]!, t)
    for cell in fx["cells"] as! [[String: Any]] {
        let index = Int(num(cell["j"])) * room.cols + Int(num(cell["i"]))
        let age = t - Double(room.revealMs[index])
        if let state = cell["state"] as? [String: Any] {
            guard age >= 0 else { failures += 1; print("FAIL t=\(t) slot \(index) expected on screen"); continue }
            let s = UnlockMotion.Slot(age: age)
            check("slot.scale", s.scale, num(state["scale"]), tol["unit"]!, t)
            check("slot.opacity", s.opacity, num(state["opacity"]), tol["unit"]!, t)
            check("slot.tint", s.tint, num(state["tint"]), tol["unit"]!, t)
        } else if age >= 0 { failures += 1; print("FAIL t=\(t) slot \(index) expected hidden") }
    }
}
print("\(checked) values compared, \(failures) outside the fixtures' tolerance")
exit(failures == 0 ? 0 : 1)
