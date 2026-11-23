# replace_previews.rb — swaps the editable version's app previews for new files, set by set, and reads them back.
#
# Usage: ruby fastlane/replace_previews.rb <version> <dir> [--platform ios|mac] [--readback]
#
# Files in <dir> are named cutling-preview-<device>-<lang>[-<n>].mp4: device iphone or ipad (iOS) or mac (Mac),
# lang "en" for en-US and the store locale code for every other language (id, ja, de-DE, ...), n the order in the set
# (1-3, Apple's limit). Every set a file names ends holding exactly those files in that order: the new previews are
# uploaded and processed first, then the old ones are deleted, so a failed upload leaves the set as it was. Sets no
# file names stay as they are. A poster frame is read from <dir>/posters.json ({"<file name>": "00:00:05:00"}),
# else the old preview's, else Apple's default 5 s. --readback uploads nothing and lists every preview of the version.
# Run it with fastlane's Ruby, which carries spaceship (Homebrew's fastlane: its libexec ruby and GEM_PATH).

require 'spaceship'
require 'json'

version, dir = ARGV[0], ARGV[1]
abort "usage: ruby fastlane/replace_previews.rb <version> <dir> [--platform ios|mac] [--readback]" unless version && dir
readback_only = ARGV.include?("--readback")
platform = ARGV[ARGV.index("--platform") + 1] rescue "ios"
platform ||= "ios"
api_platform = { "ios" => "IOS", "mac" => "MAC_OS" }.fetch(platform) { abort "platform is ios or mac" }
TYPES = platform == "mac" ? { "mac" => "DESKTOP" } : { "iphone" => "IPHONE_67", "ipad" => "IPAD_PRO_3GEN_129" }
lang_of = ->(locale) { locale == "en-US" ? "en" : locale }

cfg = JSON.parse(File.read(File.join(__dir__, "asc_api_key.json")))
Spaceship::ConnectAPI.auth(key_id: cfg["key_id"], issuer_id: cfg["issuer_id"], key: cfg["key"])
app = Spaceship::ConnectAPI::App.find("com.matsuokengo.Cutling")
v = app.get_edit_app_store_version(platform: api_platform)
abort "editable #{api_platform} version is #{v&.version_string}, not #{version}" unless v&.version_string == version
puts "#{api_platform} #{v.version_string} (#{v.app_store_state})"

posters_path = File.join(dir, "posters.json")
posters = File.exist?(posters_path) ? JSON.parse(File.read(posters_path)) : {}
files = Dir[File.join(dir, "cutling-preview-*.mp4")].map { |p| File.basename(p) }
wanted = Hash.new { |h, k| h[k] = [] } # [device, lang] => [file names in order]
files.each do |name|
  m = name.match(/\Acutling-preview-(iphone|ipad|mac)-(.+?)(?:-(\d))?\.mp4\z/) or next
  next unless TYPES.key?(m[1])
  wanted[[m[1], m[2]]] << [m[3].to_i, name]
end
wanted.each_value { |list| list.sort!.map!(&:last) }
abort "no cutling-preview-<#{TYPES.keys.join('|')}>-<lang>.mp4 in #{dir}" if wanted.empty? && !readback_only

locs = v.get_app_store_version_localizations.sort_by(&:locale)
unless readback_only
  missing = wanted.keys.map(&:last).uniq - locs.map { |l| lang_of.(l.locale) }
  abort "no #{api_platform} #{version} localization for: #{missing.join(', ')}" unless missing.empty?
  too_many = wanted.select { |_, list| list.size > 3 }
  abort "Apple holds at most three previews per set: #{too_many.keys.inspect}" unless too_many.empty?
end

count = 0
locs.each do |loc|
  sets = loc.get_app_preview_sets
  TYPES.each do |device, type|
    names = wanted[[device, lang_of.(loc.locale)]] || []
    set = sets.find { |s| s.preview_type == type }
    if !readback_only && !names.empty?
      set ||= loc.create_app_preview_set(attributes: { previewType: type })
      old = Spaceship::ConnectAPI::AppPreviewSet.get(app_preview_set_id: set.id).app_previews.to_a
      old_code = old.map(&:preview_frame_time_code).compact.first
      fresh_ids = names.map do |name|
        fresh = set.upload_preview(path: File.join(dir, name), wait_for_processing: true, frame_time_code: posters[name] || old_code || "00:00:05:00")
        fresh = Spaceship::ConnectAPI::AppPreview.get(app_preview_id: fresh.id)
        abort "#{loc.locale} #{type} #{name}: preview #{fresh.id} not complete: #{fresh.asset_delivery_state}" unless fresh.complete?
        fresh.id
      end
      old.each(&:delete!)
      set.reorder_previews(app_preview_ids: fresh_ids) if fresh_ids.size > 1
    end
    next unless set
    Spaceship::ConnectAPI::AppPreviewSet.get(app_preview_set_id: set.id).app_previews.to_a.each do |p|
      count += 1
      puts "#{loc.locale} #{type}: #{p.file_name} #{p.file_size} B, state #{p.asset_delivery_state&.dig('state')}, poster #{p.preview_frame_time_code}, id #{p.id}"
    end
  end
end
puts "#{count} previews across #{locs.size} localizations"
