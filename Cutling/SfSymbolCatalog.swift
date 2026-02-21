//
//  SFSymbolCatalog.swift
//  Cutling
//
//  Created by Kenneth Johannes Fang on 18/02/26.
//

import Foundation

struct SFSymbolEntry: Identifiable {
    let id: String // the SF Symbol name
    let keywords: [String]

    var name: String { id }
}

struct SFSymbolCatalog {
    static let all: [SFSymbolEntry] = communication + people + devices + connectivity
        + media + commerce + health + nature + travel + objects + shapes + text + arrows + indices

    static func search(_ query: String) -> [SFSymbolEntry] {
        guard !query.isEmpty else { return all }
        let q = query.lowercased()
        return all.filter { entry in
            entry.id.localizedCaseInsensitiveContains(q) ||
            entry.keywords.contains { $0.localizedCaseInsensitiveContains(q) }
        }
    }

    // MARK: - Communication

    static let communication: [SFSymbolEntry] = [
        .init(id: "envelope", keywords: ["email", "mail", "message", "letter"]),
        .init(id: "envelope.fill", keywords: ["email", "mail", "message", "letter"]),
        .init(id: "envelope.open", keywords: ["email", "mail", "read", "open"]),
        .init(id: "paperplane", keywords: ["send", "mail", "message"]),
        .init(id: "paperplane.fill", keywords: ["send", "mail", "message"]),
        .init(id: "phone", keywords: ["call", "telephone", "dial", "contact"]),
        .init(id: "phone.fill", keywords: ["call", "telephone", "dial", "contact"]),
        .init(id: "bubble.left", keywords: ["chat", "message", "text", "sms", "comment"]),
        .init(id: "bubble.left.fill", keywords: ["chat", "message", "text", "sms", "comment"]),
        .init(id: "bubble.right", keywords: ["chat", "message", "reply"]),
        .init(id: "bubble.left.and.bubble.right", keywords: ["conversation", "chat", "discussion"]),
        .init(id: "megaphone", keywords: ["announce", "broadcast", "speaker"]),
        .init(id: "megaphone.fill", keywords: ["announce", "broadcast", "speaker"]),
        .init(id: "bell", keywords: ["notification", "alert", "reminder"]),
        .init(id: "bell.fill", keywords: ["notification", "alert", "reminder"]),
        .init(id: "bell.slash", keywords: ["mute", "silent", "notification off"]),
        .init(id: "video", keywords: ["camera", "facetime", "call", "record"]),
        .init(id: "video.fill", keywords: ["camera", "facetime", "call", "record"]),
    ]

    // MARK: - People

    static let people: [SFSymbolEntry] = [
        .init(id: "person", keywords: ["user", "profile", "account", "people"]),
        .init(id: "person.fill", keywords: ["user", "profile", "account", "people"]),
        .init(id: "person.circle", keywords: ["user", "profile", "avatar"]),
        .init(id: "person.circle.fill", keywords: ["user", "profile", "avatar"]),
        .init(id: "person.2", keywords: ["group", "team", "people", "friends"]),
        .init(id: "person.2.fill", keywords: ["group", "team", "people", "friends"]),
        .init(id: "person.3", keywords: ["group", "team", "people", "crowd"]),
        .init(id: "person.crop.rectangle", keywords: ["badge", "id", "card", "contact"]),
        .init(id: "person.text.rectangle", keywords: ["contact", "vcard", "business card"]),
        .init(id: "figure.stand", keywords: ["person", "body", "standing"]),
        .init(id: "hand.raised", keywords: ["stop", "wave", "hi", "volunteer"]),
        .init(id: "hand.raised.fill", keywords: ["stop", "wave", "hi", "volunteer"]),
        .init(id: "hand.thumbsup", keywords: ["like", "approve", "good"]),
        .init(id: "hand.thumbsup.fill", keywords: ["like", "approve", "good"]),
        .init(id: "hand.wave", keywords: ["hello", "hi", "greeting", "wave"]),
        .init(id: "hand.wave.fill", keywords: ["hello", "hi", "greeting", "wave"]),
    ]

    // MARK: - Devices & Tech

