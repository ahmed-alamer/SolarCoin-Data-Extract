class Wallet

  def initialize(public_address)
    @public_address = public_address
  end

  def to_sql_statement(claimant_id)
    'INSERT INTO wallets(public_address, claimant_id)'
        .concat('VALUES')
        .concat("('#{@public_address}', #{claimant_id})")
  end

end