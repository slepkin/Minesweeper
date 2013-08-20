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
    print "  "
    (0...@size).each{|i| print "#{i} "}
    puts
    @known_board_array.each_with_index do |row, index|
      print "#{index} "
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