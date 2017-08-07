require 'slack-ruby-client'
require 'date'

# local variables

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::Web::Client.new

non_archived_channels = client.channels_list.channels.select { |data| !data.is_archived }

non_archived_channels.each do |channel|
  id = channel["id"]
  channel_name = channel["name"]

  channel_info = client.channels_info(channel: id)
if ??
    puts "#{channel_name} is active! #{active}"
  else
    puts "#{channel_name} missing"
  end
end

#
#
#
#
# active_channels = channelInfos.select do |channelInfo|
#   channelInfo.latest?
# end
#
# puts active_channels
#
#

