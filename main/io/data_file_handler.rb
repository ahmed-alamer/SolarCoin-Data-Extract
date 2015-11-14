require 'json'

class DataFileHandler

  def initialize(input_directory, output_directory)
    @input_directory = input_directory
    @output_directory = output_directory
  end

  def read_json_file(file_name)
    JSON.parse(read_file("#{file_name}.json"))
  end

  def write_json_file(result, file_name)
    File.write("#{@output_directory}/#{file_name}.json", result.to_json)
  end

  def write_sql_file(statements, file_name)
    file = File.open("#{@output_directory}#{file_name}.sql", 'w')
    statements.each do |statement|
      file.write(statement.concat("\n"))
    end
    file.close
  end

  def read_directory_files(filter)
    result_list = Array.new

    Dir.glob(filter) do |file_name|
      Logger.debug("Parsing File - #{file_name}")
      hash = File.read(file_name)
      result_list.push(*hash)
    end

    result_list
  end

  private
  def read_file(file_name)
    File.read("#{@input_directory}/#{file_name}")
  end

end