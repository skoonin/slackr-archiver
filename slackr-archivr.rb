require 'slack-ruby-client'
require 'date'

# Blacklist: add to this array any message subtypes you don't want to include (check slack's api for info)
# currently not including 'bot_message' since we have lots of channels that use mostly or only
subtype_blacklist = ['channel_leave', 'channel_join', 'channel_name', 'channel_purpose', 'channel_topic'] 
active_channels = []
dead_channels = []

Slack.configure do |config|
  config.token = ['SLACK_API_TOKEN']
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::Web::Client.new

# Create whitelist of channels to ignore
# Create dry run switch
# Create days_inactve variable
# Call DB for channels that haven't been active in X amount of days
# Iterate over channels, skipping whitelisted channels, (if not dry run) archiving the rest
# 

