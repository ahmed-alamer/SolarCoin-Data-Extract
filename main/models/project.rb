class Project

  attr_accessor :id
  attr_accessor :address
  attr_accessor :city
  attr_accessor :state
  attr_accessor :post_code
  attr_accessor :country
  attr_accessor :nameplate
  attr_accessor :install_date
  attr_accessor :documentation
  attr_accessor :status

  def initialize(id, project_hash)
    project_hash.each do |key, value|
      field_name = get_field_name(key)
      next if field_name == :unknown # obviously, we don't give a damn!
      self.send("#{field_name}=", transform_value(field_name, value))
    end

    self.id = id

    address = project_hash['Generator Facility Location (Street Address)']
    address_ext = project_hash['Generator Facility Location (Address Line 2)']
    self.address = "#{address}"
    if address_ext.class != Fixnum
      self.address << " - #{address_ext}"
    end
  end

  def transform_value(field_name, value)
    if field_name == :status
      Project.parse_approval_code(value) #WTF Ruby?
    elsif field_name == :documentation
      value == 0 ? 'N/A' : value
    elsif field_name == :install_date
      #MySQL Compliant format
      date_string = value.split('/')
      Date.parse("#{date_string[2]}-#{date_string[0]}-#{date_string[1]}").to_s
    else
      value #no transformation
    end
  end

  def self.parse_approval_code(value)
    if value == 0 || value == 'Test'
      'P'
    else
      value.split('-').first.strip
    end
  end

  def self.from_json(project_hash)
    project_hash.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def to_sql(claimant_id)
    columns = '('
    self.instance_variables.each do |member|
      columns << extract_member_accessor(member) << ', '
    end
    columns << 'claimant_id, created_at, updated_at)'

    values = '('
    self.instance_variables.each do |member|
      member_value = self.instance_variable_get(member)
      if member_value.class == String
        values << "\"#{member_value}\"" << ', '
      else
        values << "#{member_value}" << ', '
      end
    end
    values << "#{claimant_id}, NOW(), NOW());"

    "INSERT INTO projects #{columns} VALUES #{values}"
  end

  def to_json(*args)
    {
        :id => self.id,
        :address => self.address,
        :city => self.city,
        :state => self.state,
        :post_code => self.post_code,
        :country => self.country,
        :nameplate => self.nameplate,
        :install_date => self.install_date,
        :documentation => self.documentation,
        :status => self.status
    }.to_json(*args)
  end

  private

  def extract_member_accessor(member)
    "#{member}".sub('@', '')
  end

  def get_field_name(json_key)
    case json_key
      when 'Generator Facility Location (City)'
        :city
      when 'Generator Facility Location (State / Province)'
        :state
      when 'Generator Facility Location (ZIP / Postal Code)'
        :post_code
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
        :unknown
    end
  end

end