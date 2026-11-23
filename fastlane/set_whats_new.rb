# set_whats_new.rb — writes only "What's New" on the editable version, from the release notes on disk, and reads it back.
#
# Usage: ruby fastlane/set_whats_new.rb <version> ios|mac [--readback]
# iOS reads fastlane/metadata/<locale>/release_notes.txt, Mac fastlane/metadata_mac/<locale>/release_notes.txt.
# Nothing else on the version changes (deliver's metadata lanes also send keywords, descriptions and promo text).
# Run it with fastlane's Ruby, which carries spaceship (Homebrew's fastlane: its libexec ruby and GEM_PATH).

require 'spaceship'
require 'json'

version, plat = ARGV[0], ARGV[1]
abort "usage: ruby fastlane/set_whats_new.rb <version> ios|mac [--readback]" unless version && %w[ios mac].include?(plat)
readback_only = ARGV.include?("--readback")
api = plat == "ios" ? "IOS" : "MAC_OS"
dir = File.join(__dir__, plat == "ios" ? "metadata" : "metadata_mac")

cfg = JSON.parse(File.read(File.join(__dir__, "asc_api_key.json")))
Spaceship::ConnectAPI.auth(key_id: cfg["key_id"], issuer_id: cfg["issuer_id"], key: cfg["key"])
app = Spaceship::ConnectAPI::App.find("com.matsuokengo.Cutling")
v = app.get_edit_app_store_version(platform: api)
abort "editable #{api} version is #{v&.version_string}, not #{version}" unless v&.version_string == version
puts "#{api} #{v.version_string} (#{v.app_store_state})"

same = 0
v.get_app_store_version_localizations.sort_by(&:locale).each do |l|
  path = File.join(dir, l.locale, "release_notes.txt")
  unless File.exist?(path)
    puts "#{l.locale}: no notes on disk"
    next
  end
  want = File.read(path).strip
  unless readback_only || l.whats_new.to_s.strip == want
    l.update(attributes: { whats_new: want })
  end
  got = v.get_app_store_version_localizations.find { |x| x.locale == l.locale }.whats_new.to_s.strip
  ok = got == want
  same += 1 if ok
  puts "#{l.locale}: #{ok ? 'matches disk' : 'DIFFERS'} | #{got[0, 60].gsub("\n", ' ')}"
end
puts "#{same} localizations match disk"
