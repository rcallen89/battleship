require './lib/cell'
require 'colorize'

class Board
  attr_reader :cells, :raw_cells_keys, :game_type

  def initialize(game_type = "1")
    @game_type = game_type
    @raw_cells_keys = []
    @cells = cell_generator(game_type)
  end

  def cell_generator(game_type)
    (game_type != "2") ? (range = ("A".."D").to_a) : (range = ("A".."I").to_a)

    cells = {}

    create_cell_names(range).each { |key| cells[key] = Cell.new(key) }

    @raw_cells_keys = cells.keys

    sorted_hash = cells.sort_by { |k, v| k }

    sorted_hash.to_h
  end

  def validate_coordinates?(coordinate)
    @cells.keys.include?(coordinate)
  end

  def valid_placement?(ship, ship_coords)
    return false if pass_valid_guards?(ship, ship_coords) == false

    check_alignment?(ship_coords)
  end

  def align_verified?(ship_coords)
    if horizontal_check(ship_coords).length == 1
      true
    elsif vertical_check(ship_coords).length == 1
      false
    end
  end

  def place(ship, ship_coords)
    return false if valid_placement?(ship, ship_coords) == false

    ship_coords.each { |coord| @cells[coord].place_ship(ship) }
  end

  # :nocov:
  def render(player = false)
    range = Math.sqrt(@cells.length)
    render_array = @cells.values.each_slice(range).to_a

    if @game_type != "2"
      print "  1 2 3 4 \n".colorize(:yellow)
    else
      print "  1 2 3 4 5 6 7 8 9 \n".colorize(:yellow)
    end

    render_array(render_array, player)
  end
  # :nocov:

  def pass_valid_guards?(ship, ship_coords)
    ship_coords.each do |coord|
      return false if validate_coordinates?(coord) == false
    end

    ship_coords.each do |coord|
      return false if @cells[coord].ship != nil
    end

    return false if ship_coords.length != ship.ship_length

    true
  end

  def horizontal_check(ship_coords)
    horizontal_check = ship_coords.map do |letter|
      letter.split(//)[0]
    end

    horizontal_check.uniq
  end

  def vertical_check(ship_coords)
    vertical_check = ship_coords.map do |letter|
      letter.split(//)[1]
    end

    vertical_check.uniq
  end

  # :nocov:
  def render_array(render_array, player)
    render_array.each do |row|
      print (row[0].coordinate.split(//)[0] + " ").colorize(:yellow)
  
      row.each { |cell| print cell.render(player) + " " }
  
      print "\n"
    end
  end
  # :nocov:

  def check_alignment?(ship_coords)
    if align_verified?(ship_coords)
      start_point = @cells.keys.index(ship_coords[0])
      ship_coords == @cells.keys.slice((start_point), (ship_coords.length))

    elsif align_verified?(ship_coords) == false
      start_point = @raw_cells_keys.index(ship_coords[0])
      ship_coords == @raw_cells_keys.slice((start_point), (ship_coords.length))

    else
      false
    end
  end

  def create_cell_names(range)
    hash_keys = []

    range.length.times do |num|
      range.each do |letter|
        hash_keys.push(letter + (num + 1).to_s)
      end
    end

    return hash_keys
  end
end
