require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/jira"

describe LogStash::Outputs::Jira do

  let(:plugin) { described_class.new(config) }

  describe "debugging `password`" do
    let(:config) {{
      "username" => "jira-user-name",
      "password" => "$ecre&-key",
      "projectid" => "my-project-id",
      "issuetypeid" => "issue-type-id",
      "summary" => "JIRA issue summary",
      "priority" => "High"
    }}

    it "should not show origin value" do
      expect(plugin.logger).to receive(:debug).with('<password>')

      plugin.register
      plugin.logger.send(:debug, plugin.password.to_s)
    end
  end

end
