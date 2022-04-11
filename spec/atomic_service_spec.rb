require 'atomic_service'

describe AtomicService do
  let(:service) { Service.new }

  before do
    stub_const('Service', AtomicService)
    allow(service).to receive(:execute)
    service.instance_variable_set('@variable', 'i\'m an instance variable')
  end

  describe '.call' do
    it "returns instance of Service" do
      service_instance_double = double
      expect(Service).to receive(:new) { service_instance_double }
      expect(service_instance_double).to receive(:call) { true }
      expect(Service.call).to be(service_instance_double)
    end
  end

  describe '#call' do
    context 'given execution succeeds' do
      it "returns true" do
        allow(service).to receive(:valid?) { true }
        expect(service.call).to eql(true)
      end
    end

    context 'given execution fails' do
      it "returns false" do
        allow(service).to receive(:valid?) { false }
        expect(service.call).to eql(false)
      end
    end
  end

  describe '#call!' do
    context 'given execution succeeds' do
      it "returns true" do
        allow(service).to receive(:valid?) { true }
        expect(service.call!).to eql(true)
      end
    end

    context 'given execution fails' do
      it "returns false" do
        allow(service).to receive(:valid?) { false }
        expect{service.call!}.to raise_error(StandardError)
      end
    end
  end

  describe '#formatted_errors' do
    context 'given execution succeeds' do
      it "returns empty array" do
        allow(service).to receive(:valid?) { true }
        service.call
        expect(service.formatted_errors).to match_array([])
      end
    end

    context 'given execution fails' do
      it "returns array with errors" do
        allow(service).to receive(:valid?) { service.errors.add(:variable, 'error'); false }
        service.call
        expect(service.formatted_errors).to match_array(['Variable error'])
      end
    end
  end

  describe '#successful?' do
    context 'given execution succeeds' do
      it "returns empty array" do
        allow(service).to receive(:valid?) { true }
        service.call
        expect(service.successful?).to be_truthy
      end
    end

    context 'given execution fails' do
      it "returns array with errors" do
        allow(service).to receive(:valid?) { service.errors.add(:variable, 'error'); false }
        service.call
        expect(service.successful?).to be_falsy
      end
    end
  end

  describe '#passed_initial_validation?' do
    context 'given before execution' do
      it "returns empty array" do
        expect(service.passed_initial_validation?).to be_nil
      end
    end

    context 'given after execution failed on initial validation' do
      it "returns empty array" do
        allow(service).to receive(:valid?) { false }
        service.call
        expect(service.passed_initial_validation?).to be(false)
      end
    end

    context 'given after execution succeeded on initial validation' do
      it "returns empty array" do
        allow(service).to receive(:valid?) { true }
        service.call
        expect(service.passed_initial_validation?).to be(true)
      end
    end
  end
end