    static let devices: [SFSymbolEntry] = [
        .init(id: "desktopcomputer", keywords: ["mac", "computer", "monitor", "desktop"]),
        .init(id: "laptopcomputer", keywords: ["macbook", "laptop", "computer"]),
        .init(id: "iphone", keywords: ["phone", "mobile", "device", "smartphone"]),
        .init(id: "ipad", keywords: ["tablet", "device"]),
        .init(id: "applewatch", keywords: ["watch", "wearable"]),
        .init(id: "keyboard", keywords: ["type", "input", "keyboard"]),
        .init(id: "printer", keywords: ["print", "output"]),
        .init(id: "tv", keywords: ["television", "screen", "display", "monitor"]),
        .init(id: "gamecontroller", keywords: ["game", "play", "controller", "gaming"]),
        .init(id: "gamecontroller.fill", keywords: ["game", "play", "controller", "gaming"]),
        .init(id: "headphones", keywords: ["audio", "music", "listen"]),
        .init(id: "hifispeaker", keywords: ["audio", "speaker", "music", "sound"]),
        .init(id: "camera", keywords: ["photo", "picture", "capture"]),
        .init(id: "camera.fill", keywords: ["photo", "picture", "capture"]),
        .init(id: "qrcode", keywords: ["scan", "code", "barcode"]),
        .init(id: "barcode", keywords: ["scan", "code", "product"]),
        .init(id: "cpu", keywords: ["processor", "chip", "hardware"]),
        .init(id: "memorychip", keywords: ["ram", "memory", "hardware"]),
        .init(id: "server.rack", keywords: ["server", "hosting", "backend"]),
    ]

    // MARK: - Connectivity

    static let connectivity: [SFSymbolEntry] = [
        .init(id: "wifi", keywords: ["internet", "wireless", "network"]),
        .init(id: "globe", keywords: ["web", "internet", "world", "website"]),
        .init(id: "globe.americas", keywords: ["web", "world", "america"]),
        .init(id: "globe.europe.africa", keywords: ["web", "world", "europe", "africa"]),
        .init(id: "globe.asia.australia", keywords: ["web", "world", "asia", "australia"]),
        .init(id: "network", keywords: ["internet", "connection", "web"]),
        .init(id: "link", keywords: ["url", "chain", "connection", "hyperlink"]),
        .init(id: "antenna.radiowaves.left.and.right", keywords: ["broadcast", "signal", "radio"]),
        .init(id: "icloud", keywords: ["cloud", "storage", "sync", "backup"]),
        .init(id: "icloud.fill", keywords: ["cloud", "storage", "sync", "backup"]),
        .init(id: "bolt.horizontal", keywords: ["connection", "ethernet"]),
    ]

    // MARK: - Media

    static let media: [SFSymbolEntry] = [
        .init(id: "play", keywords: ["start", "video", "media"]),
        .init(id: "play.fill", keywords: ["start", "video", "media"]),
        .init(id: "pause", keywords: ["stop", "wait", "media"]),
        .init(id: "stop.fill", keywords: ["end", "media"]),
        .init(id: "music.note", keywords: ["song", "audio", "music"]),
        .init(id: "music.note.list", keywords: ["playlist", "songs", "music"]),
        .init(id: "mic", keywords: ["microphone", "audio", "record", "voice"]),
        .init(id: "mic.fill", keywords: ["microphone", "audio", "record", "voice"]),
        .init(id: "speaker.wave.2", keywords: ["volume", "sound", "audio"]),
        .init(id: "speaker.wave.2.fill", keywords: ["volume", "sound", "audio"]),
        .init(id: "speaker.slash", keywords: ["mute", "silent", "no sound"]),
        .init(id: "photo", keywords: ["image", "picture", "gallery"]),
        .init(id: "photo.fill", keywords: ["image", "picture", "gallery"]),
        .init(id: "film", keywords: ["movie", "video", "cinema"]),
        .init(id: "music.mic", keywords: ["karaoke", "sing", "microphone"]),
        .init(id: "radio", keywords: ["broadcast", "fm", "am", "station"]),
        .init(id: "radio.fill", keywords: ["broadcast", "fm", "am", "station"]),
    ]

    // MARK: - Commerce & Finance

