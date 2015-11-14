require '../main/config'

class Application

  def initialize(file_handler, data_processor)
    @file_handler = file_handler
    @data_processor = data_processor
  end

  def execute
    claims = @file_handler.read_json_file('full_set')
    claimants = @data_processor.process_claims(claims)
    @file_handler.write_json_file(claimants, 'result')
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