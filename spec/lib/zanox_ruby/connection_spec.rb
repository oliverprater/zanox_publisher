require 'spec_helper'

describe ZanoxRuby::Connection, :focus do
  describe "#initialize" do
    context "with parameters" do
      it "should set connect ID and secret key" do
        connection = ZanoxRuby::Connection.new('', credentials['connect_id'], credentials['secret_key'])

        expect(connection.instance_variable_get(:@connect_id)).to eql credentials['connect_id']
        expect(connection.instance_variable_get(:@secret_key)).to eql credentials['secret_key']
      end
    end

    context "with ZanoxRuby::authenticate" do
      before(:each) do
        ZanoxRuby.authenticate(credentials['connect_id'], credentials['secret_key'])
      end

      it "should default to authenticate parameters" do
        connection = ZanoxRuby::Connection.new

        expect(connection.instance_variable_get(:@connect_id)).to eql credentials['connect_id']
        expect(connection.instance_variable_get(:@secret_key)).to eql credentials['secret_key']
      end

      it "should be able to set the relative path" do
        connection = ZanoxRuby::Connection.new('/profiles')

        expect(connection.instance_variable_get(:@relative_path)).to eql '/profiles'
      end
    end
  end
end
