class Grant

  attr_accessor :guid
  attr_accessor :receiver_wallet
  attr_accessor :amount
  attr_accessor :type_tag
  attr_accessor :grant_date
  attr_accessor :project

  def initialize(guid, receiver_wallet, amount, type_tag, grant_date, project)
    @guid = guid
    @receiver_wallet = receiver_wallet
    @amount = amount
    @type_tag = type_tag
    @grant_date = grant_date
    @project = project
  end

  def self.from_file_hash(grant_hash)
    type_tag = grant_hash['GUID'].split('-')[0] #YeeHaw!

    new(grant_hash['GUID'],
        grant_hash['Public Wallet Address'],
        grant_hash['Quick Claim Calc'],
        type_tag,
        grant_hash['Prior Grant Date'],
        grant_hash['Generator UID'])
  end

  def to_sql_statement
    #I feel so bad that I crossed the 80 chars, alright!!
    columns = '(id, guid, receiver_wallet, amount, type_tag, grant_date, project_id, created_at, updated_at)'
    wallet = "(select id from wallets where public_address = \"#{@receiver_wallet}\")"
    values = "(DEFAULT, \"#{@guid}\", #{wallet}, #{@amount}, \"#{@type_tag}\", \"#{@grant_date}\", #{@project}, NOW(), NOW())"

    'INSERT INTO grants' << columns << ' VALUES ' << values
  end

end