    static let commerce: [SFSymbolEntry] = [
        .init(id: "creditcard", keywords: ["payment", "card", "bank", "money", "finance"]),
        .init(id: "creditcard.fill", keywords: ["payment", "card", "bank", "money", "finance"]),
        .init(id: "banknote", keywords: ["money", "cash", "payment", "dollar"]),
        .init(id: "banknote.fill", keywords: ["money", "cash", "payment", "dollar"]),
        .init(id: "dollarsign.circle", keywords: ["money", "price", "cost", "dollar", "currency"]),
        .init(id: "dollarsign.circle.fill", keywords: ["money", "price", "cost", "dollar", "currency"]),
        .init(id: "yensign.circle", keywords: ["money", "yen", "japan", "currency"]),
        .init(id: "eurosign.circle", keywords: ["money", "euro", "europe", "currency"]),
        .init(id: "sterlingsign.circle", keywords: ["money", "pound", "uk", "currency"]),
        .init(id: "cart", keywords: ["shop", "buy", "store", "shopping"]),
        .init(id: "cart.fill", keywords: ["shop", "buy", "store", "shopping"]),
        .init(id: "bag", keywords: ["shop", "store", "shopping", "purchase"]),
        .init(id: "bag.fill", keywords: ["shop", "store", "shopping", "purchase"]),
        .init(id: "gift", keywords: ["present", "reward", "surprise"]),
        .init(id: "gift.fill", keywords: ["present", "reward", "surprise"]),
        .init(id: "tag", keywords: ["label", "price", "sale", "discount"]),
        .init(id: "tag.fill", keywords: ["label", "price", "sale", "discount"]),
        .init(id: "receipt", keywords: ["bill", "invoice", "payment"]),
        .init(id: "building.columns", keywords: ["bank", "institution", "government"]),
        .init(id: "building.columns.fill", keywords: ["bank", "institution", "government"]),
    ]

    // MARK: - Health & Fitness

    static let health: [SFSymbolEntry] = [
        .init(id: "heart", keywords: ["love", "like", "favorite", "health"]),
        .init(id: "heart.fill", keywords: ["love", "like", "favorite", "health"]),
        .init(id: "heart.circle", keywords: ["love", "like", "favorite", "health"]),
        .init(id: "bolt.heart", keywords: ["health", "fitness", "workout"]),
        .init(id: "cross.case", keywords: ["medical", "first aid", "health", "emergency"]),
        .init(id: "cross.case.fill", keywords: ["medical", "first aid", "health", "emergency"]),
        .init(id: "pills", keywords: ["medicine", "medication", "pharmacy"]),
        .init(id: "pills.fill", keywords: ["medicine", "medication", "pharmacy"]),
        .init(id: "stethoscope", keywords: ["doctor", "medical", "health"]),
        .init(id: "figure.run", keywords: ["exercise", "running", "fitness", "sport"]),
        .init(id: "figure.walk", keywords: ["walk", "steps", "fitness"]),
        .init(id: "dumbbell", keywords: ["gym", "workout", "fitness", "exercise"]),
        .init(id: "dumbbell.fill", keywords: ["gym", "workout", "fitness", "exercise"]),
        .init(id: "flame", keywords: ["fire", "hot", "calories", "burn"]),
        .init(id: "flame.fill", keywords: ["fire", "hot", "calories", "burn"]),
    ]

    // MARK: - Nature & Weather

