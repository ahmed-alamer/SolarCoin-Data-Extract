class DataProcessor

  attr_accessor :file_handler

  def read_data(json_data)
    data_list = Array.new

    json_data.each do |json_object|
      claimant = process_hash(json_object)

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

    claimants.each_with_index do |claimant, index|
      sql_statements << claimant.to_sql_statement(index)
      sql_statements << claimant.wallet.to_sql_statement(index)
      sql_statements << claimant.project.to_sql_statement(index)
    end

    sql_statements
  end

  private
  def process_hash(hash)
    #if it was an empty excel row in the past! Yuck!
    if hash['Name (First)'] == 0
      return nil
    end

    wallet = Wallet.new(hash['SolarCoin Public Wallet Address'])
    project = Project.from_file_hash(hash)

    #That's a hell of way to return a value! Damn!
    Claimant.new(hash['Name (First)'], hash['Name (Last)'], hash['Claimant Contact Email'], wallet, project)
  end

end