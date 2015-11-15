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

  def generate_claimants_sql(claimants)
    claimants.map do |claimant|
      projects_sql = claimant.projects.map{ |p| p.to_sql(claimant.id) }
      claimant.to_sql + "\n" + projects_sql.join("\n")
    end
  end

  def generate_grants_sql(grants)
    grants.map { |grant| grant.to_sql }
  end

  private
  def process_hash(hash)
    return nil if  hash['Name (First)'] == 0 || hash['Approval'] == 'R'

    # generate ids
    claimant_id = generate_id(:claimant)
    project_id = generate_id(:project)

    # instantiate objects
    wallet = Wallet.new(hash['SolarCoin Public Wallet Address'])
    project = Project.new(project_id, hash)

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