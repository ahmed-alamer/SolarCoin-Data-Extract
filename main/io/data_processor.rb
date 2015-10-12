class DataProcessor

  attr_accessor :file_handler

  def initialize(data_file_handler)
    @file_handler = data_file_handler
  end

  def read_data(json_data)
    data_list = Array.new

    json_data.each do |json_object|
      claimant = process_hash json_object

      if claimant != nil
        data_list << claimant
      end
    end

    data_list
  end

  def generate_sql_statements(json_data)
    sql_statements = Array.new
    claimants = Array.new

    json_data.each do |hash|
      claimants << Claimant.json_create(hash)
    end



    #note this is a list of hashes
    # result = file_handler.read_json_file 'result'

    # json_data.each do |claimant_json|
    #   claimant = JSON.parse claimant_json
    #   Logger.debug claimant
    #   claimant.instance_variables.each do |member|
    #     Logger.debug member, ' = ', member.instance_variable_get
    #   end
    #   # sql_statements << convert_hash_to_sql('CLAIMANTS', claimant)
    # end

    # result.each do |claimant|
    #   sql_statements << convert_hash_to_sql('PROJECTS', claimant['project'])
    # end
    # file_handler.write_sql_statements sql_statements, 'result'
  end

  def convert_hash_to_sql(table_name, hash)
    columns_names = hash.keys.to_s.sub('[', '(').sub(']', ')')
    sql_statement = "INSERT INTO #{table_name} #{columns_names} VALUES("

    hash.each_value do |value|
      if value.is_a? Fixnum
        sql_statement = "#{sql_statement} #{value},"
      elsif value.is_a? String
        sql_statement = sql_statement.concat('"').concat(value.to_s).concat('",')
      end
    end

    sql_statement[-1] = ')' #this way I replace the last comma with a ) YeeHaw! One Step!

    Logger.debug sql_statement

    sql_statement.concat(';')
  end

  private
  #this should be an hash
  def process_hash(hash)
    #if it was an empty excel row in the past! Yuck!
    if hash['Name (First)'] == 0
      return nil
    end

    wallet = Wallet.new(hash['SolarCoin Public Wallet Address'])
    project = Project.new(hash)

    #That's a hell of way to return a value! Damn!
    Claimant.new(hash['Name (First)'], hash['Name (Last)'], hash['Claimant Contact Email'], wallet, project)
  end

end