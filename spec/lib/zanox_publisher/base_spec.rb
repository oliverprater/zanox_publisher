require 'spec_helper'

describe ZanoxPublisher::Base do
  subject { ZanoxPublisher::Base }

  it { is_expected.to respond_to :maximum_per_page }

  it { is_expected.to respond_to :per_page }
  it { is_expected.to respond_to :per_page= }

  it { is_expected.to respond_to :total }
  it { is_expected.to respond_to :total= }

  # The order can not be :random here but must follow code definition
  describe "::per_page", :order => :defined do
    subject { ZanoxPublisher::Base.per_page }

    it { is_expected.to be == ZanoxPublisher::Base.class_variable_get(:@@default_per_page) }

    it "is greater than or equal to 0" do
      ZanoxPublisher::Base.per_page = -1
      expect(subject).to be == 0
    end

    it "is not greater than the maximum page size" do
      ZanoxPublisher::Base.per_page = 1_000_000
      expect(subject).to be == ZanoxPublisher::Base.class_variable_get(:@@maximum_per_page)
    end

    it "accepts valid values" do
      ZanoxPublisher::Base.per_page = 5
      expect(subject).to be == 5
    end
  end
end
