class Claimant

  attr_accessor :first_name, :last_name, :email, :wallet, :project

  def initialize(first_name, last_name, email, wallet, project)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @wallet = wallet
    @project = project
  end

  def to_sql_statement(id)
    'INSERT INTO CLAIMANTS(id, first_name, last_name, email, wallet_id)'
        .concat('VALUES')
        .concat("(#{id}, \"#{@first_name}\", \"#{@last_name}\", \"#{@email}\");")
  end

  #God! I should've done this using Java & Jackson!
  def to_json(*args)
    {
        :first_name => @first_name,
        :last_name => @last_name,
        :email => @email,
        :wallet => @wallet,
        :project => @project
    }.to_json(*args)
  end

  def self.json_create(json_hash)
    new(json_hash['first_name'],
        json_hash['last_name'],
        json_hash['email'],
        Wallet.json_create(json_hash['wallet']),
        Project.json_create(json_hash['project']))
  end

end