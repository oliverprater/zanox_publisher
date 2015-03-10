require 'spec_helper'

describe ZanoxRuby::AdMedium do
  before(:all) { ZanoxRuby::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxRuby::authenticate(nil, nil) }

  let(:program) { ZanoxRuby::Program.page.first }
  let(:category) { program.categories.first }
  let(:region) { 'DE' }
  let(:format) { 4 }
  let(:type) { ZanoxRuby::AdMedium.const_get(:ADMEDIA_TYPE_ENUM).first }
  let(:purpose_supported) { ZanoxRuby::AdMedium.const_get(:ADMEDIA_PURPOSE_ENUM)[1] }
  let(:purpose_unsupported) { ZanoxRuby::AdMedium.const_get(:ADMEDIA_PURPOSE_ENUM).last }
  let(:partnership_direct) { 'DIRECT' }
  let(:partnership_indirect) { 'INDIRECT' }
  let(:adspace) { ZanoxRuby::Profile.first }
  let(:admedium_total) do
    ZanoxRuby::AdMedium.page
    ZanoxRuby::AdMedium.total
  end

  describe '::page', :vcr do
    subject(:admedia) { ZanoxRuby::AdMedium.page }

    it { is_expected.to be_kind_of Array }
    it { expect(admedia.first).to be_kind_of ZanoxRuby::AdMedium }

    it { expect(admedia.count).to be > 0 }
    it 'to set the AdMedium total count' do
      ZanoxRuby::AdMedium.total = nil
      admedia
      expect(ZanoxRuby::AdMedium.total).to be > 0
    end

    context 'with program', vcr: { record: :new_episodes } do
      subject(:admedia) { ZanoxRuby::AdMedium.page(0, { program: program }) }

      it { expect(admedia.all? { |admedium| admedium.program.id == program.id }).to be true }
    end

    context 'with region', vcr: { record: :new_episodes } do
      subject(:admedia) { ZanoxRuby::AdMedium.page(0, { region: region }) }

      it 'limits results to programs from a particular region' do
        programs = []

        admedia.each do |admedium|
          program = ZanoxRuby::Program.find(admedium.program.id)
          programs << program
        end

        expect(programs.all? { |program| program.regions.include? region }).to be true
      end
    end

    context 'with format' do
      subject(:admedia) { ZanoxRuby::AdMedium.page(0 , { format: format }) }

      it { expect(admedia.all? { |admedium| admedium.format.id == format }).to be true }
    end

    context 'with admedium_type' do
      subject(:admedia) { ZanoxRuby::AdMedium.page(0, { admedium_type: type }) }

      it { expect(admedia.all? { |admedium| admedium.admedium_type == type }).to be true }
    end

    context 'with admediumtype' do
      subject(:admedia) { ZanoxRuby::AdMedium.page(0, { admediumtype: type }) }

      it { expect(admedia.all? { |admedium| admedium.admedium_type == type }).to be true }
    end

    context 'with purpose' do
      subject(:admedia) { ZanoxRuby::AdMedium.page(0, { purpose: purpose_supported }) }

      # The response seems to nil purpose but does not error with unallowed request
      it { expect(admedia.all? { |admedium| admedium.purpose == purpose_supported or admedium.purpose.nil? }).to be true}
    end

    context 'with unsupported purpose' do
      subject { ZanoxRuby::AdMedium.page(0, { purpose: purpose_unsupported }) }

      it { expect{ subject }.to raise_error(ZanoxRuby::BadRequest) }
    end

    context 'with partnership direct' do
      subject(:admedia) { ZanoxRuby::AdMedium.page(0, { partnership: partnership_direct }) }

      # Seems to be effectless
      it 'limits results to admedia with mandatory application' do
        admedia
        expect(ZanoxRuby::AdMedium.total).to be <= admedium_total
      end
    end

    context 'with partnership indirect' do
      subject(:admedia) { ZanoxRuby::AdMedium.page(0, { partnership: partnership_indirect }) }

      # Seems to be effectless
      it 'limits results to admedia without required application' do
        admedia
        expect(ZanoxRuby::AdMedium.total).to be <= admedium_total
      end
    end

    context 'with category' do
      subject(:admedia) { ZanoxRuby::AdMedium.page(0, { category: category })}

      it { expect(admedia.all? { |admedium| admedium.category.id == category.id }).to be true }
    end

    # Seems to be an implementation error on Zanox side
    context 'with adspace' do
      let(:total) { ZanoxRuby::AdMedium.page.count }
      subject(:admedia) { ZanoxRuby::AdMedium.page(0, {adspace: adspace}) }

      #it { expect(admedia.count).to be < total }
      it { expect{ admedia }.to raise_error(ZanoxRuby::ServerError) }
    end
  end

  describe '::all', :vcr do
    subject(:admedia) { ZanoxRuby::AdMedium.all region: region, admedium_type: type }

    it { is_expected.to be_kind_of Array }
    it { expect(admedia.first).to be_kind_of ZanoxRuby::AdMedium }

    it { expect(admedia.count).to be == ZanoxRuby::AdMedium.total }
  end

  describe '::find', vcr: { record: :new_episodes } do
    let(:first) do
      ZanoxRuby::AdMedium.page.first
    end

    subject(:find) { ZanoxRuby::AdMedium.find(first.id) }

    it { is_expected.to be_kind_of ZanoxRuby::AdMedium }

    it { expect(find.id).to be == first.id }
    it { expect(find.name).to be == first.name }
    it { expect(find.adrank).to be == first.adrank }
    it { expect(find.admedium_type).to be == first.admedium_type }
    it { expect(find.program.id).to be == first.program.id }

    # Seems to be implementation error in Zanox API
    context 'with adspace' do
      subject(:find) { ZanoxRuby::AdMedium.find(first.id, adspace: adspace)}

      it { expect{ find }.to raise_error(ZanoxRuby::ServerError) }
    end
  end

  describe 'item', :vcr do
    subject(:admedium) { ZanoxRuby::AdMedium.page.first }

    it 'responds to to_i with its ID' do
      expect(admedium.to_i).to be == admedium.id
    end
  end
end
