require '../main/io/data_file_handler'
require '../main/io/data_processor'
require '../main/io/logger'

#TODO: Add the wallets creation logic

def main
  data_processor = DataProcessor.new

  Logger.debug 'Processing'

  data = data_processor.read_data

  data_processor.file_handler.write_json_data data, 'result.json'

  data_processor.generate_sql_statements

  Logger.debug 'Complete!'
end

#start point
main
