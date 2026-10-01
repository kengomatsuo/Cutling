# submit_release.rb — attach build N to the editable iOS and macOS versions and
# submit both for review; the iOS submission also carries every custom product
# page version still in PREPARE_FOR_SUBMISSION.
#
# Usage: ruby fastlane/submit_release.rb <build-number>
# Waits up to an hour for each build to finish processing.

require 'spaceship'
require 'json'

BUILD = ARGV.fetch(0)
cfg = JSON.parse(File.read(File.join(__dir__, "asc_api_key.json")))
Spaceship::ConnectAPI.auth(key_id: cfg["key_id"], issuer_id: cfg["issuer_id"], key: cfg["key"])
app = Spaceship::ConnectAPI::App.find("com.matsuokengo.Cutling")
client = Spaceship::ConnectAPI.tunes_request_client

def wait_for_build(app, platform, number)
  120.times do
    build = app.get_builds(filter: { version: number, "preReleaseVersion.platform" => platform }).first
    state = build&.processing_state
    puts "#{platform} build #{number}: #{state || 'not visible yet'}"
    return build if state == "VALID"
    abort "#{platform} build #{number} failed processing: #{state}" if %w[FAILED INVALID].include?(state)
    sleep 30
  end
  abort "#{platform} build #{number} did not finish processing within an hour"
end

{ "IOS" => "IOS", "MAC_OS" => "MAC_OS" }.each do |platform, build_platform|
  version = app.get_edit_app_store_version(platform: platform)
  abort "No editable #{platform} version" unless version
  build = wait_for_build(app, build_platform, BUILD)
  version.select_build(build_id: build.id)
  puts "#{platform} #{version.version_string}: build #{BUILD} attached"

  submission = app.get_ready_review_submission(platform: platform) || app.create_review_submission(platform: platform)
  submission.add_app_store_version_to_review_items(app_store_version_id: version.id)

  if platform == "IOS"
    client.get("v1/apps/#{app.id}/appCustomProductPages").body["data"].each do |page|
      client.get("v1/appCustomProductPages/#{page['id']}/appCustomProductPageVersions").body["data"].each do |v|
        next unless v.dig("attributes", "state") == "PREPARE_FOR_SUBMISSION"
        client.post("v1/reviewSubmissionItems", { data: { type: "reviewSubmissionItems", relationships: {
          reviewSubmission: { data: { type: "reviewSubmissions", id: submission.id } },
          appCustomProductPageVersion: { data: { type: "appCustomProductPageVersions", id: v["id"] } } } } })
        puts "  + custom product page #{page.dig('attributes', 'name')}"
      end
    end
  end

  submission.submit_for_review
  puts "#{platform} #{version.version_string}: submitted for review"
end
