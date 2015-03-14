require 'spec_helper'

describe ZanoxPublisher::Program do
  before(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxPublisher::authenticate(nil, nil) }

  let(:query_phrase) { 'mobile' }
  let(:query_contextual) { 'Discover everything iPhone, including the most advanced mobile OS in its most advanced form and great apps that let you be creative and productive.' }
  let(:program_total) do
    ZanoxPublisher::Program.page
    ZanoxPublisher::Program.total
  end
  let(:start_date) { Date.new(2011, 3, 1)}
  let(:region) { 'DE' }
  let(:partnership_direct) { 'DIRECT' }
  let(:partnership_indirect) { 'INDIRECT' }
  let(:partnership_other) { 'random' }
  let(:has_products) { true }
  let(:has_no_products) { false }

  describe '::page', :vcr do
    subject(:programs) { ZanoxPublisher::Program.page }


    it { is_expected.to be_kind_of Array }
    it { expect(programs.first).to be_kind_of ZanoxPublisher::Program }

    it { expect(programs.count).to be > 0 }
    it 'to set the Program total count' do
      ZanoxPublisher::Program.total = nil
      programs
      expect(ZanoxPublisher::Program.total).to be > 0
    end

    context 'with phrase query' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { query: query_phrase }) }

      it 'limits results to programs associated with search string' do
        programs
        expect(ZanoxPublisher::Program.total).to be < program_total
      end
    end

    context 'with contextual query' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { query: query_contextual }) }

      it 'limits results to programs associated with search string' do
        programs
        expect(ZanoxPublisher::Program.total).to be < program_total
      end
    end

    context 'with q' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { q: query_phrase }) }

      it 'limits results to programs associated with search string' do
        programs
        expect(ZanoxPublisher::Program.total).to be < program_total
      end
    end

    context 'with start_date' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { start_date: start_date }) }

      it { expect(programs.all? { |program| program.start_date > start_date }).to be true }
    end

    context 'with region' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { region: region }) }

      it { expect(programs.all? { |program| program.regions.include? region }).to be true }
    end

    context 'with direct partnership' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { partnership: partnership_direct }) }

      it 'limits results to programs with mandatory application' do
        programs
        expect(ZanoxPublisher::Program.total).to be < program_total
      end

      it { expect(programs.all? { |o| o.application_required == true }).to be true }
    end

    context 'with indirect partnership' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { partnership: partnership_indirect }) }

      it 'limits results to programs without application requirement' do
        programs
        expect(ZanoxPublisher::Program.total).to be < program_total
      end

      it { expect(programs.all? { |o| o.application_required == false }).to be true }
    end

    context 'with random partnership' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { partnership: partnership_other }) }

      it { expect{ programs }.to raise_error(ZanoxPublisher::BadRequest) }
    end

    context 'with has_products' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { has_products: has_products })}

      it 'limits results to programs with products' do
        programs
        expect(ZanoxPublisher::Program.total).to be < program_total
      end
    end

    context 'with hasproducts' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { hasproducts: has_products })}

      it 'limits results to programs with products' do
        programs
        expect(ZanoxPublisher::Program.total).to be < program_total
      end
    end

    context 'with has_products other than true' do
      subject(:programs) { ZanoxPublisher::Program.page(0, { has_products: has_no_products })}

      it 'has no effect on results' do
        programs
        expect(ZanoxPublisher::Program.total).to be == program_total
      end
    end
  end

  describe '::all', :vcr do
    subject(:programs) { ZanoxPublisher::Program.all region: region, has_products: true, partnership: partnership_direct }

    it { is_expected.to be_kind_of Array }
    it { expect(programs.first).to be_kind_of ZanoxPublisher::Program }

    it { expect(programs.count).to be == ZanoxPublisher::Program.total }
    it { expect(programs.all? { |program| program.regions.include?(region) and program.application_required == true }).to be true}
  end

  describe '::find', vcr: { record: :new_episodes } do
    let(:first) do
      ZanoxPublisher::Program.page.first
    end

    subject(:find) { ZanoxPublisher::Program.find(first.id) }

    it { is_expected.to be_kind_of ZanoxPublisher::Program }

    it { expect(find.id).to be == first.id }
    it { expect(find.name).to be == first.name }
    it { expect(find.adrank).to be == first.adrank }
    it { expect(find.application_required).to be == first.application_required }
    it { expect(find.description).to be == first.description }
  end

  describe '::categories', :vcr do
    subject { ZanoxPublisher::Program.categories }

    it { is_expected.to be_kind_of Array }
    it { expect(subject.first).to be_kind_of ZanoxPublisher::Category }
    it { expect(subject.count).to be > 0 }
  end

  describe 'item', :vcr do
    subject(:progam) { ZanoxPublisher::Program.page.first }

    it 'responds to to_i with its ID' do
      expect(progam.to_i).to be == progam.id
    end
  end

  describe '#admedia_categories', vcr: { record: :new_episodes } do
    subject(:progam) { ZanoxPublisher::Program.page.first }

    it { is_expected.to respond_to :admedia_categories }
    it { expect(progam.admedia_categories).to be_kind_of Array }
    it { expect(progam.admedia_categories.count).to be > 0 }
    it { expect(progam.admedia_categories.first).to be_kind_of ZanoxPublisher::Category }
  end
end
