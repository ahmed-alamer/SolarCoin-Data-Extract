class Grant

  attr_accessor :claimant_email
  attr_accessor :guid
  attr_accessor :receiver_wallet
  attr_accessor :amount
  attr_accessor :type_tag
  attr_accessor :grant_date
  attr_accessor :project

  def initialize(claimant_email,
                 guid,
                 receiver_wallet,
                 amount,
                 type_tag,
                 grant_date,
                 project)

    @claimant_email = claimant_email
    @guid = guid
    @receiver_wallet = receiver_wallet
    @amount = amount
    @type_tag = type_tag
    @grant_date = grant_date
    @project = project
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
      accessor = extract_accessor(member)
      if accessor == 'claimant_email'
        columns << 'project_id'
      elsif accessor == 'project'
        next
      else
        columns << accessor
      end
    end

    columns << 'created_at' << 'updated_at'

    self.instance_variables.each do |var|
      accessor = extract_accessor(var)

      next if accessor == 'project'

      value = self.send(accessor)

      if accessor == 'claimant_email'
        claimant_id = '(SELECT id ' +
            'FROM claimants ' +
            "WHERE email = '#{value}'" +
            'LIMIT 1)'

          values << '(SELECT id FROM projects ' +
              "WHERE claimant_id = #{claimant_id} LIMIT 1)"
      elsif accessor == 'receiver_wallet'
        values << '(SELECT id FROM wallets ' +
            'WHERE public_address = "' + @receiver_wallet.public_address +
            '" LIMIT 1)'
      elsif value.class == Fixnum || value.class == Float
        values << value
      else
        values << '"' + value.to_s + '"'
      end
    end

    values << 'NOW()' << 'NOW()'

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