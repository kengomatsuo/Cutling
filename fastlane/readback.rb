# readback.rb — prints what App Store Connect holds for the editable versions.
#
# Usage: ruby fastlane/readback.rb > docs/aso/readback-<date>.md
# Names and subtitles live on the app-info record; keywords, promo, notes and
# screenshots on each platform's version; custom product pages on their own.

require 'spaceship'
require 'json'

cfg = JSON.parse(File.read(File.join(__dir__, "asc_api_key.json")))
Spaceship::ConnectAPI.auth(key_id: cfg["key_id"], issuer_id: cfg["issuer_id"], key: cfg["key"])
app = Spaceship::ConnectAPI::App.find("com.matsuokengo.Cutling")

def cell(text) = (text || "").gsub("|", "\\|").gsub("\n", " ")

puts "# App Store Connect read-back, #{Time.now.utc.strftime('%Y-%m-%d %H:%M UTC')}", ""

info = app.fetch_edit_app_info
puts "## App information (#{info.app_store_state}), shared by iOS and macOS", ""
puts "| Locale | Name | Subtitle |", "|---|---|---|"
info.get_app_info_localizations.sort_by(&:locale).each do |l|
  puts "| #{l.locale} | #{cell(l.name)} | #{cell(l.subtitle)} |"
end

{ "IOS" => "iOS", "MAC_OS" => "macOS" }.each do |platform, label|
  live = app.get_app_store_versions(filter: { platform: platform }).find { |v| v.app_store_state == "READY_FOR_SALE" }
  v = app.get_edit_app_store_version(platform: platform)
  puts "", "## #{label} #{v.version_string} (#{v.app_store_state}); on sale: #{live&.version_string}", ""
  puts "| Locale | Keywords (bytes) | Promo (chars) | What's New | Screenshot sets |", "|---|---|---|---|---|"
  v.get_app_store_version_localizations.sort_by(&:locale).each do |l|
    sets = l.get_app_screenshot_sets.map { |s| "#{s.screenshot_display_type.sub('APP_', '')}=#{s.app_screenshots.to_a.size}" }
    kw = l.keywords || ""
    puts "| #{l.locale} | #{cell(kw)} (#{kw.bytesize}) | #{(l.promotional_text || '').size} | #{cell(l.whats_new)} | #{sets.join(' ')} |"
  end
end

c = Spaceship::ConnectAPI.tunes_request_client
puts "", "## Custom product pages", ""
c.get("v1/apps/#{app.id}/appCustomProductPages").body["data"].each do |page|
  a = page["attributes"]
  puts "### #{a['name']}", "", "URL: #{a['url']}", ""
  c.get("v1/appCustomProductPages/#{page['id']}/appCustomProductPageVersions").body["data"].each do |ver|
    puts "Version state: #{ver.dig('attributes', 'state')}; deep link: #{ver.dig('attributes', 'deepLink')}", ""
    puts "| Locale | Promo (chars) | Keywords | Screenshot sets |", "|---|---|---|---|"
    locs = []
    resp = c.get("v1/appCustomProductPageVersions/#{ver['id']}/appCustomProductPageLocalizations", { "limit" => 200 })
    locs.concat(resp.body["data"])
    locs.sort_by { |l| l.dig("attributes", "locale") }.each do |l|
      kws = c.get("v1/appCustomProductPageLocalizations/#{l['id']}/searchKeywords").body["data"].map { |k| k["id"] }
      sets = c.get("v1/appCustomProductPageLocalizations/#{l['id']}/appScreenshotSets").body["data"].map do |s|
        n = c.get("v1/appScreenshotSets/#{s['id']}/appScreenshots").body["data"].size
        "#{s.dig('attributes', 'screenshotDisplayType').sub('APP_', '')}=#{n}"
      end
      puts "| #{l.dig('attributes', 'locale')} | #{(l.dig('attributes', 'promotionalText') || '').size} | #{kws.join(',')} | #{sets.join(' ')} |"
    end
    puts ""
  end
end
