# frozen_string_literal: true

RSpec.describe Klu::Langcraft do
  it 'has a version number' do
    expect(Klu::Langcraft::VERSION).not_to be_nil
  end

  it 'has a standard error' do
    expect { raise Klu::Langcraft::Error, 'some message' }
      .to raise_error('some message')
  end
end
