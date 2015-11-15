require '../main/config'

class Application

  def initialize(file_handler, data_processor)
    @file_handler = file_handler
    @data_processor = data_processor
  end

  def transform_claims
    claims = @file_handler.read_json_file('full_set')
    @data_processor.process_claims(claims)
  end

  def execute
    @claimants = transform_claims
    @sql_statements = @data_processor.generate_claimants_sql(@claimants)
  end

  def shutdown
    @file_handler.write_json_file(@claimants, 'result')
    @file_handler.write_sql_file(@sql_statements, 'claimants')
  end

end

begin
  file_handler = DataFileHandler.new(INPUT_DIRECTORY, OUTPUT_DIRECTORY)
  data_processor = DataProcessor.new

  application = Application.new(file_handler, data_processor)

  Logger.debug('Processing...')
  application.execute
  Logger.debug('Complete!')
ensure
  application.shutdown
end