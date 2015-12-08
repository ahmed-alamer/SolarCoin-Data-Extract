class DataProcessor

  def initialize
    @id_generator = {:project_id => 1, :claimant => 1}
  end

  def process_claims(claims_from_file)
    claimants = Hash.new

    claims_from_file.each do |json_object|
      Logger.debug("Processing #{json_object['Entry Id']}")

      claimant = process_claim_hash(json_object)
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

  def generate_claimants_sql(claimants)
    claimants.map do |claimant|
      projects_sql = claimant.projects.map { |project| project.to_sql(claimant.id) }

      wallets = Set.new
      claimant.projects.each { |project| wallets.add(project.wallet) }
      wallets_sql = wallets.map { |wallet| wallet.to_sql }

      claimant.to_sql + "\n" + projects_sql.join("\n") + "\n" + wallets_sql.join("\n") + "\n"
    end
  end

  def generate_adjustment_grants(claims)
    # This is so cool, I don't give a damn about the performance penalty!
    claims.map(&method(:generate_adjustment_grant))
        .flatten
        .map(&:to_sql)
  end

  def generate_periodic_grants(claimants, start_date, end_date)
    grant_date = start_date
    grants = Array.new

    while grant_date <= end_date
      grants << generate_monthly_grants(claimants, grant_date).compact
      grant_date = grant_date >> 1
    end

    grants.flatten
  end

  private
  def process_claim_hash(hash)
    first_name = hash['Name (First)']
    last_name = hash['Name (Last)']
    email = hash['Claimant Contact Email']

    if first_name == 0 || hash['Approval'].include?('R')
      return nil
    end

    # generate ids
    claimant_id = generate_id(:claimant)
    project_id = hash['Entry Id']

    # instantiate objects
    project = Project.new(project_id, hash)

    Claimant.new(claimant_id, first_name, last_name, email, project)
  end

  def generate_monthly_grants(claimants, grant_date)
    claimants.flat_map do |claimant|
      claimant.projects.map do |project|
        install_date = Date.parse(project.install_date)
        six_months = install_date >> 6
        six_months = Date.new(grant_date.year, six_months.month, six_months.day)

        unless six_months > grant_date
          create_periodic_grant(claimant, project, grant_date).to_sql
        end
      end
    end
  end

  def create_periodic_grant(claimant, project, grant_date)
    guid = generate_grant_guid('PGRT', claimant.id, project, grant_date)
    amount = 180 * project.nameplate * 0.15 # 6 months = 180 days
    Grant.new(guid, project.wallet, amount, 'PGRT', grant_date, project.id)
  end

  def generate_adjustment_grant(claimant)
    claimant.projects.map do |project|
      granting_date = project.created_at.to_date
      install_date = Date.parse(project.install_date)

      grant_date = adjust_date(install_date, granting_date)
      amount = calculate_grant_amount(project, grant_date)
      guid = generate_grant_guid('AGRT', claimant.id, project, grant_date)

      Logger.debug("Generated Grant -> #{guid}")

      Grant.new(guid, project.wallet, amount, 'AGRT', grant_date, project.id)
    end
  end

  # copy and paste from Demeter. I know! it should be a gem! Whatever!
  def adjust_date(install_date, granting_date)
    if install_date.year < 2010
      install_date = Date.new(2010, 1, 1)
    end

    next_anniversary = Date.new(granting_date.year, install_date.month, install_date.day)
    six_months = next_anniversary >> 6

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

  def generate_id(model)
    @id_generator[model] += 1
  end

  def generate_grant_guid(type_tag, claimant_id, project, grant_date)
    county_code = IsoCountryCodes.search_by_name('australia').first.alpha2
    "#{type_tag}-" +
        "#{county_code}-" +
        "#{project.post_code}-" +
        "#{project.id}-" +
        "#{project.nameplate}-" +
        "#{claimant_id}-" +
        "#{project.install_date}-" +
        "#{grant_date}"
  end

end