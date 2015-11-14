require '../main/config'

class Application

  def initialize(file_handler, data_processor)
    @file_handler = file_handler
    @data_processor = data_processor
  end

  def execute
    claims = @file_handler.read_json_file('approved.json')
    claimants = @data_processor.process_claims(claims)
    @file_handler.write_json_file(claimants, 'result.json')
  end

end

# def aggregate_claimants_data(data_processor, file_handler)
#   json_data = file_handler.aggregate_claims
#   data = data_processor.process_claims(json_data)
#   file_handler.write_json_file(data, 'result')
#   file_handler.write_json_file(json_data, 'aggregate')
#   data
# end
#
# def generate_sql_file(data_processor, file_handler, claimants)
#   sql_statements = data_processor.generate_claimant_sql(claimants)
#   file_handler.write_sql_file(sql_statements, 'result')
# end
#
# def load_grants(file_handler)
#   file_handler.read_json_file('grants')
# end
#
# def aggregate_grants(data_processor, file_handler)
#   grants_json = load_grants(file_handler)
#
#   data_processor.read_grants(grants_json)
# end
#
# def generate_grants_sql_file(data_processor, file_handler, grants)
#   sql_statements = data_processor.generate_grants_sql(grants)
#   file_handler.write_sql_file(sql_statements, 'grants')
# end

def main
  file_handler = DataFileHandler.new(INPUT_DIRECTORY, OUTPUT_DIRECTORY)
  data_processor = DataProcessor.new

  application = Application.new(file_handler, data_processor)

  Logger.debug('Processing...')
  result = file_handler.read_directory_files(CLAIMS_DIRECTORY_REGEX)
  Logger.debug(result)
  Logger.debug('Complete!')
end

#start point
main