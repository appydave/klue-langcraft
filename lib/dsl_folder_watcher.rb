# frozen_string_literal: true

class DSLFolderWatcher
  def self.watch(folder_path)
    puts "Watching: #{folder_path}"
    listener = Listen.to(folder_path) do |modified, added, _removed|
      changes = (modified + added).uniq

      # DEBOUNCE CURRENTLY NOT WORKING
      # debounce_map = {}
      # debounce_interval = 1 # seconds

      changes.each do |file_path|
        next unless File.extname(file_path) == '.klue'

        puts file_path

        # debounce_map[file_path] ||= Time.now
        # next unless Time.now - debounce_map[file_path] >= debounce_interval

        # debounce_map[file_path] = Time.now

        base_name = file_path.gsub(/\.klue$/, '')
        input_file = "#{base_name}.klue"
        output_file = "#{base_name}.json"

        interpreter = DSLInterpreter.new
        if interpreter.process('', input_file, output_file)
          # Process the JSON data to add 'process-data' details
          dsl_processor = DSLProcessData.new
          dsl_processor.process('', output_file, output_file)
          # SKIP EXTEND FILE FOR NOW AND REWRITE THE OUTPUTFILE
          # dsl_processor.process('', output_file, extended_output_file)

          # interpreter.send_to_endpoint
        else
          puts 'Skipping further processing due to errors in DSL interpretation.'
        end
      end

      # Remove old entries from debounce_map to prevent memory bloat
      # debounce_map.each_key do |key|
      #   debounce_map.delete(key) if Time.now - debounce_map[key] > debounce_interval * 2
      # end
    end
    listener.start
    puts "Wait for changes: #{folder_path}"
    sleep
  end
end
