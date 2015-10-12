require '../main/io/data_file_handler'
require '../main/io/data_processor'
require '../main/io/logger'

#TODO: Add the wallets creation logic

def main
  DataFileHandler file_handler = DataFileHandler.new

  data_processor = DataProcessor.new(file_handler)

  Logger.debug 'Processing'

  data = data_processor.read_data

  file_handler.write_json_data data, 'result'

  data_processor.generate_sql_statements

  Logger.debug 'Complete!'
end

#start point
main
