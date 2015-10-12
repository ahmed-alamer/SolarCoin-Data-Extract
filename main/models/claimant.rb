class Claimant

  def initialize(first_name, last_name, email, wallet, project)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @wallet = wallet
    @project = project
  end

  attr_accessor :first_name, :last_name, :email, :wallet, :project

  def to_sql_statement
    'INSERT INTO CLAIMANTS(first_name, last_name, email, wallet_id)'
        .concat('VALUES')
        .concat("('#{@first_name}', '#{@last_name}', '#{@email}', #{@wallet.id})")
  end

end