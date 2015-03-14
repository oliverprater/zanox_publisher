require 'spec_helper'

describe ZanoxPublisher::AdSpace do
  before(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxPublisher::authenticate(nil, nil) }

  describe '::page', :vcr do
    subject(:adspaces) { ZanoxPublisher::AdSpace.page }

    it { is_expected.to be_kind_of Array }
    it { expect(adspaces.first).to be_kind_of ZanoxPublisher::AdSpace }

    it { expect(adspaces.count).to be > 0 }
    it 'sets the AdSpace total count' do
      ZanoxPublisher::AdSpace.total = nil
      adspaces
      expect(ZanoxPublisher::AdSpace.total).to be > 0
    end
  end

  describe '::all', :vcr do
    subject(:adspaces) { ZanoxPublisher::AdSpace.all }

    it { is_expected.to be_kind_of Array }
    it { expect(adspaces.first).to be_kind_of ZanoxPublisher::AdSpace }

    it { expect(adspaces.count).to be == ZanoxPublisher::AdSpace.total }
  end

  describe '::find', vcr: { record: :new_episodes } do
    let(:first) do
      ZanoxPublisher::AdSpace.all.first
    end

    subject(:find) { ZanoxPublisher::AdSpace.find(first.id) }

    it { is_expected.to be_kind_of ZanoxPublisher::AdSpace }

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
    subject(:adspace) { ZanoxPublisher::AdSpace.all.first }

    it 'responds to to_i with its ID' do
      expect(adspace.to_i).to be == adspace.id
    end
  end
end
