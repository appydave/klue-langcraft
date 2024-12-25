# DSL System Expansion Plan

## Overview

The current system processes DSL input using an interpreter, matchers, processors, and pipelines. We need to expand the system by introducing several new features:

1. **Processor Service**: A centralized service that orchestrates all operations, simplifying how the watcher and command-line tools work.
2. **Data Saving Option**: An option to toggle whether the processed JSON data is saved to a file or not.
3. **Endpoint for Data Delivery**: Add the capability to send the processed data to external HTTP endpoints, configurable via the command line.

The changes will affect the class structure, as well as introduce new command-line options and configurations. Below is a detailed explanation of the required features and how they will be implemented.

---

## New Components and Changes

### 1. **Processor Service**

- **Purpose**: We need to introduce a new service (tentatively called `ProcessorService`) to orchestrate the different components. This class will:
  - Call the interpreter to process the DSL input.
  - Run the data through the processing pipeline to apply any necessary transformations.
  - Handle the saving of the processed data to a file if configured.
  - Send the resulting JSON data to external endpoints if URLs are provided via the command line.

- **Why**: Currently, the watcher or command-line tool is responsible for calling various components (interpreter, pipeline, etc.). By introducing this service, we centralize the logic and simplify the external interfaces. The watcher will only need to call this service, and any configuration options (like file saving or sending data to an endpoint) will be handled internally by the service.

- **Key Features**:
  - **Options Handling**: The service will take in various options, such as:
    - Whether to save the processed JSON to a file.
    - URLs for sending data (e.g., one for simplified JSON, one for enhanced JSON).
  - **Sequential Processing**: The service will sequentially call:
    1. The interpreter to process the DSL.
    2. The processing pipeline to enhance the data.
    3. Save the data to a file (if the option is enabled).
    4. Send the data to the endpoint (if URLs are provided).

### 2. **Data Saving Option**

- **Purpose**: Introduce a command-line option (`--save-to-file`) that will enable or disable saving the processed data to a file. By default, the data should flow through the system, but whether it gets written to the filesystem should be configurable.

- **Why**: Not all users may want to persist the JSON data to disk. The ability to toggle this behavior will make the system more flexible.

- **Details**:
  - When the `--save-to-file` option is enabled, the processed data should be saved to a file.
  - If the option is not provided, the data will not be saved to a file, but it will still flow through the system for other uses (e.g., sending to endpoints).
  
### 3. **Data Delivery to Endpoints**

- **Purpose**: Add the ability to send the JSON data (either simplified or enhanced) to external HTTP endpoints. These endpoints should be configurable via command-line options (`--endpoint-simplified` and `--endpoint-enhanced`).

- **Why**: The system should be able to integrate with external services by sending the resulting data to a web application. For example, the web app could receive simplified JSON for debugging and enhanced JSON for final usage. This allows seamless data transfer between the DSL processing system and external applications.

- **Details**:
  - The `ProcessorService` will check if any URLs are provided via the command line.
  - If the URLs are provided, it will send the resulting JSON data (using HTTP POST) to those endpoints.
  - **Two endpoints**:
    - One for simplified JSON.
    - One for enhanced JSON.
  - The system should allow sending data to either or both endpoints, depending on the provided options.

### 4. **Command-Line Interface (Expanded)**

- The existing `CommandLineInterface` class should be expanded to handle the new options:
  - `--save-to-file`: Toggles whether the JSON is saved to a file.
  - `--endpoint-simplified`: Specifies the URL for sending simplified JSON.
  - `--endpoint-enhanced`: Specifies the URL for sending enhanced JSON.
  
- These options should be passed to the `ProcessorService`, which will handle the actual behavior (e.g., saving the file, sending data to the endpoint).
  
### 5. **Watcher Integration**

- The existing `Watcher` class, which uses `ListenGem` to monitor file changes, will now delegate all processing to the `ProcessorService`. When a file change is detected, the watcher should simply call the service with the necessary options.
  
- This means that the watcher doesn't need to know about interpreters, pipelines, or processors—it just needs to hand over the file to the `ProcessorService`, which will handle everything sequentially.

---

## Revised Class Structure

### New Classes:

1. **ProcessorService**:
   - Central orchestrator for calling the interpreter, processing data, saving the file, and sending data to endpoints.
   - Will take all options from the command line and watcher.

2. **DataDeliveryService**:
   - Handles sending JSON data to external HTTP endpoints.
   - Accepts a URL and sends the provided data using HTTP POST.

### Expanded Classes:

