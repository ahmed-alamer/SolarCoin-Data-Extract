class DataProcessor

  def initialize
    @id_generator = {:project => 1, :claimant => 1}
    @claimants_ids = Set.new
    @wallets = Set.new
  end

  def read_claimants_and_projects(json_data)
    claimants = Hash.new

    json_data.each do |json_object|
      claimant = process_hash(json_object)

      if claimant == nil
        next
      end

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

    claimants.each_with_index do |claimant|

      if @claimants_ids.include? claimant.id
        claimant.id = generate_id(:claimant)
        @claimants_ids.add(claimant.id)
      end
      @claimants_ids.add(claimant.id)

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
    #if it was an empty excel row in the past! Yuck!
    if hash['Name (First)'] == 0
      return nil
    end

    approval_code = Project.parse_approval_code(hash['Approval Code'])
    claimant_id = transform_id(:claimant, hash['Claimant UID'], approval_code)
    project_id = transform_id(:project, hash['Generator UID'], approval_code)

    # we don't care if it's nil because the whole object will be ignored anyway
    wallet = get_wallet(hash['SolarCoin Public Wallet Address'])
    project = Project.new(project_id, hash)

    #That's a hell of way to return a value! Damn!
    Claimant.new(claimant_id,
                 hash['Name (First)'],
                 hash['Name (Last)'],
                 hash['Claimant Contact Email'],
                 wallet,
                 [project])
  end

  def transform_id(model, original_id, approval_status)
    if approval_status.start_with?('R') || original_id == 0
      generate_id(model)
    else
      original_id
    end
  end

  def get_wallet(wallet_address)
    if @wallets.include? wallet_address
      nil
    else
      wallet = Wallet.new(wallet_address)
      @wallets.add wallet

      wallet
    end
  end

  def generate_id(model)
    id = @id_generator[model]
    @id_generator[model] = id + 1

    id
  end

end