# custom_product_pages.rb — create or update Cutling's custom product pages.
#
# Usage: ruby fastlane/custom_product_pages.rb docs/aso/cpp.json [--readback]
#
# cpp.json: {"pages": [{"name", "deepLink", "keywords": {"<locale>": ["term", ...]},
#            "locales": {"<locale>": {"promo", "screenshots": {"APP_IPHONE_67": [paths], ...}}}}]}
#
# Idempotent: finds pages by name, edits the version still in
# PREPARE_FOR_SUBMISSION, replaces screenshot sets. Never submits for review.
# Calls follow docs/aso/custom-product-pages.md ("API recipe").

require 'spaceship'
require 'json'
require 'digest'
$stdout.sync = true

APP_ID = "6759476314"
cfg = JSON.parse(File.read(File.join(__dir__, "asc_api_key.json")))
Spaceship::ConnectAPI.auth(key_id: cfg["key_id"], issuer_id: cfg["issuer_id"], key: cfg["key"])
C = Spaceship::ConnectAPI.tunes_request_client

def data(resp) = resp.body["data"]

def all(path, params = {})
  out = []
  resp = C.get(path, params)
  loop do
    out.concat(resp.body["data"] || [])
    nxt = resp.body.dig("links", "next")
    break unless nxt
    resp = C.get(nxt.sub(%r{^https://api.appstoreconnect.apple.com/}, ""))
  end
  out
end

def post(type, attributes, relationships)
  data(C.post("v1/#{type}", { data: { type: type, attributes: attributes, relationships: relationships } }))
end

def rel(type, id) = { data: { type: type, id: id } }

def upload_set(loc_id, display_type, paths)
  existing = all("v1/appCustomProductPageLocalizations/#{loc_id}/appScreenshotSets")
  set = existing.find { |s| s.dig("attributes", "screenshotDisplayType") == display_type }
  if set
    all("v1/appScreenshotSets/#{set['id']}/appScreenshots").each { |s| C.delete("v1/appScreenshots/#{s['id']}") }
  else
    set = post("appScreenshotSets", { screenshotDisplayType: display_type },
               { appCustomProductPageLocalization: rel("appCustomProductPageLocalizations", loc_id) })
  end
  paths.each do |path|
    Spaceship::ConnectAPI::AppScreenshot.create(app_screenshot_set_id: set["id"], path: path, wait_for_processing: false)
  end
  # Order as given
  ids = all("v1/appScreenshotSets/#{set['id']}/appScreenshots").map { |s| s["id"] }
  C.patch("v1/appScreenshotSets/#{set['id']}/relationships/appScreenshots",
          { data: ids.map { |id| { type: "appScreenshots", id: id } } }) if ids.size == paths.size
  ids.size
end

def keyword_ids(locale, terms)
  @kw ||= {}
  @kw[locale] ||= all("v1/apps/#{APP_ID}/searchKeywords", { "filter[locale]" => locale, "filter[platform]" => "IOS", "limit" => 200 })
  # Ids are the approved version's keyword terms themselves
  @kw[locale].map { |k| k["id"] } & terms
rescue => e
  warn "keywords #{locale}: #{e.message}"
  []
end

def readback
  all("v1/apps/#{APP_ID}/appCustomProductPages").each do |page|
    a = page["attributes"]
    puts "PAGE #{a['name']} visible=#{a['visible']} url=#{a['url']}"
    all("v1/appCustomProductPages/#{page['id']}/appCustomProductPageVersions").each do |v|
      puts "  version state=#{v.dig('attributes', 'state')} deepLink=#{v.dig('attributes', 'deepLink')}"
      all("v1/appCustomProductPageVersions/#{v['id']}/appCustomProductPageLocalizations").each do |l|
        sets = all("v1/appCustomProductPageLocalizations/#{l['id']}/appScreenshotSets")
        counts = sets.map { |s| "#{s.dig('attributes', 'screenshotDisplayType')}=#{all("v1/appScreenshotSets/#{s['id']}/appScreenshots").size}" }
        kws = (all("v1/appCustomProductPageLocalizations/#{l['id']}/searchKeywords") rescue []).size
        puts "    #{l.dig('attributes', 'locale')} promo=#{(l.dig('attributes', 'promotionalText') || '').size}ch keywords=#{kws} #{counts.join(' ')}"
      end
    end
  end
end

if ARGV.include?("--readback")
  readback
  exit
end

spec = JSON.parse(File.read(ARGV[0], encoding: "UTF-8"))
pages = all("v1/apps/#{APP_ID}/appCustomProductPages")

spec["pages"].each do |p|
  page = pages.find { |x| x.dig("attributes", "name") == p["name"] }
  unless page
    # A page is created together with its first version and one localization
    first = p["locales"].keys.first
    body = {
      data: { type: "appCustomProductPages", attributes: { name: p["name"] },
              relationships: { app: rel("apps", APP_ID),
                               appCustomProductPageVersions: { data: [{ type: "appCustomProductPageVersions", id: "${v1}" }] } } },
      included: [
        { type: "appCustomProductPageVersions", id: "${v1}", attributes: { deepLink: p["deepLink"] },
          relationships: { appCustomProductPageLocalizations: { data: [{ type: "appCustomProductPageLocalizations", id: "${l1}" }] } } },
        { type: "appCustomProductPageLocalizations", id: "${l1}",
          attributes: { locale: first, promotionalText: p["locales"][first]["promo"] } }
      ]
    }
    page = data(C.post("v1/appCustomProductPages", body))
  end
  puts "page #{p['name']} #{page['id']}"

  versions = all("v1/appCustomProductPages/#{page['id']}/appCustomProductPageVersions")
  version = versions.find { |v| v.dig("attributes", "state") == "PREPARE_FOR_SUBMISSION" }
  version ||= post("appCustomProductPageVersions", { deepLink: p["deepLink"] },
                   { appCustomProductPage: rel("appCustomProductPages", page["id"]) })
  C.patch("v1/appCustomProductPageVersions/#{version['id']}",
          { data: { type: "appCustomProductPageVersions", id: version["id"], attributes: { deepLink: p["deepLink"] } } })

  locs = all("v1/appCustomProductPageVersions/#{version['id']}/appCustomProductPageLocalizations")
  only = ENV["CPP_LOCALES"]&.split(",")
  p["locales"].each do |locale, l|
    next if only && !only.include?(locale)
    loc = locs.find { |x| x.dig("attributes", "locale") == locale }
    if loc
      C.patch("v1/appCustomProductPageLocalizations/#{loc['id']}",
              { data: { type: "appCustomProductPageLocalizations", id: loc["id"], attributes: { promotionalText: l["promo"] } } })
    else
      loc = post("appCustomProductPageLocalizations", { locale: locale, promotionalText: l["promo"] },
                 { appCustomProductPageVersion: rel("appCustomProductPageVersions", version["id"]) })
    end
    shots = (l["screenshots"] || {}).map { |type, paths| "#{type}=#{upload_set(loc['id'], type, paths)}" }
    terms = (p["keywords"] || {})[locale] || []
    linked = 0
    ids = terms.empty? ? [] : keyword_ids(locale, terms)
    unless ids.empty?
      begin
        C.post("v1/appCustomProductPageLocalizations/#{loc['id']}/relationships/searchKeywords",
               { data: ids.map { |id| { type: "appKeywords", id: id } } })
        linked = ids.size
      rescue => e
        warn "  #{locale} keywords: #{e.message}"
      end
    end
    puts "  #{locale} #{shots.join(' ')} keywords=#{linked}/#{terms.size}"
  rescue => e
    warn "  #{locale} FAILED: #{e.message}"
  end
end
