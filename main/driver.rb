require '../main/pom'

def aggregate_claimants_data(data_processor, file_handler)
  json_data = file_handler.load_data_from_files
  data = data_processor.read_claimants_and_projects(json_data)
  file_handler.write_json_file(data, 'result')

  data
end

def generate_sql_file(data_processor, file_handler, claimants)
  sql_statements = data_processor.generate_claimant_sql(claimants)

  file_handler.write_sql_file(sql_statements, 'result')
end

def load_grants(file_handler)
  file_handler.read_json_file('grants')
end

DATA_DIRECTORY = '/home/ahmed/solar-coin-data/'

def main
  file_handler = DataFileHandler.new(DATA_DIRECTORY)
  data_processor = DataProcessor.new

  Logger.debug('Processing')

  data = aggregate_claimants_data(data_processor, file_handler)

  generate_sql_file(data_processor, file_handler, data)

  grants_json = load_grants(file_handler)

  grants = data_processor.read_grants(grants_json)

  sql = data_processor.generate_grants_sql(grants)

  Logger.debug(sql)

  Logger.debug('Complete!')
end

#start point
main