1. **CommandLineInterface**:
   - Now handles additional command-line options (`--save-to-file`, `--endpoint-simplified`, `--endpoint-enhanced`).
   - Passes these options to the `ProcessorService`.

2. **Watcher**:
   - Instead of directly calling interpreters and pipelines, the watcher will now pass the detected file changes to the `ProcessorService` for handling.

---

## Command-Line Options

- **New Options**:
  - `--save-to-file`: If provided, the resulting JSON will be saved to a file. Otherwise, the data will only flow through the system.
  - `--endpoint-simplified`: A URL for sending the simplified JSON to an external endpoint.
  - `--endpoint-enhanced`: A URL for sending the enhanced JSON to an external endpoint.

These options should be passed to the `ProcessorService`, which will then handle the appropriate behavior based on the configuration.

---

## Final Workflow

1. **Command-Line Usage**:
   - Users can pass options such as directories to watch, whether to save files, and URLs for endpoints.
   
2. **Watcher**:
   - Monitors the specified directories for file changes and passes any detected changes to the `ProcessorService`.
   
3. **ProcessorService**:
   - Orchestrates the sequence:
     1. Calls the `Interpreter` to process the DSL input.
     2. Runs the `ProcessDataPipeline` to enhance the data.
     3. Saves the resulting data to a file if the `--save-to-file` option is enabled.
     4. Sends the resulting data to the provided URL(s) if the `--endpoint-simplified` or `--endpoint-enhanced` options are specified.

4. **Data Delivery**:
   - The `DataDeliveryService` is responsible for sending the processed data to the external endpoints, handling any HTTP interactions required.


# SAMPLE CODE, NOT TESTED BUT MIGHT BE SUITABLE
```ruby

# file: lib/klue/langcraft/dsl/data_delivery_service.rb
require 'net/http'
require 'uri'
require 'json'

module Klue
  module Langcraft
    module DSL
      class DataDeliveryService
        def initialize(url)
          @url = URI.parse(url)
        end

        def send(data)
          http = Net::HTTP.new(@url.host, @url.port)
          request = Net::HTTP::Post.new(@url.request_uri, { 'Content-Type' => 'application/json' })
          request.body = data.to_json
          response = http.request(request)

          puts "Data sent to #{@url}: #{response.code} #{response.message}"
        end
      end
    end
  end
end
```

```ruby
# file: lib/klue/langcraft/dsl/processor_service.rb
require_relative 'interpreter'
require_relative 'process_data_pipeline'
require_relative 'data_delivery_service'

module Klue
  module Langcraft
    module DSL
      class ProcessorService
        def initialize(options)
          @options = options
          @interpreter = Interpreter.new
          @pipeline = ProcessDataPipeline.new(ProcessMatcher.new)
        end

        def run
          data = call_interpreter
          enhanced_data = run_pipeline(data)
          save_to_file(enhanced_data) if @options[:save_to_file]
          send_to_endpoint(enhanced_data)
        end

        private

        def call_interpreter
          @interpreter.process(input: 'path_to_input_file.dsl')
        end

        def run_pipeline(data)
          @pipeline.execute(data)
        end

        def save_to_file(data)
          File.write('output.json', JSON.pretty_generate(data))
        end

        def send_to_endpoint(data)
          if @options[:endpoint_simplified]
            DataDeliveryService.new(@options[:endpoint_simplified]).send(data)
          end

          if @options[:endpoint_enhanced]
            DataDeliveryService.new(@options[:endpoint_enhanced]).send(data)
          end
        end
      end
    end
  end
end

```

```ruby
# file: lib/klue/langcraft/dsl/command_line_interface.rb
require_relative 'watcher'
require_relative 'processor_service'

module Klue
  module Langcraft
    module DSL
      class CommandLineInterface
        def initialize
          @watch_dirs = []
          @options = {}
        end

        def start
          parse_arguments
          start_watcher_or_processor_service
        end

        private

        def parse_arguments
          ARGV.each_with_index do |arg, index|
            case arg
            when '--watch'
              @watch_dirs << ARGV[index + 1]
            when '--save-to-file'
              @options[:save_to_file] = true
            when '--endpoint-simplified'
              @options[:endpoint_simplified] = ARGV[index + 1]
            when '--endpoint-enhanced'
              @options[:endpoint_enhanced] = ARGV[index + 1]
            end
          end

          raise 'No directories specified for watching' if @watch_dirs.empty?
        end

        def start_watcher_or_processor_service
          if @watch_dirs.any?
            watcher = Watcher.new(@watch_dirs)
            watcher.start
          else
            processor_service = ProcessorService.new(@options)
            processor_service.run
          end
        end
      end
    end
  end
end

```