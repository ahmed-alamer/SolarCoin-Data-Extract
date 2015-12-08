class Wallet

  attr_accessor :public_address
  attr_accessor :project_id

  def initialize(public_address, project_id)
    @public_address = public_address
    @project_id = project_id
    Logger.debug("Fucking Info - #{@public_address} => #{@project_id}")
  end

  def to_sql
    columns = '(id, public_address, project_id, created_at, updated_at)'
    values = "(DEFAULT, \"#{@public_address}\", #{@project_id}, NOW(), NOW());"
    'INSERT INTO wallets' << columns  << ' VALUES ' << values
  end

  def to_json(*args)
    {
        :public_address => @public_address,
        :project_id => @project_id
    }.to_json(*args)
  end

  def self.json_create(json_hash)
    new(json_hash['public_address'], 0)
  end

  def eql?(wallet)
    public_address == wallet.public_address
  end

  def hash
    public_address.hash
  end

end