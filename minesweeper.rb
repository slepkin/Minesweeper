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

class Board
  attr_accessor :known_board_array, :true_board_array, :size
  @@moves = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]

  def initialize(size,mine_num)
    @size = size
    @known_board_array = []
    size.times{@known_board_array << []}
    @known_board_array.each do |row|
      size.times{row << "*"}
    end

    @true_board_array = []
    size.times{|i| @true_board_array << @known_board_array[i].dup}

    #Add mines
    until string_count("M",@true_board_array) == mine_num
      @true_board_array[rand(size)][rand(size)] = "M"
    end

    #Label non-mines with adjacent mine count
    (0...size).each do |i|
      (0...size).each do |j|
        if @true_board_array[i][j] == "*"
          @true_board_array[i][j] = surrounding_mines(i,j)
          @true_board_array[i][j] = "_" if @true_board_array[i][j] == 0
        end
      end
    end
  end

  def string_count(str,grid) #Counts how many times a string appears on grid
    str_count = 0
    grid.each do |x|
      str_count += x.count(str)
    end
    str_count
  end

  def surrounding_mines(coord1, coord2)
    count = 0
    @@moves.each do |move|
      y,x = move
      count += 1 if mine?([coord1 + y,coord2 + x]) && in_board?([coord1 + y,coord2 + x])
    end
    count
  end

  def display_board
    @known_board_array.each do |row|
      row.each do |char|
        print "#{char} "
      end
      puts
    end
  end

  def flag!(coord1, coord2)
    case @known_board_array[coord1][coord2]
    when "F" then @known_board_array[coord1][coord2] = "*"
    when "*" then @known_board_array[coord1][coord2] = "F"
    else
      puts "Invalid location for flag."
    end
  end

  def adjacent_nonmine(coords)
    adjacent_in_board(coords).select{|adj_coord| !mine?(adj_coord)}
  end

  def adjacent_in_board(coords)
    adjacencies = []
    @@moves.each do |move|
      adj_coord = [coords[0]+move[0],coords[1]+move[1]]
      if in_board?(adj_coord)
        adjacencies << adj_coord
      end
    end
    adjacencies
  end

  def reveal_adjacencies(coords, excluded = [coords])
    y, x = coords
    if @true_board_array[y][x] == "_" && @known_board_array != "F"
      adjacencies = adjacent_nonmine(coords) - excluded

      adjacencies.each do |adj_coords|
        y2, x2 = adj_coords
        reveal!(y2,x2)
        if @true_board_array[y2][x2] == "_"
          excluded << adj_coords
          reveal_adjacencies(adj_coords, excluded)
        elsif @true_board_array[y2][x2].is_a? Integer
          excluded << adj_coords
        end
      end
    end
  end

  def in_board?(coords)
    coords[0] >= 0 && coords[0] < @size && coords[1] >= 0 && coords[1] < @size
  end

  def mine?(coords)
    if coords[0] >= @size || coords[1] >= @size
      return false
    end
    @true_board_array[coords[0]][coords[1]] == "M"
  end

  def reveal!(coord1,coord2)
    unless @known_board_array[coord1][coord2] == "F"
      @known_board_array[coord1][coord2] = @true_board_array[coord1][coord2]
    end
  end
end

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

#It would be neat to add a rudimentary AI, but Ke advised us not to today.

# class Computer
#
#   def
#   def take_turn
#     #r or f something
#   end
#
#   def safe_to_flag?(coord1,coord2)
#
#   end
#
#   def safe_to_reveal?(coord1,coord2)
#
#   end
#
# end

if __FILE__ == $PROGRAM_NAME
  puts "How wide should the field be?"
  size = gets.chomp.to_i
  puts "How many mines?"
  mine_num = gets.chomp.to_i
  MinesweeperGame.new(size,mine_num)
end