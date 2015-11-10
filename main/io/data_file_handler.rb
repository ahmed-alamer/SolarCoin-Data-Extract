require 'json'

class DataFileHandler

  def initialize(data_directory)
    @directory = data_directory
  end

  def read_json_file(file_name)
    JSON.parse(read_file("#{file_name}.json"))
  end

  def write_json_file(result, file_name)
    File.write("#{@directory}#{file_name}.json", result.to_json)
  end

  def write_sql_file(statements, file_name)
    file = File.open("#{@directory}#{file_name}.sql", 'w')
    statements.each do |statement|
      file.write(statement.concat("\n"))
    end
    file.close
  end

  def load_claims_data
    result_list = Array.new

    Dir.glob(CLAIMS_DIRECTORY) do |claim_file|
      Logger.debug("Parsing File - #{claim_file}")
      hash_list = read_json_file(claim_file)
      result_list.push(*hash_list)
    end

    result_list
  end

  def load_approved_claims
    read_json_file("#{INPUT_DIRECTORY}/approved.json")
  end

  private
  def read_file(file_name)
    File.read(@directory + file_name)
  end

end