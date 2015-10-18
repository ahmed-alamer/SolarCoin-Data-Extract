class Wallet

  attr_accessor :public_address

  def initialize(public_address)
    @public_address = public_address
  end

  def to_sql_statement(claimant_id)
    columns = '(public_address, claimant_id)'
    values = "(\"#{@public_address}\", #{claimant_id});"
    'INSERT INTO wallets' << columns  << ' VALUES ' << values
  end

  def to_json(*args)
    {
        :public_address => @public_address
    }.to_json(*args)
  end

  def self.json_create(json_hash)
    new(json_hash['public_address'])
  end

end