# encoding: utf-8

require "logstash/outputs/base"
require "logstash/namespace"

# This output allows you to use Logstash to parse and structure
# your logs and ship structured event data to JIRA.
#
# Structured event data will be added to the JIRA issue as 'Description' field value.
#
# Example JSON-encoded event:
#
#     {
#       "message": "Hello JIRA!",
#       "@version": "1",
#       "@timestamp": "2015-06-04T10:23:30.279Z",
#       "type": "syslog",
#       "host": "192.168.1.42",
#       "syslog_pri": "11",
#       "syslog_timestamp": "Jun  4 14:23:30",
#       "syslog_host": "myhost",
#       "program": "root",
#       "syslog_severity_code": 3,
#       "syslog_facility_code": 1,
#       "syslog_facility": "user-level",
#       "syslog_severity": "error"
#     }
#
# Example JIRA issue created the event above:
#
#     Type:        Task
#     Priority:    2 - Major
#     Status:      TO DO
#     Resolution:  Unresolved
#     Summary:     [logstash] Hello JIRA!
#     Description:
#         ---
#         message: Hello JIRA!
#         '@version': '1'
#         '@timestamp': 2015-06-04 10:23:30.279000000 Z
#         type: syslog
#         host: 192.168.1.42
#         syslog_pri: '11'
#         syslog_timestamp: Jun 4 14:23:30
#         syslog_host: myhost
#         program: root
#         syslog_severity_code: 3
#         syslog_facility_code: 1
#         syslog_facility: user-level
#         syslog_severity: error
#
# To use this output you'll need to ensure that your JIRA instance allows REST calls.
#
# This output uses `jiralicious` as the bridge to JIRA
# By Martin Cleaver, Blended Perspectives
# with a lot of help from 'electrical' in #logstash.
#
# Origin <https://groups.google.com/forum/#!msg/logstash-users/exgrB4iQ-mw/R34apku5nXsJ>
# and <https://botbot.me/freenode/logstash/msg/4169496/>
# via <https://gist.github.com/electrical/4660061e8fff11cdcf37#file-jira-rb>.

class LogStash::Outputs::Jira < LogStash::Outputs::Base
  config_name "jira"

  # The hostname to send logs to. This should target your JIRA server 
  # and has to have the REST interface enabled
  config :host, :validate => :string

  config :username, :validate => :string, :required => true
  config :password, :validate => :string, :required => true

  # Javalicious has no proxy support
###
  # JIRA Project number
  config :projectid, :validate => :string, :required => true

  # JIRA Issuetype number
  config :issuetypeid, :validate => :string, :required => true

  # JIRA Summary
  #
  # Truncated and appended with '...' if longer than 255 characters.
  config :summary, :validate => :string, :required => true

  # JIRA Priority
  config :priority, :validate => :string, :required => true

  # JIRA Reporter
  config :reporter, :validate => :string

  # JIRA Reporter
  config :assignee, :validate => :string

### The following have not been implemented
  # Ticket creation method
  #config :method, :validate => :string, :default => 'new'
  
  # Search fields; When in 'append' method. search for a ticket that has these fields and data.
  #config :searchfields, :validate => :hash
  
  # createfields; Add data to these fields at initial creation
  #config :createfields, :validate => :hash
  
  # appendfields; Update data in these fields when appending data to an existing ticket
  #config :appendfields, :validate => :hash
  
  # Comment; Add this in the comment field ( is for new and append method the same )
  #config :comment, :validate => :string


  public
  def register
    require "jiralicious" # 0.2.2 works for me
    # nothing to do
  end

  public
  def receive(event)
    return unless output?(event)

    if event == LogStash::SHUTDOWN
      finished
      return
    end

    Jiralicious.configure do |config|
      config.username = @username
      config.password = @password
      config.uri = @host
      config.auth_type = :basic
      config.api_version = "latest"
    end


    # Limit issue summary to 255 characters
    summary = event.sprintf(@summary)
    summary = "#{summary[0,252]}..." if summary.length > 255

issue = Jiralicious::Issue.new
    issue.fields.set_id("project", @projectid) # would have prefered a project key, https://github.com/jstewart/jiralicious/issues/16
    issue.fields.set("summary", summary)
    issue.fields.set("description", event.sprintf(event.to_hash.to_yaml))
    issue.fields.set_id("issuetype", @issuetypeid)
    issue.fields.set_name("reporter", @reporter) if @reporter
    issue.fields.set_name("assignee", @assignee) if @assignee
    issue.fields.set_id("priority", @priority)
#puts issue.fields.to_yaml
    issue.save



#    if response.is_a?(Net::HTTPSuccess)
#      @logger.info("Event send to JIRA OK!")
#    else
#      @logger.warn("HTTP error", :error => response.error!)
#    end
  end # def receive
end # class LogStash::Outputs::Jira
