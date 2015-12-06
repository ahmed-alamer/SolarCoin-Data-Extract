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
  attr_accessor :created_at
  attr_accessor :wallet

  def initialize(id, project_hash)
    project_hash.each do |key, value|
      field_name = get_field_name(key)
      next if field_name == :unknown # obviously, we don't give a damn!
      self.send("#{field_name}=", transform_value(field_name, value))
    end

    self.id = id
    self.documentation = get_documentation_link(project_hash)
    self.address = get_address(project_hash)
  end

  def transform_value(field_name, value)
    case field_name
    when :status
      "#{Project.parse_approval_code(value)}1" #WTF Ruby?
    when :install_date
      #MySQL Compliant format
      date_string = value.split('/')
      Date.parse("#{date_string[2]}-#{date_string[0]}-#{date_string[1]}").to_s
    when :created_at
      DateTime.strptime(value, '%m/%d/%y %H:%M')
    when :wallet
      Wallet.new(value)
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
      next if member == :@wallet
      columns << extract_member_accessor(member) << ', '
    end
    columns << 'claimant_id, updated_at)'

    values = '('
    self.instance_variables.each do |member|
      member_value = self.instance_variable_get(member)
      next if member == :@wallet
      if member_value.class == String || member_value.class == DateTime
        values << "\"#{member_value}\"" << ', '
      else
        values << "#{member_value}" << ', '
      end
    end
    values << "#{claimant_id}, NOW());"

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
        :created_at => self.created_at,
        :status => self.status,
        :wallet => wallet
    }.to_json(*args)
  end

  private
  def get_address(project_hash)
    address = project_hash['Generator Facility Location (Street Address)']
    address_ext = project_hash['Generator Facility Location (Address Line 2)']
    if address_ext.class != Fixnum
      "#{address} - #{address_ext}"
    else
      address
    end
  end

  def extract_member_accessor(member)
    "#{member}".sub('@', '')
  end

  def get_documentation_link(project_hash)
    if project_hash['File Upload'] == 0
      project_hash['Link']
    else
      project_hash['File Upload']
    end
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
      when 'Utility Interconnection Date'
        :install_date
      when 'SolarCoin Public Wallet Address'
        :wallet
      when 'File Upload'
        :documentation
      when 'Link'
        :documentation
      when 'Approval'
        :status
      when 'Entry Date'
        :created_at
      else
        :unknown
    end
  end

end