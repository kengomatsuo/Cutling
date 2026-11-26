import Foundation

var failures = 0
func check(_ ok: Bool, _ what: String, line: Int = #line) {
    if !ok { failures += 1; print("FAIL line \(line): \(what)") }
}

// The count leaves out the starter.
check(FreeLimit.counted(total: 5, starterPresent: true) == 4, "Try Me does not count")
check(FreeLimit.counted(total: 5, starterPresent: false) == 5, "no starter, all count")
check(FreeLimit.counted(total: 0, starterPresent: true) == 0, "never negative")

// Five counted cutlings block the sixth; four do not.
check(FreeLimit.blocks(counted: 5, limit: 5, unlocked: false), "5 of 5 blocks")
check(!FreeLimit.blocks(counted: 4, limit: 5, unlocked: false), "4 of 5 allows")
check(!FreeLimit.blocks(counted: 5000, limit: 5, unlocked: true), "unlocked never blocks")
// Several items that would pass the limit wait together, none partly.
check(FreeLimit.blocks(counted: 4, adding: 2, limit: 5, unlocked: false), "4 plus 2 blocks")
check(!FreeLimit.blocks(counted: 3, adding: 2, limit: 5, unlocked: false), "3 plus 2 fits")
// Try Me plus four own cutlings leaves room for one.
check(!FreeLimit.blocks(counted: FreeLimit.counted(total: 5, starterPresent: true), limit: 5, unlocked: false), "Try Me + 4 allows")

// The keyboard's toast.
check(FreeLimit.saveNote(countedAfterSave: 3, limit: 5, unlocked: false) == .plain, "3rd is plain")
check(FreeLimit.saveNote(countedAfterSave: 4, limit: 5, unlocked: false) == .oneLeft, "4th says one left")
check(FreeLimit.saveNote(countedAfterSave: 5, limit: 5, unlocked: false) == .last, "5th says last")
check(FreeLimit.saveNote(countedAfterSave: 4, limit: 5, unlocked: true) == .plain, "unlocked is plain")
check(FreeLimit.saveNote(countedAfterSave: 5, limit: 5, unlocked: true) == .plain, "unlocked 5th is plain")

// A waiting item lives 24 hours.
let t = Date(timeIntervalSince1970: 1_000_000)
check(!FreeLimit.isStale(createdAt: t, now: t.addingTimeInterval(24 * 3600)), "exactly 24 h is kept")
check(FreeLimit.isStale(createdAt: t, now: t.addingTimeInterval(24 * 3600 + 1)), "past 24 h is dropped")

if failures == 0 { print("FreeLimit: all passed") } else { print("FreeLimit: \(failures) failed"); exit(1) }
