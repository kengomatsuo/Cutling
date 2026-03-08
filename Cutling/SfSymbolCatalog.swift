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

    enum Category: String, CaseIterable, Identifiable {
        case people = "People"
        case communication = "Chat"
        case media = "Media"
        case objects = "Objects"
        case tech = "Tech"
        case places = "Places"
        case commerce = "Commerce"
        case symbols = "Symbols"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .people: "person.2"
            case .communication: "bubble.left.and.bubble.right"
            case .media: "play.circle"
            case .objects: "wrench"
            case .tech: "desktopcomputer"
            case .places: "map"
            case .commerce: "cart"
            case .symbols: "number"
            }
        }

        var entries: [SFSymbolEntry] {
            switch self {
            case .people:
                SFSymbolCatalog.people + SFSymbolCatalog.accessibility + SFSymbolCatalog.health
            case .communication:
                SFSymbolCatalog.communication
            case .media:
                SFSymbolCatalog.media + SFSymbolCatalog.gaming
            case .objects:
                SFSymbolCatalog.objects + SFSymbolCatalog.food + SFSymbolCatalog.editing
            case .tech:
                SFSymbolCatalog.devices + SFSymbolCatalog.connectivity + SFSymbolCatalog.math
            case .places:
                SFSymbolCatalog.travel + SFSymbolCatalog.nature
            case .commerce:
                SFSymbolCatalog.commerce + SFSymbolCatalog.science
            case .symbols:
                SFSymbolCatalog.shapes + SFSymbolCatalog.text + SFSymbolCatalog.arrows
                    + SFSymbolCatalog.indices + SFSymbolCatalog.privacy
            }
        }
    }

    static let all: [SFSymbolEntry] = communication + people + devices + connectivity
        + media + commerce + health + nature + travel + objects + shapes + text + arrows
        + indices + food + science + gaming + privacy + accessibility + editing + math

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
        .init(id: "envelope", keywords: ["email", "mail", "message", "letter", "inbox", "send", "correspondence", "postal"]),
        .init(id: "envelope.open", keywords: ["email", "mail", "read", "open", "letter", "inbox", "unread"]),
        .init(id: "envelope.badge", keywords: ["email", "mail", "notification", "unread", "new", "badge"]),
        .init(id: "envelope.arrow.triangle.branch", keywords: ["email", "forward", "redirect", "mail"]),
        .init(id: "paperplane", keywords: ["send", "mail", "message", "submit", "deliver", "telegram", "dispatch"]),
        .init(id: "phone", keywords: ["call", "telephone", "dial", "contact", "ring", "mobile", "cellphone"]),
        .init(id: "phone.arrow.up.right", keywords: ["call", "outgoing", "dial", "phone"]),
        .init(id: "phone.arrow.down.left", keywords: ["call", "incoming", "receive", "phone"]),
        .init(id: "phone.badge.plus", keywords: ["call", "add", "new", "contact", "phone"]),
        .init(id: "bubble.left", keywords: ["chat", "message", "text", "sms", "comment", "speech", "talk", "conversation", "imessage"]),
        .init(id: "bubble.right", keywords: ["chat", "message", "reply", "response", "text", "speech"]),
        .init(id: "bubble.left.and.bubble.right", keywords: ["conversation", "chat", "discussion", "dialogue", "talk", "thread"]),
        .init(id: "bubble.left.and.text.bubble.right", keywords: ["conversation", "chat", "ai", "assistant", "bot", "reply"]),
        .init(id: "ellipsis.bubble", keywords: ["typing", "thinking", "chat", "loading", "message"]),
        .init(id: "megaphone", keywords: ["announce", "broadcast", "speaker", "promotion", "marketing", "shout", "amplify"]),
        .init(id: "bell", keywords: ["notification", "alert", "reminder", "ring", "alarm", "notify", "push"]),
        .init(id: "bell.badge", keywords: ["notification", "alert", "new", "unread", "badge", "count"]),
        .init(id: "bell.slash", keywords: ["mute", "silent", "notification off", "do not disturb", "quiet", "dnd"]),
        .init(id: "video", keywords: ["camera", "facetime", "call", "record", "film", "stream", "conference", "meeting"]),
        .init(id: "video.slash", keywords: ["camera off", "no video", "disabled", "mute video"]),
        .init(id: "captions.bubble", keywords: ["subtitle", "caption", "text", "accessibility", "closed caption"]),
        .init(id: "quote.bubble", keywords: ["quote", "speech", "message", "citation", "reply"]),
    ]

    // MARK: - People

    static let people: [SFSymbolEntry] = [
        .init(id: "person", keywords: ["user", "profile", "account", "people", "individual", "contact", "member", "human"]),
        .init(id: "person.circle", keywords: ["user", "profile", "avatar", "account", "picture", "photo", "identity"]),
        .init(id: "person.2", keywords: ["group", "team", "people", "friends", "duo", "pair", "couple", "together"]),
        .init(id: "person.3", keywords: ["group", "team", "people", "crowd", "community", "members", "organization"]),
        .init(id: "person.crop.rectangle", keywords: ["badge", "id", "card", "contact", "identification", "employee"]),
        .init(id: "person.text.rectangle", keywords: ["contact", "vcard", "business card", "profile", "info"]),
        .init(id: "person.crop.square", keywords: ["profile", "photo", "portrait", "headshot", "avatar"]),
        .init(id: "person.badge.plus", keywords: ["add", "invite", "new user", "register", "follow", "friend request"]),
        .init(id: "person.badge.minus", keywords: ["remove", "unfriend", "block", "delete user", "unfollow"]),
        .init(id: "person.badge.key", keywords: ["admin", "access", "permission", "role", "authentication"]),
        .init(id: "person.badge.clock", keywords: ["schedule", "appointment", "wait", "pending", "history"]),
        .init(id: "figure.stand", keywords: ["person", "body", "standing", "human", "pose", "figure"]),
        .init(id: "figure.wave", keywords: ["hello", "hi", "greeting", "wave", "welcome", "bye"]),
        .init(id: "hand.raised", keywords: ["stop", "wave", "hi", "volunteer", "palm", "halt", "block", "deny"]),
        .init(id: "hand.thumbsup", keywords: ["like", "approve", "good", "positive", "upvote", "agree", "ok"]),
        .init(id: "hand.thumbsdown", keywords: ["dislike", "disapprove", "bad", "negative", "downvote", "reject"]),
        .init(id: "hand.wave", keywords: ["hello", "hi", "greeting", "wave", "goodbye", "welcome", "hey"]),
        .init(id: "hand.point.up.left", keywords: ["point", "tap", "touch", "gesture", "click", "select"]),
        .init(id: "hand.draw", keywords: ["draw", "sign", "signature", "write", "gesture", "freehand"]),
        .init(id: "hands.clap", keywords: ["clap", "applause", "bravo", "cheer", "congratulate"]),
        .init(id: "person.crop.circle.badge.checkmark", keywords: ["verified", "approved", "confirmed", "identity"]),
        .init(id: "shared.with.you", keywords: ["shared", "share", "collaboration", "together", "social"]),
    ]

    // MARK: - Devices & Tech

    static let devices: [SFSymbolEntry] = [
        .init(id: "desktopcomputer", keywords: ["mac", "computer", "monitor", "desktop", "imac", "pc", "workstation", "screen"]),
        .init(id: "laptopcomputer", keywords: ["macbook", "laptop", "computer", "notebook", "portable", "pc"]),
        .init(id: "iphone", keywords: ["phone", "mobile", "device", "smartphone", "cell", "ios", "touchscreen"]),
        .init(id: "ipad", keywords: ["tablet", "device", "touchscreen", "slate", "ipados"]),
        .init(id: "applewatch", keywords: ["watch", "wearable", "smartwatch", "wrist", "fitness tracker"]),
        .init(id: "visionpro", keywords: ["vision", "headset", "ar", "vr", "spatial", "mixed reality", "goggles"]),
        .init(id: "keyboard", keywords: ["type", "input", "keyboard", "keys", "typing", "text entry"]),
        .init(id: "computermouse", keywords: ["mouse", "click", "cursor", "pointer", "input"]),
        .init(id: "printer", keywords: ["print", "output", "paper", "document", "hardcopy"]),
        .init(id: "scanner", keywords: ["scan", "digitize", "document", "copy"]),
        .init(id: "tv", keywords: ["television", "screen", "display", "monitor", "entertainment", "streaming"]),
        .init(id: "display", keywords: ["monitor", "screen", "external display", "output"]),
        .init(id: "gamecontroller", keywords: ["game", "play", "controller", "gaming", "joystick", "console", "xbox", "playstation"]),
        .init(id: "headphones", keywords: ["audio", "music", "listen", "earphones", "earbuds", "airpods", "beats"]),
        .init(id: "hifispeaker", keywords: ["audio", "speaker", "music", "sound", "homepod", "stereo", "bass"]),
        .init(id: "hifispeaker.2", keywords: ["audio", "speakers", "stereo", "surround", "music"]),
        .init(id: "homepodmini", keywords: ["speaker", "siri", "smart speaker", "audio", "assistant"]),
        .init(id: "camera", keywords: ["photo", "picture", "capture", "shoot", "photograph", "lens", "snapshot"]),
        .init(id: "camera.viewfinder", keywords: ["scan", "capture", "viewfinder", "frame", "focus"]),
        .init(id: "qrcode", keywords: ["scan", "code", "barcode", "qr", "link", "url", "matrix"]),
        .init(id: "qrcode.viewfinder", keywords: ["scan", "qr", "camera", "read", "decode"]),
        .init(id: "barcode", keywords: ["scan", "code", "product", "upc", "ean", "price"]),
        .init(id: "barcode.viewfinder", keywords: ["scan", "barcode", "camera", "read"]),
        .init(id: "cpu", keywords: ["processor", "chip", "hardware", "computing", "silicon", "core"]),
        .init(id: "memorychip", keywords: ["ram", "memory", "hardware", "storage", "chip"]),
        .init(id: "server.rack", keywords: ["server", "hosting", "backend", "data center", "infrastructure", "cloud"]),
        .init(id: "externaldrive", keywords: ["storage", "disk", "drive", "backup", "hard drive", "ssd", "hdd"]),
        .init(id: "opticaldiscdrive", keywords: ["cd", "dvd", "disc", "optical", "drive", "media"]),
        .init(id: "cable.connector", keywords: ["cable", "wire", "connect", "usb", "plug", "charge"]),
        .init(id: "battery.100", keywords: ["battery", "power", "charge", "energy", "full"]),
        .init(id: "battery.25", keywords: ["battery", "low", "charge", "power", "dying"]),
        .init(id: "bolt.batteryblock", keywords: ["charging", "battery", "power", "energy"]),
        .init(id: "simcard", keywords: ["sim", "card", "mobile", "phone", "carrier", "cellular"]),
        .init(id: "sdcard", keywords: ["sd", "card", "storage", "memory", "photo"]),
        .init(id: "flipphone", keywords: ["phone", "retro", "old", "mobile", "vintage"]),
        .init(id: "candybarphone", keywords: ["phone", "retro", "nokia", "old", "mobile"]),
    ]

    // MARK: - Connectivity

    static let connectivity: [SFSymbolEntry] = [
        .init(id: "wifi", keywords: ["internet", "wireless", "network", "connection", "online", "hotspot", "signal"]),
        .init(id: "wifi.slash", keywords: ["no internet", "offline", "disconnected", "no wifi"]),
        .init(id: "wifi.exclamationmark", keywords: ["wifi error", "connection problem", "weak signal"]),
        .init(id: "globe", keywords: ["web", "internet", "world", "website", "browser", "online", "earth", "global"]),
        .init(id: "globe.americas", keywords: ["web", "world", "america", "north america", "south america", "western hemisphere"]),
        .init(id: "globe.europe.africa", keywords: ["web", "world", "europe", "africa", "eastern hemisphere"]),
        .init(id: "globe.asia.australia", keywords: ["web", "world", "asia", "australia", "pacific", "eastern"]),
        .init(id: "network", keywords: ["internet", "connection", "web", "mesh", "infrastructure", "nodes"]),
        .init(id: "network.badge.shield.half.filled", keywords: ["vpn", "security", "network", "protected", "encrypted"]),
        .init(id: "link", keywords: ["url", "chain", "connection", "hyperlink", "link", "attach", "reference"]),
        .init(id: "link.badge.plus", keywords: ["add link", "new link", "attach", "connect"]),
        .init(id: "antenna.radiowaves.left.and.right", keywords: ["broadcast", "signal", "radio", "wireless", "transmit", "cellular"]),
        .init(id: "dot.radiowaves.left.and.right", keywords: ["broadcast", "signal", "nfc", "tap", "contactless"]),
        .init(id: "icloud", keywords: ["cloud", "storage", "sync", "backup", "upload", "download", "online"]),
        .init(id: "icloud.and.arrow.up", keywords: ["upload", "cloud", "sync", "backup", "send"]),
        .init(id: "icloud.and.arrow.down", keywords: ["download", "cloud", "sync", "fetch", "get"]),
        .init(id: "bolt.horizontal", keywords: ["connection", "ethernet", "thunderbolt", "wired", "cable"]),
        .init(id: "cellularbars", keywords: ["signal", "mobile", "cellular", "reception", "coverage"]),
        .init(id: "personalhotspot", keywords: ["hotspot", "tethering", "share", "wifi", "mobile"]),
        .init(id: "airplayaudio", keywords: ["airplay", "stream", "cast", "audio", "wireless"]),
        .init(id: "airplayvideo", keywords: ["airplay", "stream", "cast", "video", "wireless", "mirror"]),
    ]

    // MARK: - Media

    static let media: [SFSymbolEntry] = [
        .init(id: "play", keywords: ["start", "video", "media", "begin", "resume", "watch", "listen"]),
        .init(id: "pause", keywords: ["stop", "wait", "media", "hold", "break", "suspend"]),
        .init(id: "stop", keywords: ["end", "media", "halt", "finish", "cease"]),
        .init(id: "record.circle", keywords: ["record", "recording", "live", "capture", "red dot"]),
        .init(id: "play.rectangle", keywords: ["video", "player", "media", "watch", "stream"]),
        .init(id: "play.circle", keywords: ["play", "start", "video", "media", "watch"]),
        .init(id: "backward", keywords: ["rewind", "back", "previous", "seek"]),
        .init(id: "forward", keywords: ["fast forward", "skip", "next", "seek"]),
        .init(id: "backward.end", keywords: ["beginning", "start", "rewind", "first"]),
        .init(id: "forward.end", keywords: ["end", "last", "skip", "final"]),
        .init(id: "shuffle", keywords: ["random", "mix", "shuffle", "reorder"]),
        .init(id: "repeat", keywords: ["loop", "repeat", "cycle", "again"]),
        .init(id: "repeat.1", keywords: ["loop one", "repeat one", "single"]),
        .init(id: "music.note", keywords: ["song", "audio", "music", "melody", "tune", "track", "note"]),
        .init(id: "music.note.list", keywords: ["playlist", "songs", "music", "queue", "tracklist", "album"]),
        .init(id: "music.quarternote.3", keywords: ["music", "melody", "notes", "tune", "harmony"]),
        .init(id: "music.mic", keywords: ["karaoke", "sing", "microphone", "vocal", "lyrics", "performer"]),
        .init(id: "mic", keywords: ["microphone", "audio", "record", "voice", "speak", "podcast", "input"]),
        .init(id: "mic.slash", keywords: ["mute", "microphone off", "silent", "no audio"]),
        .init(id: "speaker.wave.2", keywords: ["volume", "sound", "audio", "loud", "speaker", "output"]),
        .init(id: "speaker.slash", keywords: ["mute", "silent", "no sound", "quiet", "off"]),
        .init(id: "speaker.wave.1", keywords: ["low volume", "quiet", "soft", "audio"]),
        .init(id: "speaker.wave.3", keywords: ["loud", "max volume", "full", "audio", "high"]),
        .init(id: "photo", keywords: ["image", "picture", "gallery", "photo", "snapshot", "jpeg", "png"]),
        .init(id: "photo.on.rectangle", keywords: ["gallery", "photos", "album", "collection", "images"]),
        .init(id: "photo.stack", keywords: ["gallery", "photos", "album", "stack", "collection"]),
        .init(id: "film", keywords: ["movie", "video", "cinema", "reel", "footage", "clip"]),
        .init(id: "film.stack", keywords: ["movies", "collection", "films", "library"]),
        .init(id: "radio", keywords: ["broadcast", "fm", "am", "station", "tuner", "frequency"]),
        .init(id: "waveform", keywords: ["audio", "sound", "wave", "signal", "equalizer", "spectrum"]),
        .init(id: "waveform.path.ecg", keywords: ["heartbeat", "pulse", "health", "ecg", "heart rate"]),
        .init(id: "dial.low", keywords: ["volume", "knob", "control", "adjust", "tune"]),
        .init(id: "goforward.10", keywords: ["skip", "forward", "10 seconds", "jump ahead"]),
        .init(id: "gobackward.10", keywords: ["rewind", "back", "10 seconds", "jump back"]),
        .init(id: "airpodsmax", keywords: ["headphones", "airpods", "audio", "music", "listen"]),
        .init(id: "airpods", keywords: ["earbuds", "airpods", "audio", "music", "listen", "wireless"]),
        .init(id: "airpodspro", keywords: ["earbuds", "airpods", "audio", "noise cancel", "wireless"]),
    ]

    // MARK: - Commerce & Finance

    static let commerce: [SFSymbolEntry] = [
        .init(id: "creditcard", keywords: ["payment", "card", "bank", "money", "finance", "visa", "mastercard", "debit", "swipe", "tap"]),
        .init(id: "creditcard.trianglebadge.exclamationmark", keywords: ["payment error", "declined", "card problem", "failed"]),
        .init(id: "banknote", keywords: ["money", "cash", "payment", "dollar", "bill", "currency", "note", "paper money"]),
        .init(id: "dollarsign.circle", keywords: ["money", "price", "cost", "dollar", "currency", "usd", "payment", "amount"]),
        .init(id: "yensign.circle", keywords: ["money", "yen", "japan", "currency", "jpy", "japanese"]),
        .init(id: "eurosign.circle", keywords: ["money", "euro", "europe", "currency", "eur", "european"]),
        .init(id: "sterlingsign.circle", keywords: ["money", "pound", "uk", "currency", "gbp", "british"]),
        .init(id: "wonsign.circle", keywords: ["money", "won", "korea", "currency", "krw", "korean"]),
        .init(id: "indianrupeesign.circle", keywords: ["money", "rupee", "india", "currency", "inr", "indian"]),
        .init(id: "bitcoinsign.circle", keywords: ["money", "bitcoin", "crypto", "currency", "btc", "cryptocurrency", "blockchain"]),
        .init(id: "cart", keywords: ["shop", "buy", "store", "shopping", "purchase", "ecommerce", "basket", "checkout"]),
        .init(id: "cart.badge.plus", keywords: ["add to cart", "shop", "buy", "add", "purchase"]),
        .init(id: "cart.badge.minus", keywords: ["remove from cart", "shop", "remove", "delete"]),
        .init(id: "bag", keywords: ["shop", "store", "shopping", "purchase", "retail", "tote", "carry"]),
        .init(id: "gift", keywords: ["present", "reward", "surprise", "birthday", "holiday", "giveaway", "prize"]),
        .init(id: "giftcard", keywords: ["gift card", "voucher", "coupon", "redeem", "store credit"]),
        .init(id: "tag", keywords: ["label", "price", "sale", "discount", "category", "tag", "offer"]),
        .init(id: "receipt", keywords: ["bill", "invoice", "payment", "transaction", "proof", "record"]),
        .init(id: "building.columns", keywords: ["bank", "institution", "government", "courthouse", "museum", "official"]),
        .init(id: "storefront", keywords: ["shop", "store", "retail", "business", "market", "merchant"]),
        .init(id: "chart.bar", keywords: ["statistics", "analytics", "graph", "data", "report", "sales"]),
        .init(id: "chart.pie", keywords: ["statistics", "analytics", "graph", "data", "breakdown", "distribution"]),
        .init(id: "chart.line.uptrend.xyaxis", keywords: ["growth", "trend", "analytics", "graph", "increase", "profit"]),
        .init(id: "percent", keywords: ["discount", "percentage", "sale", "off", "rate", "ratio"]),
        .init(id: "signature", keywords: ["sign", "autograph", "contract", "agreement", "approve"]),
        .init(id: "wallet.pass", keywords: ["wallet", "pass", "ticket", "coupon", "boarding", "card"]),
    ]

    // MARK: - Health & Fitness

    static let health: [SFSymbolEntry] = [
        .init(id: "heart", keywords: ["love", "like", "favorite", "health", "care", "affection", "passion", "valentine"]),
        .init(id: "heart.circle", keywords: ["love", "like", "favorite", "health", "care"]),
        .init(id: "heart.slash", keywords: ["unlike", "dislike", "broken", "remove favorite"]),
        .init(id: "heart.text.square", keywords: ["health record", "medical", "vitals", "health data"]),
        .init(id: "bolt.heart", keywords: ["health", "fitness", "workout", "cardio", "active", "exercise"]),
        .init(id: "cross.case", keywords: ["medical", "first aid", "health", "emergency", "hospital", "doctor"]),
        .init(id: "pills", keywords: ["medicine", "medication", "pharmacy", "drug", "prescription", "capsule"]),
        .init(id: "pill", keywords: ["medicine", "medication", "tablet", "drug", "dose"]),
        .init(id: "syringe", keywords: ["injection", "vaccine", "shot", "medical", "needle", "immunization"]),
        .init(id: "bandage", keywords: ["wound", "injury", "first aid", "heal", "medical", "patch"]),
        .init(id: "stethoscope", keywords: ["doctor", "medical", "health", "checkup", "diagnosis", "examine"]),
        .init(id: "figure.run", keywords: ["exercise", "running", "fitness", "sport", "jog", "marathon", "cardio"]),
        .init(id: "figure.walk", keywords: ["walk", "steps", "fitness", "stroll", "pedestrian", "hike"]),
        .init(id: "figure.hiking", keywords: ["hike", "trail", "outdoor", "walk", "nature", "trek"]),
        .init(id: "figure.pool.swim", keywords: ["swim", "pool", "water", "exercise", "sport", "aquatic"]),
        .init(id: "figure.yoga", keywords: ["yoga", "meditation", "stretch", "relax", "flexibility", "zen"]),
        .init(id: "figure.dance", keywords: ["dance", "party", "move", "fun", "music", "rhythm"]),
        .init(id: "figure.tennis", keywords: ["tennis", "sport", "racket", "game", "court"]),
        .init(id: "figure.basketball", keywords: ["basketball", "sport", "game", "ball", "court", "hoop"]),
        .init(id: "figure.soccer", keywords: ["soccer", "football", "sport", "ball", "game", "kick"]),
        .init(id: "figure.golf", keywords: ["golf", "sport", "club", "course", "putt"]),
        .init(id: "figure.skiing.downhill", keywords: ["ski", "skiing", "winter", "sport", "snow", "slope"]),
        .init(id: "figure.surfing", keywords: ["surf", "surfing", "wave", "ocean", "sport", "beach"]),
        .init(id: "figure.climbing", keywords: ["climb", "climbing", "rock", "sport", "boulder"]),
        .init(id: "figure.boxing", keywords: ["boxing", "fight", "sport", "punch", "mma"]),
        .init(id: "dumbbell", keywords: ["gym", "workout", "fitness", "exercise", "weight", "strength", "lift"]),
        .init(id: "flame", keywords: ["fire", "hot", "calories", "burn", "trending", "popular", "heat"]),
        .init(id: "brain.head.profile", keywords: ["brain", "mind", "think", "mental", "psychology", "intelligence"]),
        .init(id: "lungs", keywords: ["breathing", "respiratory", "lungs", "health", "air"]),
        .init(id: "ear", keywords: ["hearing", "listen", "ear", "sound", "audio", "deaf"]),
        .init(id: "eye", keywords: ["vision", "see", "look", "view", "sight", "watch", "observe"]),
        .init(id: "nose", keywords: ["smell", "nose", "scent", "sniff", "fragrance"]),
        .init(id: "mouth", keywords: ["mouth", "speak", "talk", "taste", "lips", "oral"]),
    ]

    // MARK: - Nature & Weather

    static let nature: [SFSymbolEntry] = [
        .init(id: "sun.max", keywords: ["weather", "bright", "day", "sunny", "sunshine", "light", "daytime", "warm"]),
        .init(id: "sun.min", keywords: ["dim", "low brightness", "dark mode", "low light"]),
        .init(id: "sun.horizon", keywords: ["sunrise", "sunset", "dawn", "dusk", "horizon", "golden hour"]),
        .init(id: "moon", keywords: ["night", "dark", "sleep", "nighttime", "lunar", "crescent"]),
        .init(id: "moon.stars", keywords: ["night", "sky", "stars", "bedtime", "sleep", "evening", "stargazing"]),
        .init(id: "sparkles", keywords: ["sparkle", "magic", "new", "shiny", "glitter", "clean", "ai", "special", "highlight"]),
        .init(id: "cloud", keywords: ["weather", "cloudy", "sky", "overcast", "fog", "haze"]),
        .init(id: "cloud.rain", keywords: ["weather", "rainy", "storm", "precipitation", "shower", "wet"]),
        .init(id: "cloud.heavyrain", keywords: ["weather", "heavy rain", "storm", "downpour", "flood"]),
        .init(id: "cloud.bolt", keywords: ["weather", "thunder", "storm", "lightning", "thunderstorm", "electric"]),
        .init(id: "cloud.snow", keywords: ["weather", "snow", "winter", "cold", "blizzard", "flurry"]),
        .init(id: "cloud.fog", keywords: ["weather", "fog", "mist", "haze", "visibility"]),
        .init(id: "cloud.sun", keywords: ["weather", "partly cloudy", "sunny", "clouds", "fair"]),
        .init(id: "cloud.moon", keywords: ["weather", "night", "partly cloudy", "evening"]),
        .init(id: "snowflake", keywords: ["cold", "winter", "snow", "freeze", "frozen", "ice", "christmas", "holiday"]),
        .init(id: "wind", keywords: ["weather", "breeze", "air", "windy", "blow", "gust"]),
        .init(id: "tornado", keywords: ["weather", "storm", "tornado", "cyclone", "disaster", "wind"]),
        .init(id: "tropicalstorm", keywords: ["weather", "hurricane", "storm", "typhoon", "cyclone"]),
        .init(id: "thermometer.medium", keywords: ["temperature", "weather", "heat", "cold", "degrees", "celsius"]),
        .init(id: "humidity", keywords: ["humidity", "moisture", "weather", "dew", "water"]),
        .init(id: "drop", keywords: ["water", "rain", "liquid", "droplet", "hydrate", "wet", "dew"]),
        .init(id: "leaf", keywords: ["nature", "plant", "eco", "green", "organic", "environment", "sustainable", "vegan"]),
        .init(id: "leaf.arrow.triangle.circlepath", keywords: ["recycle", "eco", "sustainable", "renew", "green", "environment"]),
        .init(id: "tree", keywords: ["nature", "forest", "plant", "wood", "timber", "shade", "park"]),
        .init(id: "mountain.2", keywords: ["nature", "landscape", "hiking", "mountain", "peak", "summit", "outdoor"]),
        .init(id: "water.waves", keywords: ["ocean", "sea", "wave", "beach", "aqua", "marine", "surf"]),
        .init(id: "sun.dust", keywords: ["haze", "dust", "hot", "dry", "arid"]),
        .init(id: "rainbow", keywords: ["rainbow", "color", "pride", "lgbtq", "weather", "spectrum"]),
        .init(id: "sunrise", keywords: ["sunrise", "morning", "dawn", "early", "daybreak"]),
        .init(id: "sunset", keywords: ["sunset", "evening", "dusk", "twilight", "golden hour"]),
        .init(id: "moon.haze", keywords: ["night", "foggy", "haze", "mysterious", "moody"]),
        .init(id: "fossil.shell", keywords: ["fossil", "shell", "nature", "ancient", "beach", "ocean"]),
        .init(id: "bird", keywords: ["bird", "nature", "animal", "fly", "tweet", "twitter"]),
        .init(id: "fish", keywords: ["fish", "ocean", "sea", "aquatic", "marine", "animal", "fishing"]),
        .init(id: "tortoise", keywords: ["turtle", "slow", "animal", "nature", "reptile"]),
        .init(id: "hare", keywords: ["rabbit", "fast", "speed", "animal", "bunny", "quick"]),
        .init(id: "cat", keywords: ["cat", "pet", "animal", "kitten", "feline"]),
        .init(id: "dog", keywords: ["dog", "pet", "animal", "puppy", "canine"]),
        .init(id: "ant", keywords: ["ant", "insect", "bug", "small", "colony"]),
        .init(id: "ladybug", keywords: ["ladybug", "insect", "bug", "nature", "lucky"]),
        .init(id: "pawprint", keywords: ["paw", "pet", "animal", "print", "track", "dog", "cat"]),
    ]

    // MARK: - Travel & Transport

    static let travel: [SFSymbolEntry] = [
        .init(id: "car", keywords: ["vehicle", "drive", "auto", "transport", "automobile", "ride", "commute", "road"]),
        .init(id: "car.side", keywords: ["vehicle", "car", "drive", "sedan", "automobile"]),
        .init(id: "suv.side", keywords: ["suv", "truck", "vehicle", "offroad", "utility"]),
        .init(id: "bus", keywords: ["transport", "public", "transit", "commute", "city", "route"]),
        .init(id: "bus.doubledecker", keywords: ["bus", "london", "transport", "city", "tour"]),
        .init(id: "tram", keywords: ["train", "transport", "rail", "transit", "subway", "metro", "commute"]),
        .init(id: "lightrail", keywords: ["train", "metro", "subway", "rail", "transit"]),
        .init(id: "cablecar", keywords: ["gondola", "ski", "mountain", "transport", "aerial"]),
        .init(id: "bicycle", keywords: ["bike", "cycle", "transport", "ride", "pedal", "cycling", "bmx"]),
        .init(id: "scooter", keywords: ["scooter", "kick", "transport", "ride", "electric"]),
        .init(id: "airplane", keywords: ["flight", "travel", "plane", "airport", "fly", "trip", "vacation", "jet"]),
        .init(id: "airplane.departure", keywords: ["takeoff", "departure", "flight", "leave", "travel"]),
        .init(id: "airplane.arrival", keywords: ["landing", "arrival", "flight", "arrive", "travel"]),
        .init(id: "ferry", keywords: ["boat", "ship", "water", "transport", "cruise", "sail", "marine"]),
        .init(id: "sailboat", keywords: ["boat", "sail", "yacht", "water", "ocean", "marine", "sailing"]),
        .init(id: "fuelpump", keywords: ["gas", "petrol", "fuel", "station", "refuel", "diesel", "energy"]),
        .init(id: "ev.charger", keywords: ["electric", "ev", "charge", "station", "plug", "green", "tesla"]),
        .init(id: "location", keywords: ["gps", "pin", "map", "navigate", "position", "current", "here", "tracker"]),
        .init(id: "location.slash", keywords: ["no location", "gps off", "privacy", "disabled"]),
        .init(id: "map", keywords: ["location", "navigate", "directions", "route", "atlas", "geography"]),
        .init(id: "mappin", keywords: ["location", "pin", "place", "marker", "spot", "destination", "poi"]),
        .init(id: "mappin.circle", keywords: ["location", "pin", "place", "marker", "destination"]),
        .init(id: "mappin.and.ellipse", keywords: ["location", "pin", "area", "zone", "radius"]),
        .init(id: "compass.drawing", keywords: ["compass", "navigate", "direction", "north", "explore"]),
        .init(id: "house", keywords: ["home", "building", "residence", "property", "dwelling", "address", "main"]),
        .init(id: "building.2", keywords: ["office", "city", "work", "commercial", "company", "urban", "downtown"]),
        .init(id: "building", keywords: ["office", "building", "work", "corporate", "business"]),
        .init(id: "tent", keywords: ["camping", "outdoor", "tent", "nature", "camp", "adventure"]),
        .init(id: "suitcase", keywords: ["travel", "luggage", "trip", "vacation", "bag", "packing"]),
        .init(id: "suitcase.rolling", keywords: ["travel", "luggage", "airport", "trip", "vacation"]),
        .init(id: "bed.double", keywords: ["sleep", "hotel", "room", "bed", "rest", "accommodation"]),
        .init(id: "figure.stairs", keywords: ["stairs", "climb", "steps", "floor", "up", "down"]),
        .init(id: "door.left.hand.open", keywords: ["door", "enter", "exit", "open", "entrance", "room"]),
        .init(id: "door.left.hand.closed", keywords: ["door", "closed", "locked", "room", "private"]),
        .init(id: "parkingsign", keywords: ["parking", "car", "lot", "garage", "spot"]),
        .init(id: "steeringwheel", keywords: ["drive", "car", "steering", "wheel", "control"]),
    ]

    // MARK: - Objects & Tools

    static let objects: [SFSymbolEntry] = [
        .init(id: "pencil", keywords: ["edit", "write", "draw", "compose", "note", "draft", "pen"]),
        .init(id: "pencil.circle", keywords: ["edit", "write", "draw", "modify", "update"]),
        .init(id: "pencil.and.outline", keywords: ["edit", "compose", "write", "draft", "annotate"]),
        .init(id: "highlighter", keywords: ["highlight", "mark", "annotate", "emphasize", "color"]),
        .init(id: "pencil.and.ruler", keywords: ["design", "draft", "blueprint", "architecture", "plan"]),
        .init(id: "trash", keywords: ["delete", "remove", "bin", "garbage", "discard", "recycle", "rubbish", "junk"]),
        .init(id: "trash.slash", keywords: ["cannot delete", "protected", "no delete", "keep"]),
        .init(id: "folder", keywords: ["file", "directory", "organize", "category", "group", "collection"]),
        .init(id: "folder.badge.plus", keywords: ["new folder", "add", "create", "organize"]),
        .init(id: "folder.badge.minus", keywords: ["remove folder", "delete", "organize"]),
        .init(id: "doc", keywords: ["document", "file", "page", "paper", "sheet"]),
        .init(id: "doc.text", keywords: ["document", "text", "file", "page", "readme", "content", "article"]),
        .init(id: "doc.on.doc", keywords: ["copy", "duplicate", "clipboard", "clone", "replicate"]),
        .init(id: "doc.badge.plus", keywords: ["new document", "create", "add", "file"]),
        .init(id: "doc.zipper", keywords: ["zip", "archive", "compress", "file", "package"]),
        .init(id: "doc.richtext", keywords: ["rich text", "document", "formatted", "word", "rtf"]),
        .init(id: "clipboard", keywords: ["paste", "copy", "notes", "checklist", "task", "todo"]),
        .init(id: "list.clipboard", keywords: ["checklist", "todo", "tasks", "list", "organize"]),
        .init(id: "paperclip", keywords: ["attach", "attachment", "file", "clip", "fasten", "document"]),
        .init(id: "scissors", keywords: ["cut", "trim", "snip", "crop", "clip"]),
        .init(id: "ruler", keywords: ["measure", "length", "size", "distance", "dimension"]),
        .init(id: "level", keywords: ["level", "balance", "straight", "align", "flat"]),
        .init(id: "book", keywords: ["read", "library", "education", "novel", "textbook", "story", "knowledge"]),
        .init(id: "book.closed", keywords: ["book", "closed", "read", "library", "reference"]),
        .init(id: "text.book.closed", keywords: ["textbook", "education", "study", "school", "manual"]),
        .init(id: "bookmark", keywords: ["save", "favorite", "read", "later", "mark", "remember"]),
        .init(id: "magazine", keywords: ["magazine", "publication", "read", "article", "news"]),
        .init(id: "newspaper", keywords: ["news", "article", "press", "headline", "media", "journal"]),
        .init(id: "calendar", keywords: ["date", "schedule", "event", "day", "month", "appointment", "planner"]),
        .init(id: "calendar.badge.plus", keywords: ["new event", "add", "schedule", "appointment", "create"]),
        .init(id: "calendar.badge.clock", keywords: ["schedule", "reminder", "event", "upcoming", "soon"]),
        .init(id: "clock", keywords: ["time", "schedule", "hour", "minute", "watch", "duration", "timer"]),
        .init(id: "alarm", keywords: ["time", "wake", "reminder", "clock", "morning", "alert", "snooze"]),
        .init(id: "timer", keywords: ["countdown", "stopwatch", "time", "duration", "interval", "cooking"]),
        .init(id: "hourglass", keywords: ["time", "wait", "loading", "patience", "sand", "timer", "pending"]),
        .init(id: "key", keywords: ["password", "lock", "security", "access", "credential", "secret", "passkey"]),
        .init(id: "lock", keywords: ["security", "password", "private", "encrypted", "protected", "closed", "secure"]),
        .init(id: "lock.open", keywords: ["unlock", "open", "access", "unsecure", "public"]),
        .init(id: "lock.shield", keywords: ["security", "protected", "shield", "safe", "encrypted"]),
        .init(id: "eye", keywords: ["view", "see", "visible", "show", "watch", "look", "preview", "display"]),
        .init(id: "eye.slash", keywords: ["hide", "invisible", "hidden", "private", "secret", "conceal"]),
        .init(id: "magnifyingglass", keywords: ["search", "find", "zoom", "lookup", "discover", "explore", "query"]),
        .init(id: "magnifyingglass.circle", keywords: ["search", "find", "zoom", "lookup"]),
        .init(id: "lightbulb", keywords: ["idea", "tip", "light", "inspiration", "insight", "suggestion", "innovation"]),
        .init(id: "lightbulb.max", keywords: ["bright idea", "eureka", "insight", "brilliant"]),
        .init(id: "wrench", keywords: ["tool", "settings", "fix", "repair", "maintain", "configure", "mechanic"]),
        .init(id: "wrench.and.screwdriver", keywords: ["tools", "settings", "repair", "fix", "maintain", "workshop"]),
        .init(id: "hammer", keywords: ["tool", "build", "construct", "develop", "create", "forge"]),
        .init(id: "screwdriver", keywords: ["tool", "fix", "repair", "screw", "assemble"]),
        .init(id: "gearshape", keywords: ["settings", "preferences", "config", "options", "setup", "cogwheel"]),
        .init(id: "gearshape.2", keywords: ["settings", "preferences", "advanced", "configuration", "system"]),
        .init(id: "slider.horizontal.3", keywords: ["settings", "adjust", "controls", "filter", "tune", "equalizer"]),
        .init(id: "slider.vertical.3", keywords: ["settings", "adjust", "controls", "mixer", "levels"]),
        .init(id: "paintbrush", keywords: ["art", "design", "draw", "paint", "color", "creative", "brush"]),
        .init(id: "paintbrush.pointed", keywords: ["art", "design", "paint", "fine art", "detail"]),
        .init(id: "paintpalette", keywords: ["art", "color", "design", "palette", "creative", "theme"]),
        .init(id: "eyedropper", keywords: ["color picker", "sample", "design", "color", "dropper"]),
        .init(id: "flag", keywords: ["report", "mark", "country", "nation", "flag", "signal", "priority"]),
        .init(id: "flag.checkered", keywords: ["finish", "race", "complete", "done", "goal"]),
        .init(id: "pin", keywords: ["pinned", "save", "mark", "location", "attach", "important", "stick"]),
        .init(id: "trophy", keywords: ["award", "prize", "winner", "champion", "achievement", "victory", "cup"]),
        .init(id: "medal", keywords: ["award", "achievement", "badge", "honor", "recognition"]),
        .init(id: "rosette", keywords: ["award", "badge", "ribbon", "prize", "certification"]),
        .init(id: "crown", keywords: ["king", "queen", "royal", "premium", "vip", "leader", "top"]),
        .init(id: "gift", keywords: ["present", "reward", "surprise", "birthday", "holiday", "wrap"]),
        .init(id: "lamp.desk", keywords: ["lamp", "desk", "light", "study", "reading", "work"]),
        .init(id: "lamp.table", keywords: ["lamp", "light", "home", "room", "cozy"]),
        .init(id: "flashlight.on.circle", keywords: ["flashlight", "light", "torch", "bright", "illuminate"]),
        .init(id: "binoculars", keywords: ["zoom", "look", "watch", "observe", "explore", "scout"]),
        .init(id: "scope", keywords: ["scope", "target", "aim", "focus", "crosshair"]),
        .init(id: "umbrella", keywords: ["rain", "weather", "protection", "shelter", "cover"]),
        .init(id: "briefcase", keywords: ["work", "business", "job", "professional", "career", "office"]),
        .init(id: "suitcase", keywords: ["travel", "luggage", "trip", "vacation", "pack"]),
        .init(id: "shippingbox", keywords: ["package", "delivery", "box", "shipping", "order", "parcel"]),
        .init(id: "archivebox", keywords: ["archive", "storage", "box", "file", "backup", "old"]),
        .init(id: "tray", keywords: ["inbox", "tray", "mail", "receive", "collect"]),
        .init(id: "tray.and.arrow.down", keywords: ["download", "inbox", "receive", "save"]),
        .init(id: "tray.and.arrow.up", keywords: ["upload", "outbox", "send", "export"]),
        .init(id: "cube", keywords: ["3d", "box", "package", "object", "model", "dimension"]),
        .init(id: "cube.transparent", keywords: ["3d", "transparent", "model", "wireframe", "augmented reality"]),
        .init(id: "puzzlepiece", keywords: ["puzzle", "plugin", "extension", "addon", "piece", "fit"]),
        .init(id: "lifepreserver", keywords: ["help", "rescue", "support", "safety", "lifeguard"]),
    ]

    // MARK: - Shapes & Symbols

    static let shapes: [SFSymbolEntry] = [
        .init(id: "star", keywords: ["favorite", "rating", "bookmark", "review", "rank", "important", "starred"]),
        .init(id: "star.leadinghalf.filled", keywords: ["half star", "rating", "review", "partial"]),
        .init(id: "circle", keywords: ["dot", "shape", "round", "ring", "orbit", "loop", "radio button"]),
        .init(id: "square", keywords: ["shape", "box", "rectangle", "container", "frame"]),
        .init(id: "square.on.square", keywords: ["copy", "overlap", "layer", "stack", "duplicate"]),
        .init(id: "app", keywords: ["app", "application", "rounded square", "icon"]),
        .init(id: "rectangle", keywords: ["shape", "box", "frame", "container", "card"]),
        .init(id: "rectangle.portrait", keywords: ["shape", "portrait", "vertical", "card"]),
        .init(id: "capsule", keywords: ["shape", "pill", "rounded", "button", "badge"]),
        .init(id: "oval", keywords: ["shape", "ellipse", "oval", "rounded"]),
        .init(id: "triangle", keywords: ["shape", "warning", "alert", "geometry", "pyramid"]),
        .init(id: "diamond", keywords: ["shape", "gem", "jewel", "precious", "rhombus"]),
        .init(id: "pentagon", keywords: ["shape", "five", "polygon", "geometry"]),
        .init(id: "hexagon", keywords: ["shape", "six", "polygon", "geometry", "honeycomb", "hive"]),
        .init(id: "octagon", keywords: ["shape", "eight", "stop sign", "polygon"]),
        .init(id: "seal", keywords: ["badge", "stamp", "certification", "verified", "approved"]),
        .init(id: "shield", keywords: ["security", "protect", "safe", "guard", "defense", "armor"]),
        .init(id: "shield.checkered", keywords: ["security", "verified", "safe", "checked", "approved"]),
        .init(id: "checkmark", keywords: ["done", "complete", "yes", "success", "confirm", "accept", "tick", "correct"]),
        .init(id: "checkmark.circle", keywords: ["done", "complete", "success", "approved", "verified"]),
        .init(id: "checkmark.seal", keywords: ["verified", "certified", "approved", "authentic", "official"]),
        .init(id: "xmark", keywords: ["close", "cancel", "no", "delete", "remove", "wrong", "reject", "error"]),
        .init(id: "xmark.circle", keywords: ["close", "cancel", "remove", "error", "failed"]),
        .init(id: "exclamationmark.triangle", keywords: ["warning", "alert", "caution", "danger", "attention", "important"]),
        .init(id: "exclamationmark.circle", keywords: ["warning", "error", "alert", "important", "attention"]),
        .init(id: "info.circle", keywords: ["information", "about", "details", "help", "tooltip", "hint"]),
        .init(id: "questionmark.circle", keywords: ["help", "question", "support", "faq", "unknown", "ask"]),
        .init(id: "questionmark.diamond", keywords: ["unknown", "question", "help", "mystery"]),
        .init(id: "plus.circle", keywords: ["add", "new", "create", "insert", "increase", "more"]),
        .init(id: "minus.circle", keywords: ["remove", "subtract", "less", "decrease", "reduce"]),
        .init(id: "plus", keywords: ["add", "new", "create", "insert", "positive"]),
        .init(id: "minus", keywords: ["remove", "subtract", "delete", "negative"]),
        .init(id: "multiply", keywords: ["close", "cancel", "times", "cross"]),
        .init(id: "divide", keywords: ["divide", "split", "fraction", "math"]),
        .init(id: "equal", keywords: ["equal", "same", "match", "compare"]),
        .init(id: "lessthan", keywords: ["less", "smaller", "before", "compare"]),
        .init(id: "greaterthan", keywords: ["greater", "more", "after", "compare"]),
        .init(id: "infinity", keywords: ["infinite", "forever", "unlimited", "loop", "endless"]),
        .init(id: "circle.grid.2x2", keywords: ["grid", "layout", "menu", "apps", "dashboard", "widget"]),
        .init(id: "circle.grid.3x3", keywords: ["grid", "layout", "matrix", "apps", "more"]),
        .init(id: "square.grid.2x2", keywords: ["grid", "layout", "gallery", "dashboard", "collection"]),
        .init(id: "square.grid.3x3", keywords: ["grid", "layout", "matrix", "keypad", "numpad"]),
        .init(id: "rectangle.grid.1x2", keywords: ["layout", "list", "cards", "stack"]),
        .init(id: "rectangle.grid.2x2", keywords: ["layout", "grid", "cards", "gallery"]),
        .init(id: "aspectratio", keywords: ["ratio", "resize", "scale", "proportion", "dimension"]),
    ]

    // MARK: - Text & Formatting

    static let text: [SFSymbolEntry] = [
        .init(id: "textformat", keywords: ["font", "type", "text", "format", "style", "typography"]),
        .init(id: "textformat.size", keywords: ["font size", "text size", "scale", "large", "small"]),
        .init(id: "bold", keywords: ["text", "format", "strong", "emphasis", "heavy", "weight"]),
        .init(id: "italic", keywords: ["text", "format", "slant", "emphasis", "oblique"]),
        .init(id: "underline", keywords: ["text", "format", "underline", "emphasis"]),
        .init(id: "strikethrough", keywords: ["text", "format", "delete", "cross out", "removed"]),
        .init(id: "text.alignleft", keywords: ["align", "left", "text", "format", "justify"]),
        .init(id: "text.aligncenter", keywords: ["align", "center", "text", "format", "middle"]),
        .init(id: "text.alignright", keywords: ["align", "right", "text", "format"]),
        .init(id: "text.justify", keywords: ["justify", "align", "text", "format", "full"]),
        .init(id: "list.bullet", keywords: ["list", "menu", "items", "bullet", "unordered", "navigation"]),
        .init(id: "list.number", keywords: ["list", "ordered", "numbered", "sequence", "steps"]),
        .init(id: "list.dash", keywords: ["list", "items", "dash", "menu"]),
        .init(id: "checklist", keywords: ["todo", "tasks", "checklist", "done", "checkbox", "complete"]),
        .init(id: "checklist.unchecked", keywords: ["todo", "tasks", "unchecked", "pending", "incomplete"]),
        .init(id: "text.bubble", keywords: ["message", "chat", "text", "sms", "comment", "speech"]),
        .init(id: "quote.opening", keywords: ["quote", "citation", "text", "blockquote", "reference"]),
        .init(id: "quote.closing", keywords: ["quote", "citation", "text", "blockquote", "reference"]),
        .init(id: "number", keywords: ["hash", "hashtag", "pound", "sharp", "number sign", "channel"]),
        .init(id: "at", keywords: ["email", "mention", "address", "username", "handle", "social"]),
        .init(id: "textformat.abc", keywords: ["spell check", "abc", "text", "language", "words"]),
        .init(id: "character.cursor.ibeam", keywords: ["cursor", "text", "type", "input", "caret"]),
        .init(id: "paragraphsign", keywords: ["paragraph", "text", "format", "section"]),
        .init(id: "text.word.spacing", keywords: ["spacing", "kerning", "text", "gap", "letter spacing"]),
        .init(id: "a.magnify", keywords: ["font", "text", "zoom", "accessibility", "large text"]),
        .init(id: "abc", keywords: ["text", "spell", "letters", "alphabet", "language"]),
        .init(id: "textformat.123", keywords: ["numbers", "digits", "numeric", "input"]),
        .init(id: "globe.badge.chevron.backward", keywords: ["language", "translate", "locale", "international", "i18n"]),
        .init(id: "character.bubble", keywords: ["language", "translate", "text", "foreign", "character"]),
    ]

    // MARK: - Arrows & Navigation

    static let arrows: [SFSymbolEntry] = [
        .init(id: "arrow.up", keywords: ["up", "upload", "direction", "increase", "top", "rise"]),
        .init(id: "arrow.down", keywords: ["down", "download", "direction", "decrease", "bottom", "drop"]),
        .init(id: "arrow.left", keywords: ["back", "previous", "direction", "left", "return", "west"]),
        .init(id: "arrow.right", keywords: ["forward", "next", "direction", "right", "continue", "east"]),
        .init(id: "arrow.up.left", keywords: ["diagonal", "up left", "direction", "northwest"]),
        .init(id: "arrow.up.right", keywords: ["diagonal", "up right", "direction", "northeast", "external"]),
        .init(id: "arrow.down.left", keywords: ["diagonal", "down left", "direction", "southwest"]),
        .init(id: "arrow.down.right", keywords: ["diagonal", "down right", "direction", "southeast"]),
        .init(id: "arrow.up.arrow.down", keywords: ["sort", "swap", "exchange", "reorder", "toggle"]),
        .init(id: "arrow.left.arrow.right", keywords: ["swap", "exchange", "switch", "horizontal", "transfer"]),
        .init(id: "arrow.turn.down.left", keywords: ["reply", "return", "back", "respond"]),
        .init(id: "arrow.turn.down.right", keywords: ["forward", "redirect", "route"]),
        .init(id: "arrow.clockwise", keywords: ["refresh", "reload", "rotate", "clockwise", "spin"]),
        .init(id: "arrow.counterclockwise", keywords: ["undo", "refresh", "rotate", "counterclockwise", "revert"]),
        .init(id: "arrow.uturn.backward", keywords: ["undo", "back", "return", "revert", "previous"]),
        .init(id: "arrow.uturn.forward", keywords: ["redo", "forward", "repeat", "again"]),
        .init(id: "arrow.2.squarepath", keywords: ["loop", "cycle", "repeat", "workflow", "process"]),
        .init(id: "arrow.3.trianglepath", keywords: ["recycle", "loop", "cycle", "process", "flow"]),
        .init(id: "square.and.arrow.up", keywords: ["share", "export", "upload", "send", "distribute"]),
        .init(id: "square.and.arrow.down", keywords: ["download", "save", "import", "receive", "get"]),
        .init(id: "arrow.down.circle", keywords: ["download", "save", "get", "receive"]),
        .init(id: "arrow.up.circle", keywords: ["upload", "send", "push", "publish"]),
        .init(id: "arrow.triangle.2.circlepath", keywords: ["sync", "refresh", "update", "synchronize", "cycle"]),
        .init(id: "arrow.triangle.branch", keywords: ["branch", "fork", "split", "diverge", "git"]),
        .init(id: "arrow.triangle.merge", keywords: ["merge", "combine", "join", "converge", "git"]),
        .init(id: "arrow.triangle.pull", keywords: ["pull", "fetch", "get", "download", "git"]),
        .init(id: "chevron.left", keywords: ["back", "previous", "left", "navigate", "collapse"]),
        .init(id: "chevron.right", keywords: ["next", "forward", "right", "navigate", "expand", "detail"]),
        .init(id: "chevron.up", keywords: ["up", "expand", "collapse", "open"]),
        .init(id: "chevron.down", keywords: ["down", "expand", "dropdown", "open", "more"]),
        .init(id: "chevron.left.2", keywords: ["rewind", "fast back", "skip back", "first"]),
        .init(id: "chevron.right.2", keywords: ["fast forward", "skip", "next", "last"]),
        .init(id: "chevron.up.chevron.down", keywords: ["sort", "stepper", "up down", "select"]),
        .init(id: "arrow.up.and.down.and.arrow.left.and.right", keywords: ["move", "drag", "reposition", "all directions"]),
        .init(id: "arrow.left.and.right", keywords: ["horizontal", "resize", "width", "expand"]),
        .init(id: "arrow.up.and.down", keywords: ["vertical", "resize", "height", "expand"]),
        .init(id: "arrow.up.left.and.arrow.down.right", keywords: ["expand", "fullscreen", "maximize", "enlarge"]),
        .init(id: "arrow.down.to.line", keywords: ["download", "bottom", "end", "dock"]),
        .init(id: "arrow.up.to.line", keywords: ["upload", "top", "start", "undock"]),
    ]

    // MARK: - Indices & Numbers

    static let indices: [SFSymbolEntry] = [
        .init(id: "1.circle", keywords: ["one", "first", "number", "1", "step", "count"]),
        .init(id: "2.circle", keywords: ["two", "second", "number", "2", "step", "count"]),
        .init(id: "3.circle", keywords: ["three", "third", "number", "3", "step", "count"]),
        .init(id: "4.circle", keywords: ["four", "fourth", "number", "4", "step", "count"]),
        .init(id: "5.circle", keywords: ["five", "fifth", "number", "5", "step", "count"]),
        .init(id: "6.circle", keywords: ["six", "sixth", "number", "6", "step", "count"]),
        .init(id: "7.circle", keywords: ["seven", "seventh", "number", "7", "step", "count"]),
        .init(id: "8.circle", keywords: ["eight", "eighth", "number", "8", "step", "count"]),
        .init(id: "9.circle", keywords: ["nine", "ninth", "number", "9", "step", "count"]),
        .init(id: "0.circle", keywords: ["zero", "number", "0", "null", "none"]),
        .init(id: "a.circle", keywords: ["letter", "alpha", "a", "grade", "first"]),
        .init(id: "b.circle", keywords: ["letter", "bravo", "b", "grade", "second"]),
        .init(id: "c.circle", keywords: ["letter", "charlie", "c", "grade", "third"]),
        .init(id: "d.circle", keywords: ["letter", "delta", "d", "grade"]),
        .init(id: "e.circle", keywords: ["letter", "echo", "e"]),
        .init(id: "f.circle", keywords: ["letter", "foxtrot", "f", "grade", "fail"]),
        .init(id: "g.circle", keywords: ["letter", "golf", "g"]),
        .init(id: "h.circle", keywords: ["letter", "hotel", "h"]),
        .init(id: "i.circle", keywords: ["letter", "india", "i", "information"]),
        .init(id: "j.circle", keywords: ["letter", "juliet", "j"]),
        .init(id: "k.circle", keywords: ["letter", "kilo", "k"]),
        .init(id: "l.circle", keywords: ["letter", "lima", "l"]),
        .init(id: "m.circle", keywords: ["letter", "mike", "m"]),
        .init(id: "n.circle", keywords: ["letter", "november", "n"]),
        .init(id: "o.circle", keywords: ["letter", "oscar", "o"]),
        .init(id: "p.circle", keywords: ["letter", "papa", "p"]),
        .init(id: "q.circle", keywords: ["letter", "quebec", "q"]),
        .init(id: "r.circle", keywords: ["letter", "romeo", "r"]),
        .init(id: "s.circle", keywords: ["letter", "sierra", "s"]),
        .init(id: "t.circle", keywords: ["letter", "tango", "t"]),
        .init(id: "u.circle", keywords: ["letter", "uniform", "u"]),
        .init(id: "v.circle", keywords: ["letter", "victor", "v"]),
        .init(id: "w.circle", keywords: ["letter", "whiskey", "w"]),
        .init(id: "x.circle", keywords: ["letter", "xray", "x"]),
        .init(id: "y.circle", keywords: ["letter", "yankee", "y"]),
        .init(id: "z.circle", keywords: ["letter", "zulu", "z"]),
    ]

    // MARK: - Food & Drink

    static let food: [SFSymbolEntry] = [
        .init(id: "cup.and.saucer", keywords: ["coffee", "tea", "cup", "drink", "cafe", "hot", "beverage"]),
        .init(id: "mug", keywords: ["mug", "coffee", "tea", "drink", "hot", "beverage", "cup"]),
        .init(id: "takeoutbag.and.cup.and.straw", keywords: ["takeout", "fast food", "order", "delivery", "restaurant"]),
        .init(id: "wineglass", keywords: ["wine", "drink", "alcohol", "glass", "bar", "cheers"]),
        .init(id: "waterbottle", keywords: ["water", "bottle", "drink", "hydrate", "fitness"]),
        .init(id: "fork.knife", keywords: ["food", "restaurant", "eat", "dining", "meal", "lunch", "dinner"]),
        .init(id: "fork.knife.circle", keywords: ["food", "restaurant", "eat", "dining", "meal"]),
        .init(id: "birthday.cake", keywords: ["cake", "birthday", "celebration", "party", "candle"]),
        .init(id: "carrot", keywords: ["carrot", "vegetable", "food", "healthy", "vegan"]),
        .init(id: "frying.pan", keywords: ["cook", "pan", "kitchen", "fry", "chef"]),
        .init(id: "oven", keywords: ["oven", "bake", "cook", "kitchen", "heat"]),
        .init(id: "refrigerator", keywords: ["fridge", "cold", "food", "kitchen", "storage"]),
        .init(id: "popcorn", keywords: ["popcorn", "movie", "snack", "cinema", "theater"]),
    ]

    // MARK: - Science & Education

    static let science: [SFSymbolEntry] = [
        .init(id: "atom", keywords: ["atom", "science", "physics", "molecule", "chemistry", "nuclear"]),
        .init(id: "graduationcap", keywords: ["education", "school", "graduate", "university", "degree", "student", "study"]),
        .init(id: "backpack", keywords: ["school", "bag", "student", "education", "carry"]),
        .init(id: "book.and.wrench", keywords: ["manual", "documentation", "guide", "reference", "developer"]),
        .init(id: "flask", keywords: ["science", "chemistry", "lab", "experiment", "research"]),
        .init(id: "testtube.2", keywords: ["science", "test", "lab", "experiment", "research", "chemistry"]),
        .init(id: "function", keywords: ["math", "function", "code", "formula", "programming"]),
        .init(id: "sum", keywords: ["math", "sum", "total", "add", "sigma", "calculate"]),
        .init(id: "x.squareroot", keywords: ["math", "square root", "formula", "equation", "calculate"]),
        .init(id: "number.circle", keywords: ["math", "number", "digit", "count"]),
        .init(id: "studentdesk", keywords: ["school", "desk", "study", "classroom", "student"]),
        .init(id: "globe.desk", keywords: ["geography", "world", "globe", "education", "earth"]),
        .init(id: "chart.xyaxis.line", keywords: ["graph", "chart", "data", "plot", "statistics", "math"]),
        .init(id: "angle", keywords: ["angle", "geometry", "math", "degree", "measure"]),
    ]

    // MARK: - Gaming & Entertainment

    static let gaming: [SFSymbolEntry] = [
        .init(id: "dice", keywords: ["dice", "game", "random", "chance", "roll", "gambling"]),
        .init(id: "die.face.1", keywords: ["dice", "one", "game", "roll"]),
        .init(id: "die.face.2", keywords: ["dice", "two", "game", "roll"]),
        .init(id: "die.face.3", keywords: ["dice", "three", "game", "roll"]),
        .init(id: "die.face.4", keywords: ["dice", "four", "game", "roll"]),
        .init(id: "die.face.5", keywords: ["dice", "five", "game", "roll"]),
        .init(id: "die.face.6", keywords: ["dice", "six", "game", "roll"]),
        .init(id: "puzzlepiece.extension", keywords: ["puzzle", "plugin", "extension", "game", "addon"]),
        .init(id: "trophy", keywords: ["award", "prize", "winner", "champion", "achievement", "victory"]),
        .init(id: "medal", keywords: ["award", "achievement", "badge", "honor", "recognition"]),
        .init(id: "flag.checkered.2.crossed", keywords: ["race", "finish", "competition", "checkered", "win"]),
        .init(id: "theatermasks", keywords: ["theater", "drama", "comedy", "acting", "performance", "mask"]),
        .init(id: "party.popper", keywords: ["celebrate", "party", "confetti", "fun", "birthday", "hooray"]),
        .init(id: "balloon", keywords: ["balloon", "party", "celebration", "fun", "birthday"]),
        .init(id: "balloon.2", keywords: ["balloons", "party", "celebration", "fun", "birthday"]),
        .init(id: "hands.sparkles", keywords: ["celebration", "clean", "sanitize", "magic", "jazz hands"]),
        .init(id: "wand.and.stars", keywords: ["magic", "wizard", "transform", "effect", "filter"]),
        .init(id: "sparkle", keywords: ["magic", "new", "highlight", "premium", "special"]),
    ]

    // MARK: - Privacy & Security

    static let privacy: [SFSymbolEntry] = [
        .init(id: "faceid", keywords: ["face id", "biometric", "unlock", "authentication", "security", "face"]),
        .init(id: "touchid", keywords: ["touch id", "fingerprint", "biometric", "unlock", "authentication"]),
        .init(id: "opticid", keywords: ["optic id", "iris", "biometric", "unlock", "authentication"]),
        .init(id: "hand.raised.slash", keywords: ["tracking", "privacy", "no tracking", "block", "prevent"]),
        .init(id: "eye.trianglebadge.exclamationmark", keywords: ["privacy", "warning", "surveillance", "watching"]),
        .init(id: "lock.trianglebadge.exclamationmark", keywords: ["security warning", "breach", "compromised"]),
        .init(id: "shield.lefthalf.filled", keywords: ["security", "protection", "half", "partial"]),
        .init(id: "shield.checkered", keywords: ["security", "verified", "safe", "approved"]),
        .init(id: "key.horizontal", keywords: ["key", "password", "passkey", "credential", "authentication"]),
        .init(id: "lock.rectangle", keywords: ["screen lock", "device lock", "security", "locked"]),
        .init(id: "lock.iphone", keywords: ["phone lock", "device lock", "security", "locked"]),
        .init(id: "person.badge.shield.checkmark", keywords: ["verified", "trusted", "secure", "identity"]),
    ]

    // MARK: - Accessibility

    static let accessibility: [SFSymbolEntry] = [
        .init(id: "accessibility", keywords: ["accessibility", "a11y", "disability", "inclusive", "universal"]),
        .init(id: "figure.roll", keywords: ["wheelchair", "accessibility", "disability", "mobility"]),
        .init(id: "ear.badge.checkmark", keywords: ["hearing", "accessible", "hearing aid", "deaf"]),
        .init(id: "hand.point.up.braille", keywords: ["braille", "blind", "accessibility", "touch", "read"]),
        .init(id: "eye.slash", keywords: ["blind", "vision", "hidden", "invisible", "accessibility"]),
        .init(id: "character.magnify", keywords: ["zoom", "large text", "accessibility", "magnify"]),
        .init(id: "textformat.size.larger", keywords: ["larger text", "accessibility", "zoom", "big"]),
        .init(id: "textformat.size.smaller", keywords: ["smaller text", "accessibility", "reduce"]),
    ]

    // MARK: - Editing & Actions

    static let editing: [SFSymbolEntry] = [
        .init(id: "square.and.pencil", keywords: ["compose", "write", "edit", "new", "create", "draft"]),
        .init(id: "rectangle.and.pencil.and.ellipsis", keywords: ["edit", "compose", "draft", "write"]),
        .init(id: "scribble.variable", keywords: ["scribble", "handwriting", "draw", "freeform", "sketch"]),
        .init(id: "lasso", keywords: ["select", "lasso", "crop", "outline", "freeform"]),
        .init(id: "crop", keywords: ["crop", "trim", "cut", "resize", "photo edit"]),
        .init(id: "crop.rotate", keywords: ["crop", "rotate", "edit", "photo", "adjust"]),
        .init(id: "wand.and.rays", keywords: ["auto enhance", "magic", "fix", "improve", "adjust"]),
        .init(id: "slider.horizontal.below.rectangle", keywords: ["adjust", "edit", "controls", "settings"]),
        .init(id: "rectangle.2.swap", keywords: ["swap", "switch", "exchange", "compare"]),
        .init(id: "arrow.up.and.down.and.sparkles", keywords: ["sort", "filter", "smart", "organize"]),
        .init(id: "line.3.horizontal.decrease", keywords: ["filter", "sort", "funnel", "narrow", "refine"]),
        .init(id: "line.3.horizontal.decrease.circle", keywords: ["filter", "sort", "funnel", "refine"]),
        .init(id: "ellipsis", keywords: ["more", "menu", "options", "dots", "overflow", "additional"]),
        .init(id: "ellipsis.circle", keywords: ["more", "menu", "options", "actions"]),
        .init(id: "ellipsis.vertical.bubble", keywords: ["more", "menu", "options", "contextual"]),
        .init(id: "filemenu.and.selection", keywords: ["menu", "select", "dropdown", "options", "list"]),
        .init(id: "contextualmenu.and.cursorarrow", keywords: ["context menu", "right click", "options"]),
        .init(id: "sidebar.left", keywords: ["sidebar", "panel", "navigation", "layout"]),
        .init(id: "sidebar.right", keywords: ["sidebar", "panel", "detail", "layout"]),
        .init(id: "rectangle.split.3x1", keywords: ["columns", "layout", "split", "divide"]),
        .init(id: "rectangle.split.2x1", keywords: ["split", "layout", "divide", "columns"]),
    ]

    // MARK: - Math & Logic

    static let math: [SFSymbolEntry] = [
        .init(id: "plus.forwardslash.minus", keywords: ["plus minus", "math", "positive negative", "toggle"]),
        .init(id: "curlybraces", keywords: ["code", "json", "programming", "braces", "developer", "bracket"]),
        .init(id: "chevron.left.forwardslash.chevron.right", keywords: ["code", "html", "programming", "tag", "developer", "markup"]),
        .init(id: "terminal", keywords: ["terminal", "console", "command line", "cli", "shell", "code", "developer"]),
        .init(id: "apple.terminal", keywords: ["terminal", "mac", "command line", "shell", "developer"]),
        .init(id: "hammer.circle", keywords: ["build", "compile", "xcode", "developer", "construct"]),
        .init(id: "wrench.adjustable", keywords: ["tool", "fix", "adjust", "configure", "settings"]),
        .init(id: "ladybug", keywords: ["bug", "debug", "error", "issue", "fix", "developer"]),
        .init(id: "ant", keywords: ["bug", "insect", "debug", "crawl", "small"]),
        .init(id: "swift", keywords: ["swift", "programming", "apple", "language", "code", "ios"]),
        .init(id: "applescript", keywords: ["script", "automation", "code", "macro", "apple"]),
        .init(id: "externaldrive.connected.to.line.below", keywords: ["database", "storage", "data", "server", "disk"]),
        .init(id: "cylinder", keywords: ["database", "storage", "data", "container", "disk"]),
        .init(id: "cylinder.split.1x2", keywords: ["database", "table", "data", "rows"]),
        .init(id: "point.3.connected.trianglepath.dotted", keywords: ["network", "graph", "nodes", "connection", "mesh"]),
        .init(id: "app.connected.to.app.below.fill", keywords: ["api", "integration", "connected", "workflow"]),
    ]
}
