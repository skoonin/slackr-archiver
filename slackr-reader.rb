require 'slack-ruby-client'
require 'date'
require 'csv'

# Blacklist: add to this array any message subtypes you don't want to include (check slack's api for info)
# currently not including 'bot_message' since we have lots of channels that use mostly or only
subtype_blacklist = ['channel_leave', 'channel_join', 'channel_name', 'channel_purpose', 'channel_topic'] 
channels = []

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::Web::Client.new

# get all active (non-archived) channels so we can get their id's
non_archived_channels = client.channels_list.channels.select { |data| !data.is_archived }

# for each channel, get it's ID
non_archived_channels.first(10).each do |channel|
  channel_id = channel['id']
  channel_name = channel['name']
  channel_history = client.channels_history(channel: channel_id, count: '3')
  recent_msg_dates = []

  # grab the last 3 messages from each channel and see if it's new. 
  channel_history['messages'].each do |msg|
    msg_date = msg['ts']
    msg_text = msg['text']
    msg_subtype = msg['subtype']
    msg_hdate = Time.at(msg_date.to_i).utc.to_datetime
  
    if !subtype_blacklist.include?(msg_subtype)
      if msg_hdate >= Time.now - 48.hours 
         recent_msg_dates.push(msg_hdate)
      end 
    end
  end

latest_active_date = recent_msg_dates[0]
latest_active_date = Time.now if latest_active_date.nil? 
channels.push({channel_name: channel_name, channel_id: channel_id, latest_active_date: latest_active_date})

# sleep for Slack's API rate limit of 1 call per second.
sleep 1
end
puts channels
  # write to csv, channel name, channel id, last message date
CSV.open("slackr-db.csv", "wb") do |csv|
  channels.each do |channel| 
    csv << channel.values
    # csv << [ channel[:channel_name], channel[:id], channel[:latest_active_date] ] 
  end
end
