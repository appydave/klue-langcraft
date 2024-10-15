require 'json'
require 'net/http'
require 'uri'

class DSLInterpreter
  def initialize
    @data = {}
  end

  # Capturing top-level DSL methods
  def method_missing(method_name, *args, &block)
    key = method_name
    value = process_args(args, block)

    # Append key-value to the current context of @data
    if @data[key]
      @data[key] = [@data[key]] unless @data[key].is_a?(Array)
      @data[key] << value
    else
      @data[key] = value
    end
  end

  # A method to handle parameters and nested blocks
  def process_args(args, block)
    data = {}

    # Handling positional and named parameters separately
    positional_args = []
    named_args = {}

    args.each do |arg|
      if arg.is_a?(Hash)
        named_args.merge!(arg)
      else
        positional_args << arg
      end
    end

    # Assign positional parameters generically
    positional_args.each_with_index do |arg, index|
      data["param#{index + 1}".to_sym] = arg
    end

    # Merge named parameters directly
    data.merge!(named_args)

    # Handling a nested block
    if block
      interpreter = DSLInterpreter.new
      interpreter.instance_eval(&block)
      data.merge!(interpreter.data)
    end

    data.empty? ? nil : data
  end

  # To access data after interpreting
  attr_reader :data

  # Reading file and evaluating as Ruby
  def evaluate_file(base_path, input_file, output_file)
    content = File.read(File.join(base_path, input_file))
    instance_eval(content)
    File.write(File.join(base_path, output_file), JSON.pretty_generate(@data))
  end

  # Convert to hash or JSON as required
  def to_hash
    @data
  end

  def to_json(*_args)
    @data.to_json
  end

  # Method to send data to an endpoint
  def send_to_endpoint
    root_key = @data.keys.first
    action_type = root_key.to_s

    uri = URI.parse("http://localhost:4567/dsl/#{action_type}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
    payload = { action_type: action_type, data: @data }
    request.body = payload.to_json

    response = http.request(request)
    puts "Response: #{response.code} - #{response.message}"
    puts "Endpoint: #{uri}"
  end
end
