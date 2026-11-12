# resubmit_rejected.rb — sends a rejected version back to App Review after its fix is in place.
#
# Usage: ruby fastlane/resubmit_rejected.rb <IOS|MAC_OS>
# A rejection leaves the platform's review submission in UNRESOLVED_ISSUES, which blocks a new
# submission (submit_release.rb and deliver both refuse). App Review takes it back only after each
# rejected item is marked resolved; then the same submission is submitted again. Only this
# platform's submission is touched, so the other platform's review keeps its place.

require 'spaceship'
require 'json'

platform = ARGV.fetch(0) { abort "usage: ruby fastlane/resubmit_rejected.rb <IOS|MAC_OS>" }
cfg = JSON.parse(File.read(File.join(__dir__, "asc_api_key.json")))
Spaceship::ConnectAPI.auth(key_id: cfg["key_id"], issuer_id: cfg["issuer_id"], key: cfg["key"])
app = Spaceship::ConnectAPI::App.find("com.matsuokengo.Cutling")
client = Spaceship::ConnectAPI.tunes_request_client

submission = client.get("v1/reviewSubmissions", { "filter[app]" => app.id, "filter[platform]" => platform,
                                                  "filter[state]" => "UNRESOLVED_ISSUES" }).body["data"].first
abort "No #{platform} submission has unresolved issues" unless submission

client.get("v1/reviewSubmissions/#{submission['id']}/items").body["data"].each do |item|
  next unless item.dig("attributes", "state") == "REJECTED"
  client.patch("v1/reviewSubmissionItems/#{item['id']}",
               { data: { type: "reviewSubmissionItems", id: item["id"], attributes: { resolved: true } } })
  puts "item #{item['id']} marked resolved"
end

result = client.patch("v1/reviewSubmissions/#{submission['id']}",
                      { data: { type: "reviewSubmissions", id: submission["id"], attributes: { submitted: true } } })
version = app.get_app_store_versions(filter: { platform: platform }, limit: 1).first
puts "#{platform} submission #{result.body.dig('data', 'attributes', 'state')}; version #{version.version_string} #{version.app_store_state}"
