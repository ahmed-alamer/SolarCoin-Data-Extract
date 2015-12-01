class Logger

  # dead simple, I am so Javatic!
  def self.debug(*messages)
    puts messages
  end

  def self.inspect(object)
    puts object.inspect
  end

end