require 'spec_helper'

describe ZanoxRuby::AdSpace do
  before(:all) { ZanoxRuby::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxRuby::authenticate(nil, nil) }

  describe '::page', :vcr do
    subject(:adspaces) { ZanoxRuby::AdSpace.page }

    it { is_expected.to be_kind_of Array }
    it { expect(adspaces.first).to be_kind_of ZanoxRuby::AdSpace }

    it { expect(adspaces.count).to be > 0 }
    it 'sets the AdSpace total count' do
      ZanoxRuby::AdSpace.total = nil
      adspaces
      expect(ZanoxRuby::AdSpace.total).to be > 0
    end
  end

  describe '::all', :vcr do
    subject(:adspaces) { ZanoxRuby::AdSpace.all }

    it { is_expected.to be_kind_of Array }
    it { expect(adspaces.first).to be_kind_of ZanoxRuby::AdSpace }

    it { expect(adspaces.count).to be == ZanoxRuby::AdSpace.total }
  end

  describe '::find', vcr: { record: :new_episodes } do
    let(:first) do
      ZanoxRuby::AdSpace.all.first
    end

    subject(:find) { ZanoxRuby::AdSpace.find(first.id) }

    it { is_expected.to be_kind_of ZanoxRuby::AdSpace }

    it { expect(find.id).to be == first.id }
    it { expect(find.name).to be == first.name }
    it { expect(find.url).to be == first.url }
    it { expect(find.description).to be == first.description }
    it { expect(find.adspace_type).to be == first.adspace_type }
    it { expect(find.visitors).to be == first.visitors }
    it { expect(find.impressions).to be == first.impressions }
    it { expect(find.language).to be == first.language }
  end

  describe 'item', :vcr do
    subject(:adspace) { ZanoxRuby::AdSpace.all.first }

    it 'responds to to_i with its ID' do
      expect(adspace.to_i).to be == adspace.id
    end
  end
end
