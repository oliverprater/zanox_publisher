require 'spec_helper'

describe ZanoxRuby::Incentive do
  before(:all) { ZanoxRuby::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxRuby::authenticate(nil, nil) }

  let(:program) { ZanoxRuby::Program.page.first }
  let(:adspace) { ZanoxRuby::AdSpace.page.first }
  let(:incentive_type) { ZanoxRuby::Incentive.const_get(:INCENTIVETYPEENUM ).first }
  let(:region) { 'DE' }
  let(:incentives_total) do
    ZanoxRuby::Incentive.page
    ZanoxRuby::Incentive.total
  end
  let(:exclusive_incentives_total) do
    ZanoxRuby::Incentive.page(0, true)
    ZanoxRuby::Incentive.total
  end

  describe '::page', :vcr do
    context 'with non-exclusive incentives' do
      subject(:incentives) { ZanoxRuby::Incentive.page }

      it { is_expected.to be_kind_of Array }
      it { expect(incentives.first).to be_kind_of ZanoxRuby::Incentive }

      it { expect(incentives.count).to be > 0 }
      it 'to set the Incentive total count' do
        ZanoxRuby::Incentive.total = nil
        incentives
        expect(ZanoxRuby::Incentive.total).to be > 0
      end
      it { expect(incentives.all? { |incentive| incentive.exclusive == false}).to be true}

      context 'with progam' do
        subject(:incentives) { ZanoxRuby::Incentive.page(0, false, program: program) }

        it { expect(incentives.all? { |incentive| incentive.program.id == program.id }).to be true }
      end

      context 'with adspace' do
        subject(:incentives) { ZanoxRuby::Incentive.page(0, false, adspace: adspace) }

        it 'incentives have tracking link associated with this AdSpace' do
          admedia = incentives.map { |incentive| incentive.admedia }
          expect(admedia.all? { |admedium| admedium.tracking_links.first.adspace == adspace.id}).to be true
        end
      end

      context 'with incentive_type' do
        subject(:incentives) { ZanoxRuby::Incentive.page(0, false, incentive_type: incentive_type ) }

        it { expect(incentives.all? { |incentive| incentive.incentive_type == incentive_type }).to be true }
      end

      context 'with incentiveType' do
        subject(:incentives) { ZanoxRuby::Incentive.page(0, false, incentiveType: incentive_type ) }

        it { expect(incentives.all? { |incentive| incentive.incentive_type == incentive_type }).to be true }
      end

      context 'with region' do
        subject(:incentives) { ZanoxRuby::Incentive.page(0, false, region: region) }

        it 'limits results to programs from a particular region' do
          programs = []

          incentives.each do |incentive|
            program = ZanoxRuby::Program.find(incentive.program.id)
            programs << program
          end

          expect(programs.all? { |program| program.regions.include? region }).to be true
        end
      end
    end

    context 'with exclusive incentives' do
      subject(:incentives) { ZanoxRuby::Incentive.page(0, true) }

      it { is_expected.to be_kind_of Array }
      it { expect(incentives.first).to be_kind_of ZanoxRuby::Incentive }

      it { expect(incentives.count).to be > 0 }
      it 'to set the Incentive total count' do
        ZanoxRuby::Incentive.total = nil
        incentives
        expect(ZanoxRuby::Incentive.total).to be > 0
      end
      it { expect(incentives.all? { |incentive| incentive.exclusive == true}).to be true}

      context 'with progam' do
        subject(:incentives) { ZanoxRuby::Incentive.page(0, true, program: program) }

        it { expect(incentives.all? { |incentive| incentive.program.id == program.id }).to be true }
      end

      context 'with adspace' do
        subject(:incentives) { ZanoxRuby::Incentive.page(0, true, adspace: adspace) }

        it 'incentives have tracking link associated with this AdSpace' do
          admedia = incentives.map { |incentive| incentive.admedia }
          expect(admedia.all? { |admedium| admedium.tracking_links.first.adspace == adspace.id}).to be true
        end
      end

      context 'with incentive_type' do
        subject(:incentives) { ZanoxRuby::Incentive.page(0, true, incentive_type: incentive_type ) }

        it { expect(incentives.all? { |incentive| incentive.incentive_type == incentive_type }).to be true }
      end

      context 'with incentiveType' do
        subject(:incentives) { ZanoxRuby::Incentive.page(0, true, incentiveType: incentive_type ) }

        it { expect(incentives.all? { |incentive| incentive.incentive_type == incentive_type }).to be true }
      end

      context 'with region' do
        subject(:incentives) { ZanoxRuby::Incentive.page(0, true, region: region) }

        it 'limits results to programs from a particular region' do
          programs = []

          incentives.each do |incentive|
            program = ZanoxRuby::Program.find(incentive.program.id)
            programs << program
          end

          expect(programs.all? { |program| program.regions.include? region }).to be true
        end
      end
    end

    describe '::all', :vcr do
      subject(:incentives) { ZanoxRuby::Incentive.all region: region, incentive_type: incentive_type }

      it { is_expected.to be_kind_of Array }
      it { expect(incentives.first).to be_kind_of ZanoxRuby::Incentive }

      it { expect(incentives.count).to be == ZanoxRuby::Incentive.total }
    end

    describe '::find', vcr: { record: :new_episodes } do
      context 'with non-exclusive incentives' do
        let(:first) do
          ZanoxRuby::Incentive.page(0, false, adspace: adspace).first
        end

        subject(:find) { ZanoxRuby::Incentive.find(first.id) }

        it { is_expected.to be_kind_of ZanoxRuby::Incentive }

        it { expect(find.id).to be == first.id }
        it { expect(find.name).to be == first.name }
        it { expect(find.incentive_type).to be == first.incentive_type }
        it { expect(find.admedia.id).to be == first.admedia.id }
        it { expect(find.program.id).to be == first.program.id }

        # Seems to be implementation error in Zanox API
        context 'with adspace' do
          subject(:find) { ZanoxRuby::Incentive.find(first.id, false, adspace: adspace)}

          it { expect(find.admedia.tracking_links.first.adspace).to be == adspace.id }
        end
      end
      context 'with exclusive incentives' do
        let(:first) do
          ZanoxRuby::Incentive.page(0, true, adspace: adspace).first
        end

        subject(:find) { ZanoxRuby::Incentive.find(first.id, true) }

        it { is_expected.to be_kind_of ZanoxRuby::Incentive }

        it { expect(find.id).to be == first.id }
        it { expect(find.name).to be == first.name }
        it { expect(find.incentive_type).to be == first.incentive_type }
        it { expect(find.admedia.id).to be == first.admedia.id }
        it { expect(find.program.id).to be == first.program.id }

        # Seems to be implementation error in Zanox API
        context 'with adspace' do
          subject(:find) { ZanoxRuby::Incentive.find(first.id, true, adspace: adspace)}

          it { expect(find.admedia.tracking_links.first.adspace).to be == adspace.id }
        end
      end
    end
  end
end
