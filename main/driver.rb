require '../main/config'

def aggregate_claimants_data(data_processor, file_handler)
  json_data = file_handler.load_claims_data
  data = data_processor.read_claimants_and_projects(json_data)
  file_handler.write_json_file(data, 'result')
  file_handler.write_json_file(json_data, 'aggregate')
  data
end

def generate_sql_file(data_processor, file_handler, claimants)
  sql_statements = data_processor.generate_claimant_sql(claimants)
  file_handler.write_sql_file(sql_statements, 'result')
end

def load_grants(file_handler)
  file_handler.read_json_file('grants')
end

def aggregate_grants(data_processor, file_handler)
  grants_json = load_grants(file_handler)

  data_processor.read_grants(grants_json)
end

def generate_grants_sql_file(data_processor, file_handler, grants)
  sql_statements = data_processor.generate_grants_sql(grants)
  file_handler.write_sql_file(sql_statements, 'grants')
end

def main
  file_handler = DataFileHandler.new(INPUT_DIRECTORY)
  data_processor = DataProcessor.new

  Logger.debug('Processing...')

  claimants = aggregate_claimants_data(data_processor, file_handler)
  grants = aggregate_grants(data_processor, file_handler)

  generate_sql_file(data_processor, file_handler, claimants)
  generate_grants_sql_file(data_processor, file_handler, grants)

  Logger.debug('Complete!')
end

#start point
main