require 'spec_helper'

describe ZanoxRuby do
  context "version" do
    it "should be defined" do
      expect(ZanoxRuby::VERSION).not_to be_nil
    end
  end

  context "::authenticate" do
    it "should set connect ID and secret" do
      ZanoxRuby::authenticate(credentials['connect_id'], credentials['secret_key'])
      expect(ZanoxRuby::connect_id).to eql credentials['connect_id']
      expect(ZanoxRuby::secret_key).to eql credentials['secret_key']
    end
  end
end
