# frozen_string_literal: true

RSpec.describe Klue::Langcraft do
  it 'has a version number' do
    expect(Klue::Langcraft::VERSION).not_to be_nil
  end

  it 'has a standard error' do
    expect { raise Klue::Langcraft::Error, 'some message' }
      .to raise_error('some message')
  end
end
