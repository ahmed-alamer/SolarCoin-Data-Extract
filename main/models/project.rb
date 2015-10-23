class Project

  attr_accessor :id
  attr_accessor :street_address
  attr_accessor :street_address_ext
  attr_accessor :city
  attr_accessor :state
  attr_accessor :zip_code
  attr_accessor :country
  attr_accessor :nameplate
  attr_accessor :install_date
  attr_accessor :documentation
  attr_accessor :status
  attr_accessor :dummy

  def initialize(project_hash)
    project_hash.each do |key, value|
      self.send("#{get_field_name(key)}=", value)
    end
  end

  def self.from_json(project_hash)
    project_hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end


  def to_sql_statement(claimant_id)
    columns = '('
    self.instance_variables.each do |member|
      columns << extract_member_accessor(member) << ', '
    end
    columns << 'claimant_id)'

    values = '('
    self.instance_variables.each do |member|
      member_value = self.instance_variable_get(member)
      if member_value.class != Fixnum
        values << "\"#{member_value}\"" << ', '
      else
        values << "#{member_value}" << ', '
      end
    end
    values << "#{claimant_id});"

    'INSERT INTO projects' << columns << ' VALUES ' << values
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

  private
  def extract_member_accessor(member)
    "#{member}".sub('@', '')
  end

  def get_field_name(json_name)
    case json_name
      when 'Entry Id'
        :id
      when 'Generator Facility Location (Street Address)'
        :street_address
      when 'Generator Facility Location (Address Line 2)'
        :street_address_ext
      when 'Generator Facility Location (City)'
        :city
      when 'Generator Facility Location (State / Province)'
        :state
      when 'Generator Facility Location (ZIP / Postal Code)'
        :zip_code
      when 'Generator Facility Location (Country)'
        :country
      when 'Generator Nameplate Capacity (KW - DC Rating)'
        :nameplate
      when 'Facility Interconnection Date'
        :install_date
      when 'File Upload'
        :documentation
      when 'Approval Code'
        :status
      else
        :dummy
    end
  end

end