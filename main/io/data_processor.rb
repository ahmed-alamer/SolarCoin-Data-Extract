class DataProcessor

  def initialize
    @id_generator = {:project => 1, :claimant => 1}
    @wallets = Set.new
  end

  def process_claims(claims_from_file)
    claimants = Hash.new

    claims_from_file.each do |json_object|
      Logger.debug("Processing #{json_object['Entry Id']}")

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

  def process_grants(grants_from_file)
    grants = Hash.new

    grants_from_file.each do |grant|
      grant = Grant.from_file_hash(grant)
      claimant_email = grant.claimant_email
      if grants.has_key?(claimant_email)
        grants[claimant_email] << grant
      else
        grants[claimant_email] = Array(grant)
      end
    end

    grants
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
      projects_sql = claimant.projects.map { |project| project.to_sql(claimant.id) }
      claimant.to_sql + "\n" +
          projects_sql.join("\n") + "\n"+
          claimant.wallet.to_sql(claimant.id) + "\n"
    end
  end

  def generate_grants_sql(claims)
    grants = claims.map { |claimant| generate_claimant_grants(claimant) }
    grants.flatten.map { |grant| grant.to_sql }
  end

  def generate_claimant_grants(claimant)
    claimant.projects.map do |project|
      granting_date = project.created_at.to_date
      install_date = Date.parse(project.install_date)

      grant_date = adjust_date(install_date, granting_date)
      amount = calculate_grant_amount(project, grant_date)

      Logger.debug("#{project.id}: #{project.id}(#{grant_date} => #{amount}")

      Grant.new(claimant.email, 'GUID', claimant.wallet, amount, 'AGRT', grant_date, project.id)
    end
  end

  private
  def process_hash(hash)
    if  hash['Name (First)'] == 0 || hash['Approval'].include?('R')
      return nil
    end

    # generate ids
    claimant_id = generate_id(:claimant)
    project_id = hash['Entry Id']

    # instantiate objects
    wallet = Wallet.new(hash['SolarCoin Public Wallet Address'])
    project = Project.new(project_id, hash)

    #adjust nameplate to MWs
    # project.nameplate = project.nameplate / 1000

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

  # copy and paste from Demeter. I know! it should be a gem! Whatever!
  def adjust_date(install_date, granting_date)
    if install_date.year < 2010
      install_date = Date.new(2010, 1, 1)
    end

    next_anniversary = Date.new(granting_date.year,
                                install_date.month,
                                install_date.day)

    six_months  = next_anniversary >> 6

    if granting_date > six_months
      calc_month = Date.new(six_months.year, six_months.month, 1)
    else
      calc_month = Date.new(six_months.year - 1, six_months.month, 1)
      # Why is isn't there a retreat method!?
    end

    calc_month
  end

  def calculate_grant_amount(project, grant_date)
    project_install_date = Date.parse(project.install_date)

    if project_install_date.year < 2010
      project_install_date = Date.new(2010, 1, 1)
    end

    day_diff = grant_date - project_install_date
    (24 * (project.nameplate) * day_diff.abs * 0.15) / 1000
  end


end