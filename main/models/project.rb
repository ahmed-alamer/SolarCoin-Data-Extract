class Project
  def initialize (project_hash)
    @id = project_hash['Entry Id']
    @street_address = project_hash['Generator Facility Location (Street Address)']
    @street_address_ext = project_hash['Generator Facility Location (Address Line 2)']
    @city = project_hash['Generator Facility Location (City)']
    @state = project_hash['Generator Facility Location (State / Province)']
    @zip_code = project_hash['Generator Facility Location (ZIP / Postal Code)']
    @country = project_hash['Generator Facility Location (Country)']
    @nameplate = project_hash['Generator Nameplate Capacity (KW - DC Rating)']
    @install_date = project_hash['Facility Interconnection Date']
    @documentation = project_hash['File Upload']
    @status = project_hash['Approval Code']
  end

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

  def to_sql_statement(claimant_id)
    'INSERT INTO projects(id, street_address, street_address_ext, city, state, zip_code, country, nameplate, install_date, documentation, status, claimant_id'
        .concat('VALUES')
        .concat("(#{@id}, '#{@street_address}', '#{@street_address_ext}', '#{@city}', '#{@state}', '#{@zip_code}', '#{@country}', '#{@nameplate}', '#{@install_date}', '#{@documentation}', '#{@status}', #{claimant_id})")
  end

end