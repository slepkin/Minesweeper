require 'time'
require 'json'

class MinesweeperGame
  attr_accessor :true_board_array, :known_board_array, :size
  @@moves = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]


  def initialize(size, mine_num)
    @size = size
    @known_board_array = []
    size.times{@known_board_array << []}
    @known_board_array.each do |row|
      size.times{row << "*"}
    end

    @true_board_array = []
    size.times{ |i| @true_board_array << @known_board_array[i].dup}

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

  def play
    time = Time.now
    player = Human.new
    until (string_count("F",@known_board_array) == string_count("M",@true_board_array) && \
    string_count("*",@known_board_array) == 0) || \
    string_count("M",@known_board_array) > 0
      display_board
      input = player.take_turn
      command = input[0].to_sym
      case command
      when :r
        coords = input[1..2].map(&:to_i)
        reveal!(coords[0],coords[1])
        reveal_adjacencies(coords)
      when :f
        coords = input[1..2].map(&:to_i)
        if @known_board_array[coords[0]][coords[1]] == "F"
          @known_board_array[coords[0]][coords[1]] = "*"
        else
          @known_board_array[coords[0]][coords[1]] = "F"
        end
      when :save
        # Save here
        save_string = {
          :known_board => @known_board_array,
          :true_board => @true_board_array,
          :time => Time.now - time
        }.to_json
        File.open("save_file.txt", "w") {|file| file.write(save_string)}
      when :load
        # Load here
        loaded_hash = JSON.parse(File.read("save_file.txt"))
        p loaded_hash
        @known_board_array = loaded_hash[:known_board]
        @true_board_array = loaded_hash[:true_board]
        #time = (Time.now - loaded_hash[:time])
        p @known_board_array.class
      else
        puts "Not a valid command"
      end
    end

    display_board
    if string_count("M",@known_board_array) > 0
      puts "BOOM!\nIt took you #{Time.now - time} seconds to lose miserably."
    else
      puts "You win!\nIt only took #{Time.now - time} seconds."
    end
  end

  def display_board
    @known_board_array.each do |row|
      row.each do |char|
        print "#{char} "
      end
      puts
    end
  end

  def string_count(str,grid)
    str_count = 0
    grid.each do |x|
      str_count += x.count(str)
    end
    str_count
  end

  def adjacent_nonmine(coords)
    adjacencies = []
    @@moves.each do |move|
      if !mine?([coords[0] + move[0], coords[1] + move[1]]) && in_board?([coords[0] + move[0], coords[1] + move[1]])
        adjacencies << [coords[0]+move[0],coords[1]+move[1]]
      end
    end
    adjacencies
  end

  def reveal_adjacencies(coords, excluded = [coords])
    if @true_board_array[coords[0]][coords[1]] == "_" && @known_board_array != "F"
      adjacencies = adjacent_nonmine(coords) - excluded

      adjacencies.each do |adj_coords|
        reveal!(adj_coords[0],adj_coords[1])
        if @true_board_array[adj_coords[0]][adj_coords[1]] == "_"
          excluded << adj_coords
          reveal_adjacencies(adj_coords, excluded)
        elsif @true_board_array[adj_coords[0]][adj_coords[1]].is_a? Integer
          excluded << adj_coords
        end
      end
    end
  end

  def surrounding_mines(coord1, coord2)
    count = 0
    count += 1 if mine?([coord1 - 1,coord2 - 1]) && in_board?([coord1 - 1,coord2 - 1])
    count += 1 if mine?([coord1 - 1,coord2 + 0]) && in_board?([coord1 - 1,coord2 + 0])
    count += 1 if mine?([coord1 - 1,coord2 + 1]) && in_board?([coord1 - 1,coord2 + 1])
    count += 1 if mine?([coord1 + 0,coord2 - 1]) && in_board?([coord1 + 0,coord2 - 1])
    count += 1 if mine?([coord1 + 0,coord2 + 1]) && in_board?([coord1 + 0,coord2 + 1])
    count += 1 if mine?([coord1 + 1,coord2 - 1]) && in_board?([coord1 + 1,coord2 - 1])
    count += 1 if mine?([coord1 + 1,coord2 + 0]) && in_board?([coord1 + 1,coord2 + 0])
    count += 1 if mine?([coord1 + 1,coord2 + 1]) && in_board?([coord1 + 1,coord2 + 1])
    count
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
    print "Where would you like to reveal (r) or flag (f)? (format r 0 2) "
    gets.chomp.split
  end
end