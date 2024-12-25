# frozen_string_literal: true

RSpec.describe Klue::Langcraft::DSL::Processors::FileCollectorProcessor do
  let(:data) { { 'as' => 'custom_file_list' } }
  let(:key) { :file_collector } # Define the key
  let(:processor) { described_class.new(data, key) } # Pass both data and key to initialize

  describe '.keys' do
    it 'returns the correct keys for FileCollectorProcessor' do
      expect(described_class.keys).to eq([:file_collector])
    end
  end

  describe '#build_result_data' do
    it 'returns the collected files data' do
      expect(processor.build_result_data).to eq({ files: ['file1.txt', 'file2.txt'] })
    end

    fit 'processes file collector data without errors' do
      data = {
        'root' => '~/dev/printspeak/printspeak-master',
        'as' => 'file_db_erd',
        'files' => {
          'include' => {
            'p1' => 'app/controllers/admin/*.rb'
          }
        }
      }
      processor = described_class.new(data, :file_collector)
      result = processor.build_result_data
      puts JSON.pretty_generate(result)
      # No expectation, just ensuring it runs without errors
    end
  end

  describe '#build_result' do
    it 'builds the result envelope with the custom name from `as` key' do
      result = processor.build_result
      expect(result).to eq({
                             name: 'custom_file_list',
                             type: 'file_collector',
                             data: { files: ['file1.txt', 'file2.txt'] }
                           })
    end

    it 'builds the result envelope with a default name when no `as` key is provided' do
      processor_without_as = described_class.new({}, key)
      result = processor_without_as.build_result
      expect(result).to eq({
                             name: nil,
                             type: 'file_collector',
                             data: { files: ['file1.txt', 'file2.txt'] }
                           })
    end
  end
end
