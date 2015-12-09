class Grant

  attr_accessor :claimant_id
  attr_accessor :guid
  attr_accessor :wallet
  attr_accessor :amount
  attr_accessor :type_tag
  attr_accessor :created_at
  attr_accessor :project_id

  def initialize(guid, wallet, amount, type_tag, grant_date, project_id)
    @guid = guid
    @wallet = wallet
    @amount = amount
    @type_tag = type_tag
    @created_at = grant_date
    @project_id = project_id
  end

  def self.from_file_hash(grant_hash)
    type_tag = grant_hash['GUID'].split('-')[0] #YeeHaw!

    new(grant_hash['Claimant Contact Email'],
        grant_hash['GUID'],
        grant_hash['Public Wallet Address'],
        grant_hash['Quick Claim Calc'],
        type_tag,
        grant_hash['Prior Grant Date'],
        grant_hash['Generator UID'])
  end

  def to_sql
    columns = Array.new
    values = Array.new

    self.instance_variables.each do |member|
      if extract_accessor(member) == 'wallet'
        columns << 'receiver_wallet'
      else
        columns << extract_accessor(member)
      end
    end

    columns << 'updated_at'

    self.instance_variables.each do |var|
      accessor = extract_accessor(var)
      value = self.send(accessor)

      if value.class == Fixnum || value.class == Float
        values << value
      else
        values << '"' + value.to_s + '"'
      end
    end

    values << 'NOW()'

    "INSERT INTO grants(#{columns.join(',')}) VALUES(#{values.join(',')});"
  end

  def to_json(*args)
    json_object = Hash.new
    self.instance_variables.each do |member|
      accessor = extract_accessor(member)
      json_object[accessor] = self.send(accessor)
    end
    json_object.to_json(args)
  end

  private

  def extract_accessor(member)
    "#{member}".sub('@', '')
  end

end