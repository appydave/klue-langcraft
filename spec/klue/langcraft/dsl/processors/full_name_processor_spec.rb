# frozen_string_literal: true

RSpec.describe Klue::Langcraft::DSL::Processors::FullNameProcessor do
  let(:key) { :full_name } # Define the key
  let(:processor) { described_class.new(data, key) } # Pass both data and key to initialize
  let(:data) { { 'first_name' => 'Appy', 'last_name' => 'Dave', 'as' => 'name_key' } }

  describe '.keys' do
    it 'returns the correct keys for FullNameProcessor' do
      expect(described_class.keys).to eq([:full_name])
    end
  end

  describe '#build_result_data' do
    subject { described_class.new(data, key).build_result_data }

    context 'with first_name and last_name provided' do
      it { is_expected.to eq(full_name: 'Appy Dave') }
    end

    context 'with first_name and last_name missing' do
      let(:data) { {} }

      it { is_expected.to eq(full_name: 'John Doe') }
    end

    context 'with first_name missing' do
      let(:data) { { 'last_name' => 'Dave' } }

      it { is_expected.to eq(full_name: 'John Dave') }
    end

    context 'with last_name missing' do
      let(:data) { { 'first_name' => 'Appy' } }

      it { is_expected.to eq(full_name: 'Appy Doe') }
    end
  end
end
