require 'spec_helper'

describe ZanoxPublisher::Profile do
  before(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxPublisher::authenticate(nil, nil) }

  describe '::all', :vcr do
    subject(:profiles) { ZanoxPublisher::Profile.all }

    it { is_expected.to be_kind_of Array }

    it { expect(profiles.count).to be > 0 }

    it { expect(profiles.first).to be_kind_of ZanoxPublisher::Profile }
  end

  describe '::first', :vcr do
    subject(:profile) { ZanoxPublisher::Profile.first }

    it { is_expected.to be_kind_of ZanoxPublisher::Profile }

    it 'responds to to_i with its ID' do
      expect(profile.to_i).to be == profile.id
    end
  end
end