    static let nature: [SFSymbolEntry] = [
        .init(id: "sun.max", keywords: ["weather", "bright", "day", "sunny"]),
        .init(id: "sun.max.fill", keywords: ["weather", "bright", "day", "sunny"]),
        .init(id: "moon", keywords: ["night", "dark", "sleep"]),
        .init(id: "moon.fill", keywords: ["night", "dark", "sleep"]),
        .init(id: "moon.stars", keywords: ["night", "sky", "stars"]),
        .init(id: "cloud", keywords: ["weather", "cloudy", "sky"]),
        .init(id: "cloud.fill", keywords: ["weather", "cloudy", "sky"]),
        .init(id: "cloud.rain", keywords: ["weather", "rainy", "storm"]),
        .init(id: "cloud.rain.fill", keywords: ["weather", "rainy", "storm"]),
        .init(id: "cloud.bolt", keywords: ["weather", "thunder", "storm", "lightning"]),
        .init(id: "snowflake", keywords: ["cold", "winter", "snow", "freeze"]),
        .init(id: "wind", keywords: ["weather", "breeze", "air"]),
        .init(id: "drop", keywords: ["water", "rain", "liquid"]),
        .init(id: "drop.fill", keywords: ["water", "rain", "liquid"]),
        .init(id: "leaf", keywords: ["nature", "plant", "eco", "green"]),
        .init(id: "leaf.fill", keywords: ["nature", "plant", "eco", "green"]),
        .init(id: "tree", keywords: ["nature", "forest", "plant"]),
        .init(id: "tree.fill", keywords: ["nature", "forest", "plant"]),
        .init(id: "mountain.2", keywords: ["nature", "landscape", "hiking"]),
        .init(id: "mountain.2.fill", keywords: ["nature", "landscape", "hiking"]),
    ]

    // MARK: - Travel & Transport

    static let travel: [SFSymbolEntry] = [
        .init(id: "car", keywords: ["vehicle", "drive", "auto", "transport"]),
        .init(id: "car.fill", keywords: ["vehicle", "drive", "auto", "transport"]),
        .init(id: "bus", keywords: ["transport", "public", "transit"]),
        .init(id: "tram", keywords: ["train", "transport", "rail", "transit"]),
        .init(id: "bicycle", keywords: ["bike", "cycle", "transport"]),
        .init(id: "airplane", keywords: ["flight", "travel", "plane"]),
        .init(id: "ferry", keywords: ["boat", "ship", "water", "transport"]),
        .init(id: "ferry.fill", keywords: ["boat", "ship", "water", "transport"]),
        .init(id: "fuelpump", keywords: ["gas", "petrol", "fuel", "station"]),
        .init(id: "fuelpump.fill", keywords: ["gas", "petrol", "fuel", "station"]),
        .init(id: "location", keywords: ["gps", "pin", "map", "navigate"]),
        .init(id: "location.fill", keywords: ["gps", "pin", "map", "navigate"]),
        .init(id: "map", keywords: ["location", "navigate", "directions"]),
        .init(id: "map.fill", keywords: ["location", "navigate", "directions"]),
        .init(id: "mappin", keywords: ["location", "pin", "place"]),
        .init(id: "mappin.circle", keywords: ["location", "pin", "place"]),
        .init(id: "house", keywords: ["home", "building", "residence"]),
        .init(id: "house.fill", keywords: ["home", "building", "residence"]),
        .init(id: "building.2", keywords: ["office", "city", "work"]),
        .init(id: "building.2.fill", keywords: ["office", "city", "work"]),
    ]

    // MARK: - Objects & Tools

