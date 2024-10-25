# frozen_string_literal: true

RSpec.describe Klue::Langcraft::DSL::Interpreter do
  let(:interpreter) { described_class.new }

  def normalize_keys(value)
    case value
    when Array
      value.map { |v| normalize_keys(v) }
    when Hash
      value.each_with_object({}) do |(k, v), memo|
        memo[k.to_sym] = normalize_keys(v)
      end
    else
      value
    end
  end

  describe '#initialize' do
    it 'initializes with an empty data hash' do
      expect(interpreter.data).to eq({})
    end
  end

  describe '#method_missing' do
    it 'stores method calls in the data hash' do
      interpreter.process(input: '') # Call process first
      interpreter.test_method('arg1', 'arg2')
      expect(interpreter.data[:test_method]).to eq({ p1: 'arg1', p2: 'arg2' })
    end
  end

  describe '#process_args' do
    it 'processes positional and named arguments' do
      result = interpreter.send(:process_args, [1, 2, { name: 'test' }], nil)
      expect(result).to eq({ p1: 1, p2: 2, name: 'test' })
    end
  end

  describe '#process' do
    let(:process) { interpreter.process(input: dsl) }
    let(:base_path) { '/tmp' }
    let(:input_file) { 'test.dsl' }
    let(:absolute_input_file) { File.join(base_path, input_file) }
    let(:output_file) { 'output.json' }
    let(:absolute_output_file) { File.join(base_path, output_file) }
    let(:dsl) { "test_method 'value1', key: 'value2'" }
    let(:output) { interpreter.data }

    before do
      File.write(absolute_input_file, dsl)
    end

    after do
      File.delete(absolute_input_file)
      FileUtils.rm_f(File.join(base_path, output_file))
    end

    it 'evaluates DSL and writes JSON output' do
      output = interpreter.process(input_file: absolute_input_file, output_file: absolute_output_file)

      expect(output).to eq(test_method: { p1: 'value1', key: 'value2' })
    end

    context 'when processing usecases' do
      before { process }

      context 'when single method' do
        let(:dsl) do
          <<~RUBY
            a_method
          RUBY
        end

        let(:expected) do
          {
            a_method: nil
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'when same method on multiple lines without parameters' do
        let(:dsl) do
          <<~RUBY
            a_method
            a_method
            a_method
          RUBY
        end

        let(:expected) do
          {
            a_method: nil
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'when same method on multiple lines with varied parameters' do
        let(:dsl) do
          <<~RUBY
            a_method 1,2
            a_method 3,4,5
            a_method#{' '}
            a_method 6
          RUBY
        end

        let(:expected) do
          {
            a_method: [
              { p1: 1, p2: 2 },
              { p1: 3, p2: 4, p3: 5 },
              nil,
              { p1: 6 }
            ]
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'when positional parameters x2 and named parameters x2' do
        let(:dsl) do
          <<~RUBY
            test_method 'value1', 'value2', name1: 'named value 1', name2: 2
          RUBY
        end

        let(:expected) do
          {
            test_method: {
              p1: 'value1',
              p2: 'value2',
              name1: 'named value 1',
              name2: 2
            }
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'when different methods with different parameter signatures' do
        let(:dsl) do
          <<~RUBY
            a_method 1,2,3,4
            b_method name: 'name', age: 20
            c_method 'value1', 'value2', name1: 'named value 1', name2: 2
          RUBY
        end

        let(:expected) do
          {
            a_method: {
              p1: 1,
              p2: 2,
              p3: 3,
              p4: 4
            },
            b_method: {
              name: 'name',
              age: 20
            },
            c_method: {
              p1: 'value1',
              p2: 'value2',
              name1: 'named value 1',
              name2: 2
            }
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'when nested block' do
        let(:dsl) do
          <<~RUBY
            a_method 'value1', 'value2' do
              b_method 'value3', 'value4'
            end
          RUBY
        end

        let(:expected) do
          {
            a_method: {
              p1: 'value1',
              p2: 'value2',
              b_method: {
                p1: 'value3',
                p2: 'value4'
              }
            }
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'when multiple nested sibling and child blocks' do
        let(:dsl) do
          <<~RUBY
            a_method 'a-value', 2 do
              b_method 'b-value', size: 3
              c_method do
                d_method
              end
            end
            e_method 'the quick brown fox'
          RUBY
        end

        let(:expected) do
          {
            a_method: {
              p1: 'a-value',
              p2: 2,
              b_method: {
                p1: 'b-value',
                size: 3
              },
              c_method: {
                d_method: nil
              }
            },
            e_method: {
              p1: 'the quick brown fox'
            }
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'when multiple methods are created using a loop' do
        let(:dsl) do
          <<~RUBY
            3.times do |i|
              a_method i, i+1
            end
          RUBY
        end

        let(:expected) do
          {
            a_method: [
              { p1: 0, p2: 1 },
              { p1: 1, p2: 2 },
              { p1: 2, p2: 3 }
            ]
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'with fullname edge case' do
        let(:dsl) do
          <<~RUBY
            some_root do
              full_name first_name: 'Appy', last_name: 'Dave', as: 'name_key'
            end
          RUBY
        end
        let(:expected) do
          {
            some_root: {
              full_name: {
                first_name: 'Appy',
                last_name: 'Dave',
                as: 'name_key'
              }
            }
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'with fullname repeated three times' do
        let(:dsl) do
          <<~RUBY
            some_root do
              full_name first_name: 'John', last_name: 'Doe'
              full_name first_name: 'John', last_name: 'Doe'
              full_name first_name: 'John', last_name: 'Doe'
            end
          RUBY
        end
        let(:expected) do
          {
            some_root: {
              full_name: [
                { first_name: 'John', last_name: 'Doe' },
                { first_name: 'John', last_name: 'Doe' },
                { first_name: 'John', last_name: 'Doe' }
              ]
            }
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'with fullname repeated three times in side custom nodes' do
        let(:dsl) do
          <<~RUBY
            some_root do
              a do
                full_name first_name: 'John', last_name: 'Doe'
              end
              b do
                full_name first_name: 'John', last_name: 'Doe'
              end
              c do
                full_name first_name: 'John', last_name: 'Doe'
              end
            end
          RUBY
        end
        let(:expected) do
          {
            some_root: {
              a: { full_name: { first_name: 'John', last_name: 'Doe' } },
              b: { full_name: { first_name: 'John', last_name: 'Doe' } },
              c: { full_name: { first_name: 'John', last_name: 'Doe' } }
            }
          }
        end

        it { expect(output).to eq(expected) }
      end

      context 'when a post-processing element is used' do
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

        let(:expected) do
          {
            custom_processors: {
              file_collector: {
                root: '~/dev/ad/appydave/appydave-app',
                as: :file_list,
                files: {
                  include: { p1: 'app/controllers/api/v1/*_controller.rb' },
                  exclude: { p1: '**/authentication_controller*' }
                }
              },
              full_name: {
                first_name: { p1: 'Appy' },
                last_name: { p1: 'Dave' }
              }
            }
          }
        end

        it { expect(output).to eq(expected) }
      end
    end
  end

  describe 'Processes a real .klue file and writes a .json output' do
    # let(:klue_file) { '/Users/davidcruwys/dev/ad/klueless/docs/dsls/docs-as-code/doc-as-code-sample.klue' }
    let(:klue_file) { '/Users/davidcruwys/dev/ad/klueless/klue-langcraft/spec/klue/langcraft/dsl/test1.klue' }
    let(:json_output_file) { File.join(File.dirname(__FILE__), 'interpreter_spec.json') }
    let(:json_output_enhanced_file) { File.join(File.dirname(__FILE__), 'interpreter_spec.enhanced.json') }

    it 'processes the .klue file and writes the result to a JSON file' do
      # Ensure the .klue file exists
      expect(File.exist?(klue_file)).to be true

      # Interpret the .klue file and write the output to a .json file
      interpreter.process(input_file: klue_file, output_file: json_output_file)

      # Assert the output file was created
      expect(File.exist?(json_output_file)).to be true

      # Optionally, you can load and inspect the content of the JSON output
      output_content = File.read(json_output_file)

      puts "Generated JSON Output: \n#{output_content}"
      matcher = Klue::Langcraft::DSL::ProcessMatcher.new
      data = JSON.parse(output_content)
      processors = matcher.match_processors(data)
      puts "Matched Processors: #{processors}"

      pipeline = Klue::Langcraft::DSL::ProcessDataPipeline.new(matcher)
      result = pipeline.execute(data)

      puts 'Processed Data:'
      puts JSON.pretty_generate(result)
      File.write(json_output_enhanced_file, JSON.pretty_generate(result))
    end
  end
end
