require 'rails_helper'

RSpec.describe Carts::RemoveAbandonedJob, type: :job do
  describe '#perform' do
    it 'calls the RemoveAbandoned service' do
      expect(Carts::RemoveAbandoned).to receive(:call)
      subject.perform
    end
  end

  describe 'job configuration' do
    it 'uses the default queue' do
      expect(described_class.queue_name).to eq('default')
    end

    it 'has 3 retry attempts' do
      expect(described_class.sidekiq_options['retry']).to eq(3)
    end
  end
end