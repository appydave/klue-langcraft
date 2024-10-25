# frozen_string_literal: true

RSpec.describe Klue::Langcraft::DSL::ProcessDataPipeline do
  let(:matcher) { Klue::Langcraft::DSL::ProcessMatcher.new }
  let(:pipeline) { described_class.new(matcher) }

  describe '#execute' do
    subject { pipeline.execute(data)['process-data'] }

    context 'when fullname process matches' do
      context 'when as: is not supplied' do
        let(:data) do
          {
            'some_root' => {
              'full_name' => { 'first_name' => 'John', 'last_name' => 'Doe' }
            }
          }
        end

        it { is_expected.to include('full_name-1' => { name: 'full_name-1', type: 'full_name', data: { full_name: 'John Doe' } }) }

        context 'when multiple fullname matches supplied' do
          let(:data) do
            {
              'some_root' => {
                'full_name' => [
                  { 'first_name' => 'John', 'last_name' => 'Doe' },
                  { 'first_name' => 'John', 'last_name' => 'Doe' },
                  { 'first_name' => 'John', 'last_name' => 'Doe' }
                ]
              }
            }
          end

          it { is_expected.to include('full_name-1' => { name: 'full_name-1', type: 'full_name', data: { full_name: 'John Doe' } }) }
          it { is_expected.to include('full_name-2' => { name: 'full_name-2', type: 'full_name', data: { full_name: 'John Doe' } }) }
          it { is_expected.to include('full_name-3' => { name: 'full_name-3', type: 'full_name', data: { full_name: 'John Doe' } }) }
        end
      end

      context 'when as: FULLNAME' do
        let(:data) do
          {
            'some_root' => {
              'full_name' => { 'first_name' => 'John', 'last_name' => 'Doe', 'as' => 'FULLNAME' }
            }
          }
        end

        it { is_expected.to include('FULLNAME' => { name: 'FULLNAME', type: 'full_name', data: { full_name: 'John Doe' } }) }

        context 'when multiple fullname matches supplied' do
          let(:data) do
            {
              'some_root' => {
                'full_name' => [
                  { 'first_name' => 'John', 'last_name' => 'Doe', 'as' => 'FULLNAME' },
                  { 'first_name' => 'John', 'last_name' => 'Doe', 'as' => 'FUNNYNAME' },
                  { 'first_name' => 'John', 'last_name' => 'Doe', 'as' => 'A-NAME' }
                ]
              }
            }
          end

          it { is_expected.to include('FULLNAME' => { name: 'FULLNAME', type: 'full_name', data: { full_name: 'John Doe' } }) }
          it { is_expected.to include('FUNNYNAME' => { name: 'FUNNYNAME', type: 'full_name', data: { full_name: 'John Doe' } }) }
          it { is_expected.to include('A-NAME' => { name: 'A-NAME', type: 'full_name', data: { full_name: 'John Doe' } }) }
        end
      end
    end

    it 'processes the data with the matched processors and adds the result to process-data' do
      skip 'This test needs to be implemented once the ProcessDataPipeline functionality is complete'

      result = pipeline.execute(data)

      expect(result['process-data']).to include(
        'full_name-1' => {
          name: 'full_name-1',
          type: 'full_name',
          data: { full_name: 'John Doe' }
        }
      )
    end
  end

  describe '#write_output' do
    let(:data) do
      {
        'some_root' => {
          'full_name' => { 'first_name' => 'John', 'last_name' => 'Doe' }
        }
      }
    end

    let(:output_file) { '/tmp/output.json' }

    after { FileUtils.rm_f(output_file) }

    it 'writes the processed data to a file' do
      result = pipeline.execute(data)
      pipeline.write_output(result, output_file)

      expect(File).to exist(output_file)
      content = JSON.parse(File.read(output_file))
      expect(content['process-data']).to include(
        'full_name-1' => {
          'data' => { 'full_name' => 'John Doe' },
          'name' => 'full_name-1',
          'type' => 'full_name'
        }
      )
    end
  end
end
