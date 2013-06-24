class MinesweeperGame
  attr_accessor :true_board_array, :known_board_array, :size


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
        end
      end
    end

    player = Human.new


  end
  #
  # def play
  #   while mine_hit? == false &&
  # end

  def string_count(str,grid)
    str_count = 0
    grid.each do |x|
      str_count += x.count(str)
    end
    str_count
  end


  private

  def surrounding_mines(coord1, coord2)
    count = 0
    count += 1 if mine_in_board?(coord1,coord2,-1,-1)
    count += 1 if mine_in_board?(coord1,coord2,0,-1)
    count += 1 if mine_in_board?(coord1,coord2,1,-1)
    count += 1 if mine_in_board?(coord1,coord2,-1,0)
    count += 1 if mine_in_board?(coord1,coord2,1,0)
    count += 1 if mine_in_board?(coord1,coord2,-1,1)
    count += 1 if mine_in_board?(coord1,coord2,0,1)
    count += 1 if mine_in_board?(coord1,coord2,1,1)
    count
  end

  def mine_in_board?(coord1,coord2, down, right)
    p "input to mine_in_board: #{coord1},#{coord2}, #{down}, #{right}"
    coord1 + down >= 0 && coord1 + down < @size && \
    coord2 + right >= 0 && coord2 + right < @size && \
    @true_board_array[coord1 + down][coord2 + right] == "M"
  end

end

class Human

end