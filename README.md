#### SLACKR Archiver

A small app built to Auto-Archive Slack Channels. 

*Context:* This for a specific use case where my company has a 2 day retention policy in Slack. In order to properly track channel history,
the Recon app runs daily and stores the newest message date from the last 2 days OR the date from a small "db" csv file. The archiver app then allows 
a user to either notify channels or archive channels. 

## Requirements

Writing in Ruby 2.4.1<br>
Requires [slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client)
Slack API Token (Bot Integration)

Gems:
<pre><code>require 'slack-ruby-client'<br>
require 'date'<br>
require 'csv'<br>
require 'logger'<br>
require 'highline/import'<br></code></pre>

## Proper Usage

The *Recon* app should be setup to run daily via cron. It creates a file called <code>slackr_channels.db</code>.  It will also create a cop of the last day's run db to use as a comparison and backup, <code>slackr_channels.db.last</code>.

The **Archiver** app can be used to either:

+ **Archive** channels with 60+ days of inactivity
+ **Notify** dead channels with 30+ days of inactivity
  + Note: This will reset a channels activity and it will become "active" again. 
  + To edit the message text, you need to edit <code>archiver_slackr.rb</code>
  + Perform a **Dry-Run**. This should always be done first. 
  + You can alter the Inactivity time in <code>archiver_slackr.rb</code>

  <pre><code>
  Usage:  archiver_slackr <flag>"
      -d, --dry-run                 runs in DRY-RUN mode (do this first! no channels will be archived)
      -n, --notify                  runs in NOTIFY mode. (sends a polite message to any channels that are 30 days inactive (but less than 60)
                                          *** NOTE: this will reset a channels `Days Till Archive` to the day you run this
      -a, --archive, --active       runs in ACTIVE mode. (this will archive channels)
      -h, --help, ?                 this handy help screen
      </code></pre>

# Whitelist

There is a whitelist file used to prevent specific channels from being archived.  Edit the file <code>whitelist.txt</code> for any changes.  If the file is missing it will be created upon first run. 

# Logging

All activity is logged in the files: 
+ **slackr_archiver.log** - Detailed logs of any archiver run, including dry runs. 
+ **slackr_archived_channels.log** - A list of all channels that were archived and the date it happened. Once a channel is archived, it will no longer be in the DB. 
+ **slackr_channels.db** - This is the CSV "db" file created by Recon and used by Archiver. 

# Future updates: 
+ Allow message to be specified on the command line
+ Allow number of recent messages parsed to be specified on command line
+ Create a way to not reset notified channels activity for 30 days after it's been done. 
