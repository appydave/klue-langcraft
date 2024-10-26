# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Klue::Langcraft::DSL::KlueRunner do
  let(:runner) { described_class.new }

  describe 'Integration test: Process a .klue file and generate output' do
    # let(:base_name) { 'fullname-array' }
    let(:base_name) { 'fullname-hierarchy' }
    let(:base_path) { File.join('spec', 'usecases', 'full-name') }
    let(:base_file) { File.join(base_path, base_name) }

    let(:klue_file) { "#{base_file}.klue" }
    let(:basic_json_file) { "#{base_file}.json" }
    let(:enhanced_json_file) { "#{base_file}-enhanced.json" }
    let(:webhook_url) { 'http://0.0.0.0:3000/pages/klueless' }

    let(:input_file) { klue_file }

    it 'processes the .klue file and writes the result to JSON files' do
      # skip 'INTEGRATION TEST ONLY - Run manually when needed'

      runner.run(
        input_file: input_file,
        basic_output_file: basic_json_file,
        enhanced_output_file: enhanced_json_file,
        webhook_url: webhook_url
      )
    end
  end
end
