# SLACKR Auto-Archiver
v.1.0

A small app built to Auto-Archive Slack Channels. 

*Context:* This for a specific use case where my company has a 2 day retention policy in Slack. In order to properly track channel history,
the Recon app runs daily and stores the newest message date from the last 2 days OR the date from a small "db" csv file.  This is needed because once retention is lost, a channel's activity history shows up as empty (no date available).

The archiver app then allows a user to either notify channels or archive channels. 

### Requirements

Writing in Ruby 2.4.1<br>
Requires [slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client)<br>

Gems:
<pre><code>require 'slack-ruby-client'<br>
require 'date'<br>
require 'csv'<br>
require 'logger'<br>
require 'highline/import'<br></code></pre>

#### `API_TOKEN` (Required)

The best way to get an `API_TOKEN` is to [create a new Slack App](https://api.slack.com/apps/new).

Once you create and name your app on your team, go to "OAuth & Permissions" to give it the following permission scopes:

- `channels:history`
- `channels:read`
- `channels:write`
- `chat:write:bot`
- `chat:write:user`
- `emoji:read`
- `users:read`

After saving, you can copy the OAuth Access Token value from the top of the same screen. It probably starts with `xox`.

## Proper Usage

#### Recon_Slackr

The **Recon** app creates a file called <code>slackr_channels.db</code>.  It stores each public channels last active message date. 

It will also create a copy of the last day's run db to use as a comparison and backup, <code>slackr_channels.db.last</code>. If it finds that a message has a last active date in the db, it won't erase it and start it fresh as if the channel is new. 

**Recon should be setup to run daily via cron.**

#### Archiver_Slackr

The **Archiver** app can be used to either:

+ Perform a **Dry-Run**. This should always be done first. 
+ **Archive** channels with 60+ days of inactivity
+ **Notify** dead channels with 30+ days of inactivity
  + To edit the message text, you need to edit <code>archiver_slackr.rb</code>
+ You can alter the Inactivity time in <code>archiver_slackr.rb</code>

<pre><code>
Usage:  archiver_slackr <flag>
    -d, --dry-run                 runs in DRY-RUN mode (do this first! no channels will be archived)
    -n, --notify                  runs in NOTIFY mode. (sends a polite message to any channels that are 30 days inactive (but less than 60)
    -a, --archive, --active       runs in ACTIVE mode. (this will archive channels)
    -h, --help, ?                 this handy help screen
    </code></pre>

An example would be to run <code>ruby archiver_slackr -d</code>code> to do a dry run.

### Whitelist

There is a whitelist file used to prevent specific channels from being archived.  Edit the file <code>whitelist.txt</code> for any changes.  If the file is missing it will be created upon first run. 

### Logging

All activity is logged in the files: 
+ **slackr_archiver.log** - Detailed logs of any archiver run, including dry runs. 
+ **slackr_archived_channels.log** - A list of all channels that were archived and the date it happened. Once a channel is archived, it will no longer be in the DB. 
+ **slackr_channels.db** - This is the CSV "db" file created by Recon and used by Archiver. 

### Future updates: 
+ Allow message to be specified on the command line
+ Allow number of recent messages parsed to be specified on command line
