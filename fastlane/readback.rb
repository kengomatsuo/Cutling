# readback.rb — prints what App Store Connect holds for the editable versions.
#
# Usage: ruby fastlane/readback.rb > docs/aso/readback-<date>.md
# Names and subtitles live on the app-info record; keywords, promo, notes and
# screenshots on each platform's version; custom product pages on their own.

require 'spaceship'
require 'json'
require 'digest'
require 'set'

cfg = JSON.parse(File.read(File.join(__dir__, "asc_api_key.json")))
Spaceship::ConnectAPI.auth(key_id: cfg["key_id"], issuer_id: cfg["issuer_id"], key: cfg["key"])
app = Spaceship::ConnectAPI::App.find("com.matsuokengo.Cutling")

def cell(text) = (text || "").gsub("|", "\\|").gsub("\n", " ")

# "on disk n/N" counts the uploaded screenshots whose checksum matches a file
# the upload lanes send from this checkout, so stale images show as a shortfall.
def md5s(glob) = Dir.glob(File.join(__dir__, glob)).map { |f| Digest::MD5.file(f).hexdigest }.to_set
def on_disk(sums, disk) = "(on disk #{sums.count { |x| disk.include?(x) }}/#{sums.size})"
DISK_GLOB = { "IOS" => "screenshots/%s/*_framed.png", "MAC_OS" => "screenshots_mac/%s/*.png" }

puts "# App Store Connect read-back, #{Time.now.utc.strftime('%Y-%m-%d %H:%M UTC')}", ""

# Without a version in preparation there is no editable app info; the live one is read then
info = app.fetch_edit_app_info || app.fetch_live_app_info
puts "## App information (#{info.state}), shared by iOS and macOS", ""
puts "| Locale | Name | Subtitle |", "|---|---|---|"
info.get_app_info_localizations.sort_by(&:locale).each do |l|
  puts "| #{l.locale} | #{cell(l.name)} | #{cell(l.subtitle)} |"
end

{ "IOS" => "iOS", "MAC_OS" => "macOS" }.each do |platform, label|
  live = app.get_app_store_versions(filter: { platform: platform }).find { |v| v.app_store_state == "READY_FOR_SALE" }
  # A version in review is not editable but is still the one being shipped
  v = app.get_edit_app_store_version(platform: platform) || app.get_latest_app_store_version(platform: platform)
  puts "", "## #{label} #{v.version_string} (#{v.app_store_state}); on sale: #{live&.version_string}", ""
  puts "| Locale | Keywords (bytes) | Promo (chars) | What's New | Screenshot sets |", "|---|---|---|---|---|"
  v.get_app_store_version_localizations.sort_by(&:locale).each do |l|
    disk = md5s(format(DISK_GLOB[platform], l.locale))
    sets = l.get_app_screenshot_sets.map do |s|
      shots = s.app_screenshots.to_a
      "#{s.screenshot_display_type.sub('APP_', '')}=#{shots.size} #{on_disk(shots.map(&:source_file_checksum), disk)}"
    end
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
      disk = md5s("screenshots_cpp/*/#{l.dig('attributes', 'locale')}/*.png")
      sets = c.get("v1/appCustomProductPageLocalizations/#{l['id']}/appScreenshotSets").body["data"].map do |s|
        shots = c.get("v1/appScreenshotSets/#{s['id']}/appScreenshots").body["data"]
        sums = shots.map { |x| x.dig("attributes", "sourceFileChecksum") }
        "#{s.dig('attributes', 'screenshotDisplayType').sub('APP_', '')}=#{shots.size} #{on_disk(sums, disk)}"
      end
      puts "| #{l.dig('attributes', 'locale')} | #{(l.dig('attributes', 'promotionalText') || '').size} | #{kws.join(',')} | #{sets.join(' ')} |"
    end
    puts ""
  end
end
