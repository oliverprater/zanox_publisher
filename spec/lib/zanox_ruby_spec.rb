require 'spec_helper'

describe ZanoxPublisher do
  context "version" do
    it "should be defined" do
      expect(ZanoxPublisher::VERSION).not_to be_nil
    end
  end

  context "::authenticate" do
    it "should set connect ID and secret" do
      ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key'])
      expect(ZanoxPublisher::connect_id).to eql credentials['connect_id']
      expect(ZanoxPublisher::secret_key).to eql credentials['secret_key']
    end
  end
end
