# frozen_string_literal: true

# file: spec/klue/langcraft/dsl/processor_config_spec.rb

RSpec.describe Klue::Langcraft::DSL::ProcessorConfig do
  let(:processor_config) { described_class.new }

  let(:dummy_processor_class) do
    Class.new do
      def self.keys
        :dummy_processor
      end
    end
  end

  let(:multi_key_processor_class) do
    Class.new do
      def self.keys
        %i[multi_key_processor alias_processor]
      end
    end
  end

  describe '.register_processor' do
    it 'registers a processor with its associated keys' do
      processor_config.register_processor(dummy_processor_class)

      expect(processor_config.processor_for(:dummy_processor)).to eq(dummy_processor_class)
    end

    it 'registers a processor with multiple keys' do
      processor_config.register_processor(multi_key_processor_class)

      expect(processor_config.processor_for(:multi_key_processor)).to eq(multi_key_processor_class)
      expect(processor_config.processor_for(:alias_processor)).to eq(multi_key_processor_class)
    end
  end

  describe '.processor_for' do
    it 'returns nil when the processor is not registered' do
      expect(processor_config.processor_for(:unknown_processor)).to be_nil
    end

    it 'returns the correct processor class when registered' do
      processor_config.register_processor(dummy_processor_class)
      expect(processor_config.processor_for(:dummy_processor)).to eq(dummy_processor_class)
    end
  end

  describe '.all_processors' do
    it 'returns all registered processors' do
      processor_config.register_processor(dummy_processor_class)
      processor_config.register_processor(multi_key_processor_class)

      expected_processors = {
        dummy_processor: dummy_processor_class,
        multi_key_processor: multi_key_processor_class,
        alias_processor: multi_key_processor_class
      }

      expect(processor_config.all_processors).to eq(expected_processors)
    end
  end

  describe 'ProcessorConfigDefault.all_processors' do
    it { expect(ProcessorConfigDefault.all_processors).to include(:file_collector, :full_name) }
  end
end
