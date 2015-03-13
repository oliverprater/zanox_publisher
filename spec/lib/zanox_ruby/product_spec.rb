require 'spec_helper'

describe ZanoxRuby::Product, :focus do
  before(:all) { ZanoxRuby::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxRuby::authenticate(nil, nil) }

  let(:product_total) do
    ZanoxRuby::Product.page
    ZanoxRuby::Product.total
  end
  let(:query_phrase) { 'mobile' }
  let(:query_contextual) { 'Discover everything iPhone' }
  let(:region) { 'DE' }
  let(:minimum_price) { 10 }
  let(:maximum_price) { 50 }
  let(:programs) { ZanoxRuby::Program.page }
  let(:program) { ZanoxRuby::Program.page.first }
  let(:program_not_confirmed) { ZanoxRuby::Program.page.first }
  let(:adspace) { ZanoxRuby::AdSpace.page.first }
  let(:ean) { ZanoxRuby::Product.page.first.ean }
  let(:merchant_category_ary) { program.categories.map(&:name) }
  let(:merchant_category) { program.categories.first.name }

  describe '::page', :vcr do
    subject(:products) { ZanoxRuby::Product.page }

    it { is_expected.to be_kind_of Array }
    it { expect(products.first).to be_kind_of ZanoxRuby::Product }

    it { expect(products.count).to be > 0 }
    it 'to set the Product total count' do
      ZanoxRuby::Product.total = nil
      products
      expect(ZanoxRuby::Product.total).to be > 0
    end

    context 'with phrase query' do
      subject(:products) { ZanoxRuby::Product.page(0, { query: query_phrase }) }

      it 'limits results to products associated with search string' do
        products
        expect(ZanoxRuby::Product.total).to be < product_total
      end
    end

    # Seems to have no effect
    context 'with contextual query' do
      subject(:products) { ZanoxRuby::Product.page(0, { query: query_contextual }) }

      it 'limits results to products associated with search string' do
        products
        expect(ZanoxRuby::Product.total).to be < product_total
      end
    end

    context 'with q' do
      subject(:products) { ZanoxRuby::Product.page(0, { q: query_contextual }) }

      it 'limits results to products associated with search string' do
        products
        expect(ZanoxRuby::Product.total).to be < product_total
      end
    end

    context 'with region' do
      subject(:products) { ZanoxRuby::Product.page(0, { region: region }) }

      it 'limits results to programs from a particular region' do
        programs = []

        products.each do |product|
          program = ZanoxRuby::Program.find(product.program.id)
          programs << program
        end

        expect(programs.all? { |program| program.regions.include? region }).to be true
      end
    end

    context 'with minimum_price' do
      subject(:products) { ZanoxRuby::Product.page(0, { minimum_price: minimum_price }) }

      it { expect(products.all? { |product| product.price > minimum_price }).to be true }
    end

    context 'with minprice' do
      subject(:products) { ZanoxRuby::Product.page(0, { minprice: minimum_price }) }

      it { expect(products.all? { |product| product.price > minimum_price }).to be true }
    end

    context 'with maximum_price' do
      subject(:products) { ZanoxRuby::Product.page(0, { maximum_price: maximum_price }) }

      it { expect(products.all? { |product| product.price < maximum_price }).to be true }
    end

    context 'with maxprice' do
      subject(:products) { ZanoxRuby::Product.page(0, { maxprice: maximum_price }) }

      it { expect(products.all? { |product| product.price < maximum_price }).to be true }
    end

    context 'with one progam' do
      skip 'need program applications to get confirmed list'
      subject(:products) { ZanoxRuby::Product.page(0, { programs: program }) }

      it { expect(products.all? { |product| product.program.id == program.id }).to be true}
    end

    context 'with multiple programs' do
      skip 'need program applications to get confirmed list'
    end

    context 'with not confirmed program' do
      skip 'need program application to exclude confirmed programs'
      subject(:products) { ZanoxRuby::Product.page(0, { programs: program_not_confirmed })}
      it { expect{subject}.to raise_error(ZanoxRuby::Unauthorized)}
    end

    context 'with has_images' do
      subject(:products) { ZanoxRuby::Product.page(0, { has_images: true }) }

      it { expect(products.all? { |product| product.image != nil }).to be true}
    end

    context 'with hasimages' do
      subject(:products) { ZanoxRuby::Product.page(0, { hasimages: true }) }

      it { expect(products.all? { |product| product.image != nil }).to be true}
    end

    context 'with adspace' do
      subject(:products) { ZanoxRuby::Product.page(0, { adspace: adspace }) }

      it 'products have tracking link associated with this AdSpace' do
        expect(products.all? { |prouct| prouct.tracking_links.first.adspace == adspace.id}).to be true
      end
    end

    context 'with all partnership' do
      subject(:products) { ZanoxRuby::Product.page(0, { partnership: 'all' }) }

      it 'has more products than with confirmed' do
        products
        expect(ZanoxRuby::Product.total).to be > product_total
      end
    end

    context 'with confirmed partnership' do
      subject(:products) { ZanoxRuby::Product.page(0, { partnership: 'confirmed' }) }

      it 'has same products count' do
        products
        expect(ZanoxRuby::Product.total).to be == product_total
      end
    end

    context 'with partnership' do
      subject(:products) { ZanoxRuby::Product.page(0, { ean: ean }) }

      it { expect(products.all? { |product| product.ean == ean }).to be true}
    end

    context 'with merchant_category array' do
      subject(:products) { ZanoxRuby::Product.page(0, { merchant_category: merchant_category_ary }) }

      it { expect(products.all? { |product| merchant_category_ary.include? product.category }).to be true }
    end

    context 'with merchant_category' do
      subject(:products) { ZanoxRuby::Product.page(0, { merchant_category: merchant_category }) }

      it { expect(products.all? { |product| product.category == merchant_category }).to be true }
    end

    context 'with merchantcategory' do
      subject(:products) { ZanoxRuby::Product.page(0, { merchantcategory: merchant_category }) }

      it { expect(products.all? { |product| product.category == merchant_category }).to be true }
    end
  end

  describe '::all', :vcr do
    subject(:products) { ZanoxRuby::Product.all query: query_phrase, region: region, minimum_price: minimum_price }

    it { is_expected.to be_kind_of Array }
    it { expect(products.first).to be_kind_of ZanoxRuby::Product }

    it { expect(products.count).to be == ZanoxRuby::Product.total }
  end

  describe '::find', vcr: { record: :new_episodes } do
    let(:first) do
      ZanoxRuby::Product.page.first
    end

    subject(:find) { ZanoxRuby::Product.find(first.id) }

    it { is_expected.to be_kind_of ZanoxRuby::Product }

    it { expect(find.id).to be == first.id }
    it { expect(find.name).to be == first.name }
    it { expect(find.program.id).to be == first.program.id }
    it { expect(find.price).to be == first.price }
    it { expect(find.currency).to be == first.currency }

    # Seems to be implementation error in Zanox API
    context 'with adspace' do
      subject(:find) { ZanoxRuby::Product.find(first.id, adspace: adspace)}

      it { expect(find.tracking_links.first.adspace). to be == adspace.id }
    end
  end
end
