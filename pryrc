Pry.commands.alias_command 'c', 'continue' if Pry.commands.commands['continue']
Pry.commands.alias_command 's', 'step' if Pry.commands.commands['step']
Pry.commands.alias_command 'n', 'next' if Pry.commands.commands['next']
Pry.commands.alias_command 'f', 'next' if Pry.commands.commands['finish']

if defined? ActiveRecord
  def railslog
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    puts 'Redirected ActiveRecord::Base.logger to stdout'
  end
 end
