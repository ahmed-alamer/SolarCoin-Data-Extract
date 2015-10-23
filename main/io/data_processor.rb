class DataProcessor

  def read_claimants_and_projects(json_data)
    claimants_and_projects_list = Array.new

    json_data.each do |json_object|
      claimant = process_hash(json_object)

      if claimant != nil
        claimants_and_projects_list << claimant
      end
    end

    claimants_and_projects_list
  end

  def read_grants(json_data)
    grants_list = Array.new

    json_data.each do |json_object|
      grant = Grant.from_file_hash(json_object)

      grants_list << grant
    end

    grants_list
  end

  def generate_claimant_sql(claimants)
    sql_statements = Array.new

    claimants.each_with_index do |claimant, index|
      sql_statements << claimant.to_sql_statement
      sql_statements << claimant.wallet.to_sql_statement(index)
      sql_statements << claimant.project.to_sql_statement(index)
    end

    sql_statements
  end



  def generate_grants_sql(grants)
    sql_statements = Array.new

    grants.each do |grant|
      sql_statements << grant.to_sql_statement
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
    project = Project.new(hash)

    #That's a hell of way to return a value! Damn!
    Claimant.new(hash['Entry Id'],
                 hash['Name (First)'],
                 hash['Name (Last)'],
                 hash['Claimant Contact Email'],
                 wallet,
                 project)
  end

end