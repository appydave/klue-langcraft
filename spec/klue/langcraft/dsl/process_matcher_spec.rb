# frozen_string_literal: true

RSpec.describe Klue::Langcraft::DSL::ProcessMatcher do
  let(:matcher) { described_class.new }
  let(:interpreter) { Klue::Langcraft::DSL::Interpreter.new }
  let(:process) { interpreter.process(input: dsl) }
  let(:data) { process }

  describe '#match_processors' do
    context 'when matching processors for nodes' do
      let(:dsl) do
        <<~RUBY
          custom_processors do
            file_collector(root: '~/dev/ad/appydave/appydave-app', as: :file_list) do
              files do
                include 'app/controllers/api/v1/*_controller.rb'
                exclude '**/authentication_controller*'
              end
            end
            full_name do
              first_name 'Appy'
              last_name 'Dave'
            end
          end
        RUBY
      end

      it 'matches FileCollectorProcessor for file_collector node and assigns the correct key' do
        processors = matcher.match_processors(data)
        file_collector_processor = processors.find { |p| p.is_a?(Klue::Langcraft::DSL::Processors::FileCollectorProcessor) }

        expect(file_collector_processor).not_to be_nil
        expect(file_collector_processor.key).to eq(:file_collector)
      end

      it 'matches FullNameProcessor for full_name node and assigns the correct key' do
        processors = matcher.match_processors(data)
        full_name_processor = processors.find { |p| p.is_a?(Klue::Langcraft::DSL::Processors::FullNameProcessor) }

        expect(full_name_processor).not_to be_nil
        expect(full_name_processor.key).to eq(:full_name)
      end

      it 'does not match any processor for unknown node' do
        processors = matcher.match_processors(data)
        expect(processors).not_to include(an_instance_of(Klue::Langcraft::DSL::Processors::Processor))
      end

      it 'returns the correct number of matched processors' do
        processors = matcher.match_processors(data)
        expect(processors.size).to eq(2) # Only 2 out of 3 nodes match known processors
      end

      context 'when matching only one processor' do
        let(:dsl) do
          <<~RUBY
            custom_processors do
              full_name do
                first_name 'Appy'
                last_name 'Dave'
              end
            end
          RUBY
        end

        it 'matches FullNameProcessor for full_name node and assigns the correct key' do
          processors = matcher.match_processors(data)
          full_name_processor = processors.find { |p| p.is_a?(Klue::Langcraft::DSL::Processors::FullNameProcessor) }

          expect(full_name_processor).not_to be_nil
          expect(full_name_processor.key).to eq(:full_name)
        end

        it 'does not match FileCollectorProcessor for file_collector node' do
          processors = matcher.match_processors(data)
          expect(processors).not_to include(an_instance_of(Klue::Langcraft::DSL::Processors::FileCollectorProcessor))
        end
      end
    end
  end
end
