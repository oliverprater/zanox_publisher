require 'spec_helper'

describe ZanoxPublisher::Connection do
  describe "#initialize" do

    it { is_expected.to respond_to :relative_path }

    context "with parameters" do
      before(:all) { ZanoxPublisher::authenticate(nil, nil) }
      after(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key']) }
      subject(:connection) { ZanoxPublisher::Connection.new('', credentials['connect_id'], credentials['secret_key']) }

      it "should set connect ID and secret key" do
        expect(connection.instance_variable_get(:@connect_id)).to eql credentials['connect_id']
        expect(connection.instance_variable_get(:@secret_key)).to eql credentials['secret_key']
      end

      it "should have '' as relative path" do
        expect(connection.relative_path).to eql ''
      end
    end

    context "with ZanoxPublisher::authenticate" do
      before(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key']) }
      after(:all) { ZanoxPublisher::authenticate(nil, nil) }
      subject(:connection) { ZanoxPublisher::Connection.new('/profiles') }

      it "should default to authenticate parameters" do
        expect(connection.instance_variable_get(:@connect_id)).to eql credentials['connect_id']
        expect(connection.instance_variable_get(:@secret_key)).to eql credentials['secret_key']
      end

      it "should be able to set the relative path" do
        expect(connection.relative_path).to eql '/profiles'
      end
    end
  end

  describe 'AuthenticationError' do
    before(:all) { ZanoxPublisher::authenticate(nil, nil) }
    after(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key']) }
    subject(:connection) { ZanoxPublisher::Connection.new() }

    it 'when public resource is accessed without connect ID' do
      expect{connection.get}.to raise_error(ZanoxPublisher::AuthenticationError)
    end

    it 'when private resource is accessed without connect ID or secret' do
      expect{connection.signature_get}.to raise_error(ZanoxPublisher::AuthenticationError)
    end
  end

  describe 'Unauthorized' do
    before(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], 'INVALID') }
    after(:all) { ZanoxPublisher::authenticate(nil, nil) }
    subject(:connection) { ZanoxPublisher::Connection.new() }

    it { expect{ connection.signature_get('/profiles') }.to raise_error(ZanoxPublisher::Unauthorized) }
  end

  describe 'NotFound' do
    before(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key']) }
    after(:all) { ZanoxPublisher::authenticate(nil, nil) }
    subject(:connection) { ZanoxPublisher::Connection.new() }

    it { expect{ connection.get('/no_where') }.to raise_error(ZanoxPublisher::NotFound) }
  end
end
