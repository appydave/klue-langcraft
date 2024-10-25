# frozen_string_literal: true

RSpec.describe Klue::Langcraft::DSL::Processors::Processor do
  let(:data) { { 'as' => 'custom_name', key1: 'value1', key2: 'value2' } }
  let(:key) { :file_collector } # The key for the processor
  let(:processor_class) { described_class }

  describe '#initialize' do
    it 'stores a deep cloned version of the provided data' do
      processor = processor_class.new(data, key)

      # Modify the cloned data inside the processor
      processor.data[:key1] = 'modified_value'

      # Ensure the original data is not affected by the modification
      expect(data[:key1]).to eq('value1') # Original data remains unchanged
    end

    it 'stores the provided key' do
      processor = processor_class.new(data, key)
      expect(processor.key).to eq(key)
    end
  end

  describe '.keys' do
    it 'raises NotImplementedError when called on the base Processor class' do
      expect { processor_class.keys }.to raise_error(NotImplementedError)
    end
  end

  describe '#build_result_data' do
    it 'raises NotImplementedError when called on the base Processor class' do
      processor = processor_class.new(data, key)
      expect { processor.build_result_data }.to raise_error(NotImplementedError)
    end
  end

  describe '#build_result' do
    let(:index) { 1 }

    it 'builds the result envelope with the provided key and index' do
      processor = processor_class.new(data, key)

      # Stubbing `build_result_data` to avoid raising an error
      allow(processor).to receive(:build_result_data).and_return({ files: 'collected files list' })

      result = processor.build_result

      expect(result).to eq({
                             name: 'custom_name',
                             type: 'file_collector',
                             data: { files: 'collected files list' }
                           })
    end

    it 'defaults the name to key-index if no `as` key is provided' do
      data_without_as = { key1: 'value1', key2: 'value2' }
      processor = processor_class.new(data_without_as, key)

      # Stubbing `build_result_data` to avoid raising an error
      allow(processor).to receive(:build_result_data).and_return({ files: 'collected files list' })

      result = processor.build_result

      # Name will get calculated as 'file_collector-1' in process data pipeline
      expect(result).to eq(
        name: nil,
        type: 'file_collector',
        data: { files: 'collected files list' }
      )
    end
  end
end