    static let objects: [SFSymbolEntry] = [
        .init(id: "pencil", keywords: ["edit", "write", "draw"]),
        .init(id: "pencil.circle", keywords: ["edit", "write", "draw"]),
        .init(id: "trash", keywords: ["delete", "remove", "bin"]),
        .init(id: "trash.fill", keywords: ["delete", "remove", "bin"]),
        .init(id: "folder", keywords: ["file", "directory", "organize"]),
        .init(id: "folder.fill", keywords: ["file", "directory", "organize"]),
        .init(id: "doc", keywords: ["document", "file", "page"]),
        .init(id: "doc.fill", keywords: ["document", "file", "page"]),
        .init(id: "doc.text", keywords: ["document", "text", "file", "page"]),
        .init(id: "doc.text.fill", keywords: ["document", "text", "file", "page"]),
        .init(id: "doc.on.doc", keywords: ["copy", "duplicate", "clipboard"]),
        .init(id: "clipboard", keywords: ["paste", "copy", "notes"]),
        .init(id: "clipboard.fill", keywords: ["paste", "copy", "notes"]),
        .init(id: "paperclip", keywords: ["attach", "attachment", "file"]),
        .init(id: "scissors", keywords: ["cut", "trim"]),
        .init(id: "book", keywords: ["read", "library", "education"]),
        .init(id: "book.fill", keywords: ["read", "library", "education"]),
        .init(id: "bookmark", keywords: ["save", "favorite", "read"]),
        .init(id: "bookmark.fill", keywords: ["save", "favorite", "read"]),
        .init(id: "calendar", keywords: ["date", "schedule", "event", "day"]),
        .init(id: "clock", keywords: ["time", "schedule", "hour"]),
        .init(id: "clock.fill", keywords: ["time", "schedule", "hour"]),
        .init(id: "alarm", keywords: ["time", "wake", "reminder", "clock"]),
        .init(id: "alarm.fill", keywords: ["time", "wake", "reminder", "clock"]),
        .init(id: "timer", keywords: ["countdown", "stopwatch", "time"]),
        .init(id: "hourglass", keywords: ["time", "wait", "loading"]),
        .init(id: "key", keywords: ["password", "lock", "security", "access"]),
        .init(id: "key.fill", keywords: ["password", "lock", "security", "access"]),
        .init(id: "lock", keywords: ["security", "password", "private"]),
        .init(id: "lock.fill", keywords: ["security", "password", "private"]),
        .init(id: "lock.open", keywords: ["unlock", "open", "access"]),
        .init(id: "eye", keywords: ["view", "see", "visible", "show"]),
        .init(id: "eye.fill", keywords: ["view", "see", "visible", "show"]),
        .init(id: "eye.slash", keywords: ["hide", "invisible", "hidden"]),
        .init(id: "magnifyingglass", keywords: ["search", "find", "zoom"]),
        .init(id: "lightbulb", keywords: ["idea", "tip", "light"]),
        .init(id: "lightbulb.fill", keywords: ["idea", "tip", "light"]),
        .init(id: "wrench", keywords: ["tool", "settings", "fix", "repair"]),
        .init(id: "wrench.fill", keywords: ["tool", "settings", "fix", "repair"]),
        .init(id: "hammer", keywords: ["tool", "build", "construct"]),
        .init(id: "hammer.fill", keywords: ["tool", "build", "construct"]),
        .init(id: "gearshape", keywords: ["settings", "preferences", "config"]),
        .init(id: "gearshape.fill", keywords: ["settings", "preferences", "config"]),
        .init(id: "slider.horizontal.3", keywords: ["settings", "adjust", "controls"]),
        .init(id: "paintbrush", keywords: ["art", "design", "draw", "paint"]),
        .init(id: "paintbrush.fill", keywords: ["art", "design", "draw", "paint"]),
        .init(id: "flag", keywords: ["report", "mark", "country"]),
        .init(id: "flag.fill", keywords: ["report", "mark", "country"]),
        .init(id: "pin", keywords: ["pinned", "save", "mark", "location"]),
        .init(id: "pin.fill", keywords: ["pinned", "save", "mark", "location"]),
    ]

    // MARK: - Shapes & Symbols

    static let shapes: [SFSymbolEntry] = [
        .init(id: "star", keywords: ["favorite", "rating", "bookmark"]),
        .init(id: "star.fill", keywords: ["favorite", "rating", "bookmark"]),
        .init(id: "circle", keywords: ["dot", "shape", "round"]),
        .init(id: "circle.fill", keywords: ["dot", "shape", "round"]),
        .init(id: "square", keywords: ["shape", "box"]),
        .init(id: "square.fill", keywords: ["shape", "box"]),
        .init(id: "triangle", keywords: ["shape", "warning"]),
        .init(id: "triangle.fill", keywords: ["shape", "warning"]),
        .init(id: "diamond", keywords: ["shape", "gem"]),
        .init(id: "diamond.fill", keywords: ["shape", "gem"]),
        .init(id: "hexagon", keywords: ["shape", "six"]),
        .init(id: "hexagon.fill", keywords: ["shape", "six"]),
        .init(id: "shield", keywords: ["security", "protect", "safe"]),
        .init(id: "shield.fill", keywords: ["security", "protect", "safe"]),
        .init(id: "checkmark", keywords: ["done", "complete", "yes", "success"]),
        .init(id: "checkmark.circle", keywords: ["done", "complete", "success"]),
        .init(id: "checkmark.circle.fill", keywords: ["done", "complete", "success"]),
        .init(id: "xmark", keywords: ["close", "cancel", "no", "delete"]),
        .init(id: "xmark.circle", keywords: ["close", "cancel", "remove"]),
        .init(id: "xmark.circle.fill", keywords: ["close", "cancel", "remove"]),
        .init(id: "exclamationmark.triangle", keywords: ["warning", "alert", "caution"]),
        .init(id: "exclamationmark.triangle.fill", keywords: ["warning", "alert", "caution"]),
        .init(id: "info.circle", keywords: ["information", "about", "details"]),
        .init(id: "info.circle.fill", keywords: ["information", "about", "details"]),
        .init(id: "questionmark.circle", keywords: ["help", "question", "support"]),
        .init(id: "questionmark.circle.fill", keywords: ["help", "question", "support"]),
        .init(id: "plus.circle", keywords: ["add", "new", "create"]),
        .init(id: "plus.circle.fill", keywords: ["add", "new", "create"]),
        .init(id: "minus.circle", keywords: ["remove", "subtract", "less"]),
        .init(id: "minus.circle.fill", keywords: ["remove", "subtract", "less"]),
    ]

