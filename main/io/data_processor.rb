class DataProcessor

  def initialize
    @id_generator = {:project => 1, :claimant => 1, :wallet => 1}
    @claimants_mappings = Hash.new
    @projects_mappings = Hash.new
  end

  def read_claimants_and_projects(json_data)
    claimants = Hash.new

    json_data.each do |json_object|
      claimant = process_hash(json_object)

      if claimant == nil
        next
      end

      claimant_id = claimant.id
      if claimants.has_key?(claimant_id)
        claimants[claimant_id].projects.push(*claimant.projects)
      else
        claimants[claimant_id] = claimant
      end
    end

    claimants.values
  end

  def read_grants(json_data)
    grants = Array.new

    json_data.each do |json_object|
      grant = Grant.from_file_hash(json_object)
      grant.project = transform_project_id(grant)
      grants << grant
    end

    grants
  end

  def transform_project_id(grant)
    @projects_mappings[grant.project]
  end

  def generate_claimant_sql(claimants)
    sql_statements = Array.new

    claimants.each_with_index do |claimant|
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

    claimant_id = get_id(:claimant)
    project_id = get_id(:project)

    @projects_mappings[hash['']]

    original_claimant_id = hash['Claimant UID']
    original_project_id = hash['Entry Id']

    handle_project_id_mapping(original_project_id, project_id)

    claimant_id = handle_claimant_id_mapping(claimant_id, original_claimant_id)

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

  def handle_project_id_mapping(original_project_id, project_id)
    @projects_mappings[original_project_id] = project_id
  end

  def handle_claimant_id_mapping(claimant_id, original_claimant_id)
    if @claimants_mappings.has_key?(original_claimant_id)
      @claimants_mappings[original_claimant_id]
    else
      @claimants_mappings[original_claimant_id] = claimant_id
      claimant_id
    end
  end

  def get_id(model)
    id = @id_generator[model]
    @id_generator[model] = id + 1

    id
  end

end