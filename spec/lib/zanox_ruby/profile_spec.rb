require 'spec_helper'

describe ZanoxRuby::Profile do
  before(:all) { ZanoxRuby::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxRuby::authenticate(nil, nil) }

  describe '::all', :vcr do
    subject(:profiles) { ZanoxRuby::Profile.all }

    it { is_expected.to be_kind_of Array }

    it { expect(profiles.count).to be > 0 }

    it { expect(profiles.first).to be_kind_of ZanoxRuby::Profile }
  end

  describe '::first', :vcr do
    subject(:profile) { ZanoxRuby::Profile.first }

    it { is_expected.to be_kind_of ZanoxRuby::Profile }

    it 'responds to to_i with its ID' do
      expect(profile.to_i).to be == profile.id
    end
  end
end