    // MARK: - Text & Formatting

    static let text: [SFSymbolEntry] = [
        .init(id: "textformat", keywords: ["font", "type", "text"]),
        .init(id: "bold", keywords: ["text", "format", "strong"]),
        .init(id: "italic", keywords: ["text", "format", "slant"]),
        .init(id: "underline", keywords: ["text", "format"]),
        .init(id: "list.bullet", keywords: ["list", "menu", "items"]),
        .init(id: "list.number", keywords: ["list", "ordered", "numbered"]),
        .init(id: "text.bubble", keywords: ["message", "chat", "text", "sms"]),
        .init(id: "text.bubble.fill", keywords: ["message", "chat", "text", "sms"]),
        .init(id: "quote.opening", keywords: ["quote", "citation", "text"]),
        .init(id: "quote.closing", keywords: ["quote", "citation", "text"]),
        .init(id: "number", keywords: ["hash", "hashtag", "pound"]),
        .init(id: "at", keywords: ["email", "mention", "address"]),
    ]

    // MARK: - Arrows & Navigation

    static let arrows: [SFSymbolEntry] = [
        .init(id: "arrow.up", keywords: ["up", "upload", "direction"]),
        .init(id: "arrow.down", keywords: ["down", "download", "direction"]),
        .init(id: "arrow.left", keywords: ["back", "previous", "direction"]),
        .init(id: "arrow.right", keywords: ["forward", "next", "direction"]),
        .init(id: "arrow.up.arrow.down", keywords: ["sort", "swap", "exchange"]),
        .init(id: "arrow.clockwise", keywords: ["refresh", "reload", "rotate"]),
        .init(id: "arrow.counterclockwise", keywords: ["undo", "refresh", "rotate"]),
        .init(id: "arrow.uturn.backward", keywords: ["undo", "back", "return"]),
        .init(id: "arrow.uturn.forward", keywords: ["redo", "forward"]),
        .init(id: "square.and.arrow.up", keywords: ["share", "export", "upload"]),
        .init(id: "square.and.arrow.down", keywords: ["download", "save", "import"]),
        .init(id: "arrow.down.circle", keywords: ["download", "save"]),
        .init(id: "arrow.down.circle.fill", keywords: ["download", "save"]),
        .init(id: "arrow.triangle.2.circlepath", keywords: ["sync", "refresh", "update"]),
    ]

    // MARK: - Indices & Numbers

    static let indices: [SFSymbolEntry] = [
        .init(id: "1.circle", keywords: ["one", "first", "number"]),
        .init(id: "1.circle.fill", keywords: ["one", "first", "number"]),
        .init(id: "2.circle", keywords: ["two", "second", "number"]),
        .init(id: "2.circle.fill", keywords: ["two", "second", "number"]),
        .init(id: "3.circle", keywords: ["three", "third", "number"]),
        .init(id: "3.circle.fill", keywords: ["three", "third", "number"]),
        .init(id: "a.circle", keywords: ["letter", "alpha"]),
        .init(id: "b.circle", keywords: ["letter", "bravo"]),
        .init(id: "c.circle", keywords: ["letter", "charlie"]),
    ]
}
