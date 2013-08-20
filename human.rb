class Human
  def take_turn
    puts "Enter command. Options:"
    puts "Reveal (format r 0 2)"
    puts "Flag (format f 0 2)"
    puts "save"
    puts "load"
    puts "quit"
    gets.chomp.split
  end
end