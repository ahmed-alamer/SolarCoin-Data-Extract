require 'json'

class DataFileHandler

  def read_file(file_name)
    File.read "../data/#{file_name}"
  end

  def read_json_file(file_name)
    JSON.parse read_file "#{file_name}.json"
  end

  def read_json_data_file(file_number)
    read_json_file "p#{file_number}"
  end

  def write_json_data(result, file_name)
    File.write "../data/#{file_name}.json", result.to_json
  end

  def write_sql_statements(statements, file_name)
    file = File.open"../data/#{file_name}.sql", 'w'
    statements.each do |statement|
      file.write statement
    end
    file.close
  end

end