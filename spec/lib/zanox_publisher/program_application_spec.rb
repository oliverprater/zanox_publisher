require 'spec_helper'

describe ZanoxPublisher::ProgramApplication do
  before(:all) { ZanoxPublisher::authenticate(credentials['connect_id'], credentials['secret_key']) }
  after(:all) { ZanoxPublisher::authenticate(nil, nil) }

  let(:program) { ZanoxPublisher::Program.page.first }
  let(:adspace) { ZanoxPublisher::AdSpace.page.first }
  let(:status)  { ZanoxPublisher::ProgramApplication.const_get(:PROGRAM_APPLICATION_STATUS_ENUM).first }

  describe '::page', :vcr do
    subject(:applications) { ZanoxPublisher::ProgramApplication.page }

    it { is_expected.to be_kind_of Array }
    it { expect(applications.first).to be_kind_of ZanoxPublisher::ProgramApplication }

    it { expect(applications.count).to be > 0 }
    it 'to set the ProgramApplication total count' do
      ZanoxPublisher::ProgramApplication.total = nil
      applications
      expect(ZanoxPublisher::ProgramApplication.total).to be > 0
    end

    context 'with program' do
      subject(:applications) { ZanoxPublisher::ProgramApplication.page(0, program: program) }

      it { expect(applications.all? { |application| application.program.id == program.id }).to be true }
    end

    context 'with adspace' do
      subject(:applications) { ZanoxPublisher::ProgramApplication.page(0, adspace: adspace) }

      it { expect(applications.all? { |application| application.adspace.id == adspace.id }).to be true }
    end

    context 'with status' do
      subject(:applications) { ZanoxPublisher::ProgramApplication.page(0, status: status) }

      it { expect(applications.all? { |application| application.status == status }).to be true }
    end
  end

  describe '::all' , :vcr do
    subject(:applications) { ZanoxPublisher::ProgramApplication.all adspace: adspace }

    it { is_expected.to be_kind_of Array }
    it { expect(applications.first).to be_kind_of ZanoxPublisher::ProgramApplication }

    it { expect(applications.count).to be == ZanoxPublisher::ProgramApplication.total }
  end
end
