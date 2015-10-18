require '../main/pom'

def aggregate_claimants_data(data_processor, file_handler)
  json_data = file_handler.load_data_from_files
  data = data_processor.read_data(json_data)
  file_handler.write_json_file(data, 'result')

  file_handler.read_json_file('result')
end

def generate_sql_file(data_processor, file_handler, result)
  sql_statements = data_processor.generate_sql_statements(result)

  file_handler.write_sql_statements(sql_statements, 'result')
end

DATA_DIRECTORY = '/home/ahmed/solar-coin-data/'

def main
  file_handler = DataFileHandler.new(DATA_DIRECTORY)
  data_processor = DataProcessor.new

  Logger.debug('Processing')

  data = aggregate_claimants_data(data_processor, file_handler)
  generate_sql_file(data_processor, file_handler, data)

  Logger.debug('Complete!')
end

#start point
main
