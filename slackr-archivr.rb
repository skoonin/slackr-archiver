require 'slack-ruby-client'
require 'date'
require 'csv'
require 'logger'


# logging options
archiver_log = Logger.new("slackr-archiver.log", 6, 50240000)
archiver_log.datetime_format = '%Y-%m-%d %H:%M:%S'
archiver_log.formatter = proc do |severity, datetime, progname, msg|
   "#{datetime} -- :  #{msg}\n"
end

#local variables
channels_to_archive = []
active_channels = []
days_inactive_threshold = 60
channel_whitelist = ["_helpdesk", "10east", "10west", "9east", "9west", "8east", "7east", "6east"]
channels_to_archive = []

dry_run = true

Slack.configure do |config|
  config.token = ['SLACK_API_TOKEN']
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::Web::Client.new


archiver_log.info { " ****** Beginning Slackr-Archiver run ****** " }
archiver_log.info { "Dry-Run is active." } if dry_run == true
archiver_log.info { "Loading existing data..." }

# load existing data from csv into array of hashes
if File.exists?("slackr-db.csv")
  data = CSV.read("slackr-db.csv", { encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
  slackr_db = data.map { |d| d.to_hash }
end

archiver_log.info { "Data loaded successfully." }
archiver_log.info { "Checking for channels that haven't been touched for #{days_inactive_threshold} days." }

# check for channels that are 60 days inactive
slackr_db.each do |x|
  channel_last_active_date = Time.parse(x[:channel_last_active_date])
  channel_name = x[:channel_name]
  channel_id = x[:channel_id]

  if !channel_whitelist.include?(channel_name)
    if channel_last_active_date <= Time.now - days_inactive_threshold.days
      channels_to_archive.push(channel_id: channel_id)

    end
  else
    active_channels.push({channel_name: channel_name, channel_id: channel_id, channel_last_active_date: channel_last_active_date})
  end
end

puts "done"
puts channels_to_archive

archiver_log.info { " ****** Finished Slackr-Archiver run ****** " }
