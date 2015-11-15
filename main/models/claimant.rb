class Claimant

  attr_accessor :id
  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :email
  attr_accessor :wallet
  attr_accessor :projects

  def initialize(id, first_name, last_name, email, wallet, projects)
    @id = id
    @first_name = first_name
    @last_name = last_name
    @email = email
    @wallet = wallet
    @projects = projects
  end

  def to_sql
    columns = '(id, first_name, last_name, email, created_at, updated_at)'
    values = "(#{@id}, \"#{@first_name}\", \"#{@last_name}\", \"#{@email}\", NOW(), NOW());"

    'INSERT INTO claimants' << columns << ' VALUES ' << values
  end

  #God! I should've done this using Java & Jackson!
  def to_json(*args)
    {
        :id => @id,
        :first_name => @first_name,
        :last_name => @last_name,
        :email => @email,
        :wallet => @wallet,
        :projects => @projects
    }.to_json(*args)
  end

  def self.json_create(json_hash)
    new(json_hash['id'],
        json_hash['first_name'],
        json_hash['last_name'],
        json_hash['email'],
        Wallet.json_create(json_hash['wallet']),
        Project.from_json(json_hash['project']))
  end

end