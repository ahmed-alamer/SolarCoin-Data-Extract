require '../main/pom'

def main
  file_handler = DataFileHandler.new('/home/ahmed/solar-coin-data/')

  data_processor = DataProcessor.new(file_handler)

  # json_data = file_handler.load_data_from_files
  #
  # Logger.debug 'Processing'
  #
  # data = data_processor.read_data(json_data)
  #
  # file_handler.write_json_file data, 'result'

  result = file_handler.read_json_file 'result'

  data_processor.generate_sql_statements result
  Logger.debug 'Complete!'
end

#start point
main
