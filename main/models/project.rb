class Project
  attr_accessor :id,
                :street_address,
                :street_address_ext,
                :city,
                :state,
                :zip_code,
                :country,
                :nameplate,
                :install_date,
                :documentation,
                :status

  def self.from_file_hash (project_hash)
    new(project_hash['Entry Id'],
        project_hash['Generator Facility Location (Street Address)'],
        project_hash['Generator Facility Location (Address Line 2)'],
        project_hash['Generator Facility Location (City)'],
        project_hash['Generator Facility Location (State / Province)'],
        project_hash['Generator Facility Location (ZIP / Postal Code)'],
        project_hash['Generator Facility Location (Country)'],
        project_hash['Generator Nameplate Capacity (KW - DC Rating)'],
        project_hash['Facility Interconnection Date'],
        project_hash['File Upload'],
        project_hash['Approval Code'])
  end

  def initialize (id, street_address, street_address_ext, city, state, zip_code, country, nameplate, install_date, documentation, status)
    @id = id
    @street_address = street_address
    @street_address_ext = street_address_ext
    @city = city
    @state = state
    @zip_code = zip_code
    @country = country
    @nameplate = nameplate
    @install_date = install_date
    @documentation = documentation
    @status = status
  end
  def to_sql_statement(claimant_id)
    'INSERT INTO projects(id, street_address, street_address_ext, city, state, zip_code, country, nameplate, install_date, documentation, status, claimant_id)'
        .concat('VALUES')
        .concat("(#{@id}, \"#{@street_address}\", \"#{@street_address_ext}\", \"#{@city}\", \"#{@state}\", \"#{@zip_code}\", \"#{@country}\", \"#{@nameplate}\", \"#{@install_date}\", \"#{@documentation}\", \"#{@status}\", #{claimant_id});")
  end

  def to_json(*args)
    {
        :id => @id,
        :street_address => @street_address,
        :street_address_ext => @street_address_ext,
        :city => @city,
        :state => @state,
        :zip_code => @zip_code,
        :country => @country,
        :nameplate => @nameplate,
        :install_date => @install_date,
        :documentation => @documentation,
        :status => @status
    }.to_json(*args)
  end

  def self.json_create(project_hash)
    new(project_hash['id'],
        project_hash['street_address'],
        project_hash['street_address_ext'],
        project_hash['city'],
        project_hash['state'],
        project_hash['zip_code'],
        project_hash['country'],
        project_hash['nameplate'],
        project_hash['install_date'],
        project_hash['documentation'],
        project_hash['status'])
  end

end