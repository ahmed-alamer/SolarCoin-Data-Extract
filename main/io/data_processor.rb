class DataProcessor

  attr_accessor :file_handler

  def initialize
    @file_handler = DataFileHandler.new
  end

  def read_data
    data_list = []
    claimant_id = 0

    (1..16).each do |file_number|
      hash_list = file_handler.read_json_data_file file_number
      hash_list.each do |hash|
        processed = process_hash hash
        if processed != nil
          processed['id'] = claimant_id += 1
          data_list << processed
        end
      end
    end

    data_list
  end

  def generate_sql_statements
    sql_statements = Array.new

    #note this is a list of hashes
    result = file_handler.read_json_file 'result'

    result.each do |claimant|
      sql_statements << convert_hash_to_sql('CLAIMANTS', claimant)
    end

    result.each do |claimant|
      sql_statements << convert_hash_to_sql('PROJECTS', claimant['project'])
    end
    file_handler.write_sql_statements sql_statements, 'result'
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
  #this should be an object
  def process_hash(hash)
    #if it was an empty excel row in the past! Yuck!
    if hash['Name (First)'] == 0
      return nil
    end

    claimant_hash = Hash.new
    project_hash = Hash.new

    claimant_hash['first_name'] = hash['Name (First)']
    claimant_hash['last_name'] = hash['Name (Last)']
    claimant_hash['email'] = hash['Claimant Contact Email']
    claimant_hash['wallet'] = hash['SolarCoin Public Wallet Address']

    project_hash['id'] = hash['Entry Id']
    project_hash['street_address'] = hash['Generator Facility Location (Street Address)']
    project_hash['street_address_ext'] = hash['Generator Facility Location (Address Line 2)']
    project_hash['city'] = hash['Generator Facility Location (City)']
    project_hash['state'] = hash['Generator Facility Location (State / Province)']
    project_hash['zip_code'] = hash['Generator Facility Location (ZIP / Postal Code)']
    project_hash['country'] = hash['Generator Facility Location (Country)']
    project_hash['nameplate'] = hash['Generator Nameplate Capacity (KW - DC Rating)']
    project_hash['install_date'] = hash['Facility Interconnection Date']
    project_hash['documentation'] = hash['File Upload']
    project_hash['status'] = hash['Approval Code']

    claimant_hash['project'] = project_hash

    claimant_hash
  end

  def process_project_hash(project)
    Logger.debug project
  end

end