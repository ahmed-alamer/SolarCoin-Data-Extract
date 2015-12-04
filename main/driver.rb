require '../main/config'

class Application

  def initialize(file_handler, data_processor)
    @file_handler = file_handler
    @data_processor = data_processor
  end

  def transform_claims
    claims = @file_handler.read_json_file('full_set_2')
    @data_processor.process_claims(claims)
  end

  def write_claims_sql(claims)
    claims_sql = @data_processor.generate_claimants_sql(claims)
    @file_handler.write_sql_file(claims_sql, 'claimants')
  end

  def write_grants_sql(claims)
    grants_sql = @data_processor.generate_grants_sql(claims)
    @file_handler.write_sql_file(grants_sql, 'grants')
  end

  def execute
    claims = transform_claims
    start_date = Date.parse('2014-01-01')
    end_date = Date.parse('2014-02-01')
    periodic_grants = @data_processor.generate_periodic_grants(claims, start_date, end_date)
    @file_handler.write_sql_file(periodic_grants, 'periodic_grants')
    # @file_handler.write_json_file(claims, 'claimants')
    #
    # write_claims_sql(claims)
    # write_grants_sql(claims)
  end

end

begin
  file_handler = DataFileHandler.new(INPUT_DIRECTORY, OUTPUT_DIRECTORY)
  data_processor = DataProcessor.new

  application = Application.new(file_handler, data_processor)

  Logger.debug('Processing...')
  application.execute
  Logger.debug('Complete!')
end