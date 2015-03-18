require 'spec_helper'

describe ZanoxPublisher::Incentive do
  before(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxPublisher::authenticate(nil, nil) }

  let(:program) { ZanoxPublisher::Program.page.first }
  let(:adspace) { ZanoxPublisher::AdSpace.page.first }
  let(:incentive_type) { ZanoxPublisher::Incentive::incentive_types.first }
  let(:region) { 'DE' }
  let(:incentives_total) do
    ZanoxPublisher::Incentive.page
    ZanoxPublisher::Incentive.total
  end

  describe '::page', :vcr do
    subject(:incentives) { ZanoxPublisher::Incentive.page }

    it { is_expected.to be_kind_of Array }
    it { expect(incentives.first).to be_kind_of ZanoxPublisher::Incentive }

    it { expect(incentives.count).to be >= 0 }
    it 'to set the Incentive total count' do
      ZanoxPublisher::Incentive.total = nil
      incentives
      expect(ZanoxPublisher::Incentive.total).to be >= 0
    end
    it { expect(incentives.all? { |incentive| incentive.exclusive == false}).to be true}

    context 'page size is one' do
      subject(:incentive) { ZanoxPublisher::Incentive.page(0, per_page: 1) }

      it { is_expected.to be_kind_of Array }
      it { expect(incentive.first).to be_kind_of ZanoxPublisher::Incentive }
      it { expect(incentive.count).to be == 1 }
    end

    context 'with progam' do
      subject(:incentives) { ZanoxPublisher::Incentive.page(0, program: program) }

      it { expect(incentives.all? { |incentive| incentive.program.id == program.id }).to be true }
    end

    context 'with adspace' do
      subject(:incentives) { ZanoxPublisher::Incentive.page(0, adspace: adspace) }

      it 'incentives have tracking link associated with this AdSpace' do
        admedia = incentives.map { |incentive| incentive.admedia }
        expect(admedia.all? { |admedium| admedium.tracking_links.first.adspace == adspace.id}).to be true
      end
    end

    context 'with incentive_type' do
      subject(:incentives) { ZanoxPublisher::Incentive.page(0, incentive_type: incentive_type ) }

      it { expect(incentives.all? { |incentive| incentive.incentive_type == incentive_type }).to be true }
    end

    context 'with incentiveType' do
      subject(:incentives) { ZanoxPublisher::Incentive.page(0, incentiveType: incentive_type ) }

      it { expect(incentives.all? { |incentive| incentive.incentive_type == incentive_type }).to be true }
    end

    context 'with region' do
      subject(:incentives) { ZanoxPublisher::Incentive.page(0, region: region) }

      it 'limits results to programs from a particular region' do
        programs = []

        incentives.each do |incentive|
          program = ZanoxPublisher::Program.find(incentive.program)
          programs << program
        end

        expect(programs.all? { |program| program.regions.include? region }).to be true
      end
    end
  end

  describe '::all', :vcr do
    subject(:incentives) { ZanoxPublisher::Incentive.all region: region, incentive_type: incentive_type }

    it { is_expected.to be_kind_of Array }
    it { expect(incentives.first).to be_kind_of ZanoxPublisher::Incentive }

    it { expect(incentives.count).to be == ZanoxPublisher::Incentive.total }
  end

  describe '::find', vcr: { record: :new_episodes } do
    let(:first) do
      ZanoxPublisher::Incentive.page(0, adspace: adspace).first
    end

    subject(:find) { ZanoxPublisher::Incentive.find(first) }

    it { is_expected.to be_kind_of ZanoxPublisher::Incentive }

    it { expect(find.id).to be == first.id }
    it { expect(find.name).to be == first.name }
    it { expect(find.incentive_type).to be == first.incentive_type }
    it { expect(find.admedia.id).to be == first.admedia.id }
    it { expect(find.program.id).to be == first.program.id }

    # Seems to be implementation error in Zanox API
    context 'with adspace' do
      subject(:find) { ZanoxPublisher::Incentive.find(first, adspace: adspace)}

      it { expect(find.admedia.tracking_links.first.adspace).to be == adspace.id }
    end
  end
end
