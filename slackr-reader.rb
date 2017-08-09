require 'slack-ruby-client'
require 'date'
require 'csv'

puts "Beginning Reader run."

# Blacklist: add to this array any message subtypes you don't want to include (check slack's api for info)
# currently not including 'bot_message' since we have lots of channels that use mostly or only
subtype_blacklist = ['channel_leave', 'channel_join', 'channel_name', 'channel_purpose', 'channel_topic']
channels = []

# load existing data from csv into array of hashes or create a new blank file.
if File.exists?("slackr-db.csv")
  data = CSV.read("slackr-db.csv", { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
  prev_run_data = data.map { |d| d.to_hash }
else
  data = File.new("slackr-db.csv", "w+")
  data << "channel_name,channel_id,channel_last_active_date"
  prev_run_data = []
end

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::Web::Client.new

# get all active (non-archived) channels so we can get their id's
non_archived_channels = client.channels_list.channels.select { |data| !data.is_archived }

# for each channel, get it's ID
non_archived_channels.each do |channel|
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

# gets the first item from the array because slack outputs events in time order, newest first.
channel_last_active_date = recent_msg_dates[0]

# if a channel's last active date is nil, check the db for a date, if there is none, set it today.
# if there is an existing date in the db, set channel_last_active_date to the date in the db.
prev_run_data_arr = prev_run_data.select { |x| x[:channel_id] == channel_id }

if !prev_run_data_arr[0].nil?
  prev_run_data_hash = prev_run_data_arr[0].to_hash
  channel_prev_run_active_date = prev_run_data_hash[:channel_last_active_date]
end

if channel_last_active_date.nil?
  if channel_prev_run_active_date.nil?
    channel_last_active_date = Time.now
  else
    channel_last_active_date = channel_prev_run_active_date
  end
end

# send the results to the channels array for output later
channels.push({channel_name: channel_name, channel_id: channel_id, channel_last_active_date: channel_last_active_date})

# sleep for Slack's API rate limit of 1 call per second.
sleep 1
end

# write to csv, channel name, channel id, last message date
CSV.open("slackr-db.csv", "wb") do |csv|
  csv << channels.first.keys
  channels.each do |channel|
    csv << channel.values
  end
end

puts "Done with Reader run!"



















