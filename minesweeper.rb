require './board.rb'
require './human.rb'
require 'time'
require 'json'

class MinesweeperGame
  attr_accessor :true_board_array, :known_board_array, :size, :board

  def initialize(size, mine_num)
    @board = Board.new(size, mine_num)

    play
  end

  def play
    time = Time.now
    player = Human.new
    until game_over?
      @board.display_board
      input = player.take_turn
      input.nil? ? command = nil : command = input[0]
      case command
      when "r"
        coords = input[1..2].map(&:to_i)
        @board.reveal!(coords[0],coords[1])
        @board.reveal_adjacencies(coords)
      when "f"
        coords = input[1..2].map(&:to_i)
        @board.flag!(coords[0],coords[1])
      when "save"
        save_game
      when "load"
        load_game
      when "quit" || "exit"
        break
      else
        puts "Not a valid command"
      end
    end

    @board.display_board

    if @board.string_count("M", @board.known_board_array) > 0
      puts "BOOM!\nIt took you #{Time.now - time} seconds to lose miserably."
    elsif game_over?
      puts "You win!\nIt only took #{Time.now - time} seconds."
    end
  end

  def game_over?
    (@board.string_count("F", @board.known_board_array) == @board.string_count("M", @board.true_board_array) && \
        @board.string_count("*", @board.known_board_array) == 0) || \
        @board.string_count("M", @board.known_board_array) > 0
  end

  def save_game
    save_string = {
      :known_board => @board.known_board_array,
      :true_board => @board.true_board_array,
      :time => Time.now - time
    }.to_json
    puts "Name of file?"
    filename = gets.chomp
    File.open(filename, "w") {|file| file.write(save_string)}
    puts "Game saved to #{filename}"
  end

  def load_game
    puts "Name of file to load?"
    filename = gets.chomp
    loaded_hash = JSON.parse(File.read(filename))
    @board.known_board_array = loaded_hash["known_board"]
    @board.true_board_array = loaded_hash["true_board"]
    time = (Time.now - loaded_hash["time"])
    puts "Loaded #{filename}"
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "How wide should the field be?"
  size = gets.chomp.to_i
  puts "How many mines?"
  mine_num = gets.chomp.to_i
  MinesweeperGame.new(size,mine_num)
end