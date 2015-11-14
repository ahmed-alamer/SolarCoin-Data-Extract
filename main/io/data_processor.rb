class DataProcessor

  def initialize
    @id_generator = {:project => 1, :claimant => 1}
    @wallets = Set.new
  end

  def process_claims(claims)
    claimants = Hash.new

    claims.each do |json_object|
      claimant = process_hash(json_object)

      next if claimant == nil

      claimant_email = claimant.email
      if claimants.has_key?(claimant_email)
        claimants[claimant_email].projects.push(*claimant.projects)
      else
        claimants[claimant_email] = claimant
      end
    end

    claimants.values
  end

  def read_grants(json_data)
    grants = Array.new

    json_data.each do |json_object|
      grant = Grant.from_file_hash(json_object)
      grants << grant
    end

    grants
  end

  def generate_claimant_sql(claimants)
    sql_statements = Array.new

    claimants.each do |claimant|
      sql_statements << claimant.to_sql_statement
      sql_statements << claimant.wallet.to_sql_statement(claimant.id)
      claimant.projects.each do |project|
        sql_statements << project.to_sql_statement(claimant.id)
      end
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
    if hash['Name (First)'] == 0 || hash['Approval Code'] == 'R'
      return nil
    end
    claimant_id = generate_id(:claimant)

    wallet = Wallet.new(hash['SolarCoin Public Wallet Address'])
    project = Project.new(hash)

    #That's a hell of way to return a value! Damn!
    Claimant.new(claimant_id,
                 hash['Name (First)'],
                 hash['Name (Last)'],
                 hash['Claimant Contact Email'],
                 wallet,
                 [project])
  end

  def generate_id(model)
    @id_generator[model] += 1
  end

end