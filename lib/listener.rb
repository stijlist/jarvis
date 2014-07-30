class Listener
  def self.listen(command)
    {command: command.match(/^(\w+)/)[0].to_sym}
  end
end
