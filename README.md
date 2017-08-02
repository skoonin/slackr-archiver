#### SLACKR Archiver

This will be a small app to pull channel last message date and save it into a database.  
The info in this database will then be used to figure out if a channel can be archived and then archive it
This is needed because Tumblr has 2 day retention on most of our channels, which makes them show up as inactive when they may actually be in use. 

Writing in Ruby 2.4<br>
Will try and use [slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client)
Need to include a dry-run scenario somehow


+ Using channels.list, request all channels from Slack
+ For each channel in that list:
  + if Channel is already archived: 
    + Output channel name and archived status to log ("X" channel is already Archived")
    + Send update to DB:  channel name, channel ID#, archived=true, last updated (timestamp of when the entry was last touched)
  + if Channel is not archived:
    + For each un-archived channel, get a channel.info request
    + Iterate over the request and pull out the channel name, channel ID and the latest message timestamp.
    + Compare the latest message timestamp with latest message date from the database.
      + If latest message date is equal or missing, re-calculate # of days since last message and update the DB (days since last message, last updated, archived=false)
      + If latest message date is more recent, re-calculate # of days since last message and update the DB (latest message date, days since last message, archived=false, last updated)
      + output channel name and last active date to the log
+ Once database is updated, pull a list of channels that have not been active in 60+ days and are not archived from the database
  + for each channel in list:
    + send a request to archive the channel
    + update the DB (archived=true, last updated)
    + output channel name and "is now archived" to the log
    
  
