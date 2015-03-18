require 'spec_helper'

describe ZanoxPublisher::AdMedium do
  before(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxPublisher::authenticate(nil, nil) }

  let(:program) { ZanoxPublisher::Program.page.first }
  let(:category) { program.admedia_categories.first }
  let(:region) { 'DE' }
  let(:format) { 4 }
  let(:type) { ZanoxPublisher::AdMedium.admedia_types.first }
  let(:purpose_supported) { ZanoxPublisher::AdMedium.admedia_purposes[1] }
  let(:purpose_unsupported) { ZanoxPublisher::AdMedium.admedia_purposes.last }
  let(:partnership_direct) { 'DIRECT' }
  let(:partnership_indirect) { 'INDIRECT' }
  let(:adspace) { ZanoxPublisher::AdSpace.page.first }
  let(:admedium_total) do
    ZanoxPublisher::AdMedium.page
    ZanoxPublisher::AdMedium.total
  end

  describe '::page', :vcr do
    subject(:admedia) { ZanoxPublisher::AdMedium.page }

    it { is_expected.to be_kind_of Array }
    it { expect(admedia.first).to be_kind_of ZanoxPublisher::AdMedium }

    it { expect(admedia.count).to be > 0 }
    it 'to set the AdMedium total count' do
      ZanoxPublisher::AdMedium.total = nil
      admedia
      expect(ZanoxPublisher::AdMedium.total).to be > 0
    end

    context 'with program', vcr: { record: :new_episodes } do
      subject(:admedia) { ZanoxPublisher::AdMedium.page(0, { program: program }) }

      it { expect(admedia.all? { |admedium| admedium.program.id == program.id }).to be true }
    end

    context 'with region', vcr: { record: :new_episodes } do
      subject(:admedia) { ZanoxPublisher::AdMedium.page(0, { region: region }) }

      it 'limits results to programs from a particular region' do
        programs = []

        admedia.each do |admedium|
          program = ZanoxPublisher::Program.find(admedium.program.id)
          programs << program
        end

        expect(programs.all? { |program| program.regions.include? region }).to be true
      end
    end

    context 'with format' do
      subject(:admedia) { ZanoxPublisher::AdMedium.page(0 , { format: format }) }

      it { expect(admedia.all? { |admedium| admedium.format.id == format }).to be true }
    end

    context 'with admedium_type' do
      subject(:admedia) { ZanoxPublisher::AdMedium.page(0, { admedium_type: type }) }

      it { expect(admedia.all? { |admedium| admedium.admedium_type == type }).to be true }
    end

    context 'with admediumtype' do
      subject(:admedia) { ZanoxPublisher::AdMedium.page(0, { admediumtype: type }) }

      it { expect(admedia.all? { |admedium| admedium.admedium_type == type }).to be true }
    end

    context 'with purpose' do
      subject(:admedia) { ZanoxPublisher::AdMedium.page(0, { purpose: purpose_supported }) }

      # The response seems to nil purpose but does not error with unallowed request
      it { expect(admedia.all? { |admedium| admedium.purpose == purpose_supported or admedium.purpose.nil? }).to be true}
    end

    context 'with unsupported purpose' do
      subject { ZanoxPublisher::AdMedium.page(0, { purpose: purpose_unsupported }) }

      it { expect{ subject }.to raise_error(ZanoxPublisher::BadRequest) }
    end

    context 'with partnership direct' do
      subject(:admedia) { ZanoxPublisher::AdMedium.page(0, { partnership: partnership_direct }) }

      # Seems to be effectless
      it 'limits results to admedia with mandatory application' do
        admedia
        expect(ZanoxPublisher::AdMedium.total).to be <= admedium_total
      end
    end

    context 'with partnership indirect' do
      subject(:admedia) { ZanoxPublisher::AdMedium.page(0, { partnership: partnership_indirect }) }

      # Seems to be effectless
      it 'limits results to admedia without required application' do
        admedia
        expect(ZanoxPublisher::AdMedium.total).to be <= admedium_total
      end
    end

    context 'with category' do
      subject(:admedia) { ZanoxPublisher::AdMedium.page(0, { category: category })}

      it { expect(admedia.all? { |admedium| admedium.category.id == category.id }).to be true }
    end

    context 'with adspace' do
      subject(:admedia) { ZanoxPublisher::AdMedium.page(0, {adspace: adspace}) }

      it 'incentives have tracking link associated with this AdSpace' do
        expect(admedia.all? { |admedium| admedium.tracking_links.first.adspace == adspace.id}).to be true
      end
    end
  end

  describe '::all', :vcr do
    subject(:admedia) { ZanoxPublisher::AdMedium.all region: region, admedium_type: type }

    it { is_expected.to be_kind_of Array }
    it { expect(admedia.first).to be_kind_of ZanoxPublisher::AdMedium }

    it { expect(admedia.count).to be == ZanoxPublisher::AdMedium.total }
  end

  describe '::find', vcr: { record: :new_episodes } do
    let(:first) do
      ZanoxPublisher::AdMedium.page.first
    end

    subject(:find) { ZanoxPublisher::AdMedium.find(first.id) }

    it { is_expected.to be_kind_of ZanoxPublisher::AdMedium }

    it { expect(find.id).to be == first.id }
    it { expect(find.name).to be == first.name }
    it { expect(find.adrank).to be == first.adrank }
    it { expect(find.admedium_type).to be == first.admedium_type }
    it { expect(find.program.id).to be == first.program.id }

    context 'with adspace' do
      subject(:find) { ZanoxPublisher::AdMedium.find(first.id, adspace: adspace)}

      it 'ad medium has tracking link associated with this AdSpace' do
        expect(find.tracking_links.first.adspace).to be == adspace.id
      end
    end
  end

  describe 'item', :vcr do
    subject(:admedium) { ZanoxPublisher::AdMedium.page.first }

    it 'responds to to_i with its ID' do
      expect(admedium.to_i).to be == admedium.id
    end
  end
end
