
# DSL Class Diagram

```plaintext
+----------------------------+          
|      Klue::Langcraft::DSL   |
|----------------------------|
| + Interpreter               |
| + ProcessMatcher            |
| + ProcessorConfig           |
| + ProcessDataPipeline       |
| + Processors                |
+----------------------------+

                |
                v
+-----------------------------------+
|          Interpreter              |         
|-----------------------------------|           
| - data: Hash                      |           
| - processed: Boolean              |
|-----------------------------------|           
| + initialize()                    |
| + process(input, output)          |
| + method_missing()                |
| + process_args(args, block)       |
| + respond_to_missing?()           |
| + to_json()                       |
+-----------------------------------+

                |
                v
+-----------------------------------+
|         ProcessMatcher            |         
|-----------------------------------|           
| + match_processors(nodes)         |           
|-----------------------------------|
| - traverse_nodes(node, &block)    |
| - find_processor_for(key, value)  |
|-----------------------------------|
| - processor_config: ProcessorConfig|
+-----------------------------------+

                |
                v
+-----------------------------------+
|      ProcessDataPipeline          |         
|-----------------------------------|           
| + execute(data)                   |           
| + write_output(data, output_file) |
|-----------------------------------|
| - store_result(data, processor,   |
|   processed_data)                 |
| - calculate_index(data, processor)|
|-----------------------------------|
| - matcher: ProcessMatcher         |
+-----------------------------------+

                |
                v
+-----------------------------------+
|       ProcessorConfig             |         
|-----------------------------------|           
| + register_processor(processor)   |           
| + processor_for(key)              |
| + all_processors()                |
|-----------------------------------|
| - processors: Hash                |
+-----------------------------------+

                |
                v
+----------------------------+          
|         Processor           |          
|----------------------------|           
| - data: Hash                |
| - key: Symbol               |
|----------------------------|
| + initialize(data, key)     |
| + build_result()            |
| + build_result_data()       |
|----------------------------|
| + keys() (abstract method)  |
+----------------------------+

                |
                v
+----------------------------+           +-------------------------+
|  FileCollectorProcessor     |           |     FullNameProcessor   |
|----------------------------|           +-------------------------+
| (inherits Processor)        |           | (inherits Processor)    |
|----------------------------|           +-------------------------+
| + build_result_data()       |           | + build_result_data()   |
| + Auto-register with        |           | + Auto-register with    |
|   ProcessorConfig           |           |   ProcessorConfig       |
+----------------------------+           +-------------------------+
```