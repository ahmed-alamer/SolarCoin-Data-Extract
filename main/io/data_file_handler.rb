require 'json'

class DataFileHandler

  def initialize(data_directory)
    @directory = data_directory
  end

  def read_json_data_file(file_number)
    read_json_file("p#{file_number}")
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

  def load_data_from_files
    result_set = Array.new

    (2..18).each do |file_number|
      Logger.debug("Parsing File - #{file_number}")

      hash_list = self.read_json_data_file(file_number)

      hash_list.each do |hash|
        result_set << hash
      end
    end

    result_set
  end

  private
  def read_file(file_name)
    File.read(@directory + file_name)
  end

end