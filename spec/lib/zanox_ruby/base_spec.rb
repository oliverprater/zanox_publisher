require 'spec_helper'

describe ZanoxRuby::Base do
  subject { ZanoxRuby::Base }

  it { is_expected.to respond_to :maximum_per_page }

  it { is_expected.to respond_to :per_page }
  it { is_expected.to respond_to :per_page= }

  it { is_expected.to respond_to :total }
  it { is_expected.to respond_to :total= }

  # The order can not be :random here but must follow code definition
  describe "::per_page", :order => :defined do
    subject { ZanoxRuby::Base.per_page }

    it { is_expected.to be == ZanoxRuby::Base.class_variable_get(:@@default_per_page) }

    it "is greater than or equal to 0" do
      ZanoxRuby::Base.per_page = -1
      expect(subject).to be == 0
    end

    it "is not greater than the maximum page size" do
      ZanoxRuby::Base.per_page = 1_000_000
      expect(subject).to be == ZanoxRuby::Base.class_variable_get(:@@maximum_per_page)
    end

    it "accepts valid values" do
      ZanoxRuby::Base.per_page = 5
      expect(subject).to be == 5
    end
  end
end
