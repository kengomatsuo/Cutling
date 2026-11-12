# replace_previews.rb — swaps one iOS version's app previews for new files, set by set, and reads them back.
#
# Usage: ruby fastlane/replace_previews.rb <version> <dir with cutling-preview-{iphone,ipad}-{en,id,ja}.mp4> [--readback]
# Each named set ends holding exactly the new file: the new preview is uploaded and processed first, then the old ones
# are deleted, so a failed upload leaves the set as it was. The poster frame keeps the old preview's time code.

require 'spaceship'
require 'json'

version, dir = ARGV[0], ARGV[1]
abort "usage: ruby fastlane/replace_previews.rb <version> <dir> [--readback]" unless version && dir
readback_only = ARGV.include?("--readback")

cfg = JSON.parse(File.read(File.join(__dir__, "asc_api_key.json")))
Spaceship::ConnectAPI.auth(key_id: cfg["key_id"], issuer_id: cfg["issuer_id"], key: cfg["key"])
app = Spaceship::ConnectAPI::App.find("com.matsuokengo.Cutling")
v = app.get_edit_app_store_version(platform: "IOS")
abort "editable iOS version is #{v&.version_string}, not #{version}" unless v&.version_string == version
puts "iOS #{v.version_string} (#{v.app_store_state})"

LOCALES = { "en-US" => "en", "id" => "id", "ja" => "ja" }
TYPES = { "IPHONE_67" => "iphone", "IPAD_PRO_3GEN_129" => "ipad" }

v.get_app_store_version_localizations.select { |l| LOCALES.key?(l.locale) }.sort_by(&:locale).each do |loc|
  sets = loc.get_app_preview_sets
  TYPES.each do |type, device|
    set = sets.find { |s| s.preview_type == type } || Spaceship::ConnectAPI::AppPreviewSet.create(app_store_version_localization_id: loc.id, attributes: { previewType: type })
    old = Spaceship::ConnectAPI::AppPreviewSet.get(app_preview_set_id: set.id).app_previews.to_a
    unless readback_only
      path = File.join(dir, "cutling-preview-#{device}-#{LOCALES[loc.locale]}.mp4")
      abort "missing #{path}" unless File.exist?(path)
      code = old.map(&:preview_frame_time_code).compact.first
      fresh = set.upload_preview(path: path, wait_for_processing: true, frame_time_code: code)
      fresh = Spaceship::ConnectAPI::AppPreview.get(app_preview_id: fresh.id)
      abort "#{loc.locale} #{type}: new preview #{fresh.id} not complete: #{fresh.asset_delivery_state}" unless fresh.complete?
      old.each(&:delete!)
    end
    now = Spaceship::ConnectAPI::AppPreviewSet.get(app_preview_set_id: set.id).app_previews.to_a
    now.each do |p|
      puts "#{loc.locale} #{type}: #{p.file_name} #{p.file_size} B, state #{p.asset_delivery_state&.dig('state')}, poster #{p.preview_frame_time_code}, id #{p.id}"
    end
  end
end
