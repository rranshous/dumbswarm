require 'shoes'
require_relative 'keyboard'

FPS = 60
WINDOW_WIDTH=1000
WINDOW_HEIGHT=1000

class Canvas
  attr_accessor :shoe

  def initialize shoe
    self.shoe = shoe
  end

  def fill locatable
    shoe.fill shoe.red
    shoe.oval left: locatable.x(shoe),
              top: locatable.y(shoe),
              radius: 1
  end
end

class Cellspace
  attr_accessor :cells

  def initialize
    self.cells = {}
  end

  def populate space
    #space.each do |locatable|
    #  cells[position(locatable)] = Cell.new(left: locatable.left,
    #                                        up: locatable.up)
    #end
  end

  def at locatable
    cells[position(locatable)] ||= Cell.new(left: locatable.left,
                                            up: locatable.up)
  end

  def for shape, center
    shape.cells(self, center)
  end

  def swap cell1, cell2
    left, up               = cell2.left, cell2.up
    cell2.left, cell2.up   = cell1.left, cell1.up
    cell1.left, cell1.up   = left, up
    cells[position(cell1)] = cell1
    cells[position(cell2)] = cell2
  end

  def center cells
    left = cells.sort_by { |c| c.left }.first
    right = cells.sort_by { |c| -c.left }.first
    top = cells.sort_by { |c| c.up }.first
    bottom = cells.sort_by { |c| -c.up }.first
    left_avg = ((left.left + right.left).to_f / 2).to_i
    up_avg = ((top.up + bottom.up).to_f / 2).to_i
    Position.new(left: left_avg, up: up_avg)
  end

  private

  def position locatable
    [locatable.left, locatable.up]
  end
end

module Locatable
  def left= mag; @left = mag; end
  def left; @left; end
  def up= mag; @up = mag; end
  def up; @up; end

  def position= locatable
    self.left = locatable.left
    self.up   = locatable.up
  end

  def overlap? locatable
    left == locatable.left && up == locatable.up
  end

  def x space
    (space.width / 2) - left
  end

  def y space
    (space.height / 2) - up
  end

  def self.add l1, l2
    Position.new(left: l1.left + l2.left,
                 up:   l1.up   + l2.up)
  end
end

class Position
  include Locatable
  def initialize opts
    self.left  = opts[:left]  if !opts[:left].nil?
    self.up    = opts[:up]    if !opts[:up].nil?
  end
end

module Paintable
  def visible?
    false
  end

  def paint painter
    painter.fill self
  end
end

class Object
  def empty?
    false
  end
end

class NilClass
  def empty?
    true
  end
end

class Cell
  include Locatable
  include Paintable

  attr_accessor :content

  def initialize opts
    self.left  = opts[:left]  if !opts[:left].nil?
    self.up    = opts[:up]    if !opts[:up].nil?
  end

  def visible?
    !content.empty?
  end

  def to_s
    "<Cell #{left}:#{up}-#{visible?}>"
  end

  def inspect
    to_s
  end
end

class Pixel
  include Locatable
  def initialize opts
    self.left  = opts[:left]  if !opts[:left].nil?
    self.up    = opts[:up]    if !opts[:up].nil?
  end
end

class Painter
  attr_accessor :canvas

  def fill paintable
    if paintable.visible?
      canvas.fill paintable
    end
  end
end

class Screen
  attr_accessor :width, :height, :pixels

  def initialize opts
    self.height = opts[:height] if opts[:height]
    self.width  = opts[:width]  if opts[:width]
    self.pixels = self.class.create_pixels self.height, self.width
  end

  def self.create_pixels width, height
    pixels = []
    half_width  = width / 2
    half_height = height / 2
    (-half_width..half_width).each do |w|
      (-half_height..half_height).each do |h|
        pixels << Pixel.new(left: w, up: h)
      end
    end
    pixels
  end
end

class Shape
  attr_accessor :fills

  def initialize opts
    self.fills = opts[:fills] || []
    populate_fills opts
  end

  def cells cellspace, center
    fills.map {|fill| cellspace.at Locatable.add(center, fill) }.uniq
  end

  def populate_fills opts
  end
end

class Box < Shape
  def populate_fills opts
    half_width = opts[:width] / 2
    (-half_width..half_width).each do |i|
      self.fills << Position.new(left: i, up: half_width)
      self.fills << Position.new(left: i, up: -half_width)
      self.fills << Position.new(left: half_width, up: i)
      self.fills << Position.new(left: -half_width, up: i)
    end
  end
end

class Line < Shape
  def populate_fills opts
    half_length = opts[:length] / 2
    (-half_length..half_length).each do |i|
      self.fills << Position.new(left: i, up: 0)
    end
  end
end

class Entity
  # include SpaceTaker
  attr_accessor :cells
  include Paintable

  def visible?
    true
  end

  def cells= cells
    @cells = cells
    cells.each {|c| c.content = self }
  end

  def paint painter
    cells.each do |cell|
      cell.paint painter
    end
  end
end

class Mover
  attr_accessor :cellspace

  def move space_taker, direction
    case direction
    when :forward
      _move forward_sort(space_taker.cells), 0, 1
    when :back
      _move back_sort(space_taker.cells), 0, -1
    when :left
      _move left_sort(space_taker.cells), 1, 0
    when :right
      _move right_sort(space_taker.cells), -1, 0
    when :rotate_right
      rotate space_taker, -15
    when :rotate_left
      rotate space_taker, 15
    end
  end

  private

  def rotate space_taker, degrees
    angle = degrees * Math::PI / 180
    handled = []
    center = cellspace.center(space_taker.cells)
    puts "center: #{center}"
    space_taker.cells.each do |cell|
      next if handled.include? cell
      puts "cell initial: #{cell}"
      x1 = -cell.left - -center.left
      y1 = cell.up - center.up
      x2 = x1 * Math.cos(angle) - y1 * Math.sin(angle)
      y2 = x1 * Math.sin(angle) + y1 * Math.cos(angle)
      to_swap_pos = Position.new(left: -x2, up: y2)
      puts "to swap pos: #{to_swap_pos}"
      to_swap_pos = Locatable.add center, to_swap_pos
      puts "to swap pos2: #{to_swap_pos}"
      to_swap = cellspace.at to_swap_pos
      cellspace.swap cell, to_swap
      handled += [to_swap, cell]
    end
  end

  def _move cells, left, up
    swap_history = []
    cells.each do |cell|
      next_pos = Locatable.add cell, Position.new(left: left, up: up)
      next_cell = cellspace.at next_pos
      if active?(cell, next_cell)
        unwind swap_history
        return false
      end
      swap_history << [cell, next_cell]
      cellspace.swap(cell, next_cell)
    end
    true
  end

  def transpose locatable, center
    diff = (locatable.left - center.left).abs
    left_of = locatable.left < center.left
    if left_of
      left_offset = locatable.left + diff * 2
    else
      left_offset = locatable.left - diff * 2
    end
    diff = (locatable.up - center.up).abs
    above = locatable.up > center.up
    if above
      up_offset = locatable.up - diff * 2
    else
      up_offset = locatable.up + diff * 2
    end
    Position.new(left: left_offset,
                 up:   up_offset)
  end

  def reverse locatable, center
    diff = (locatable.left - center.left).abs
    left_of = locatable.left < center.left
    if left_of
      left_offset = locatable.left + diff * 2
    else
      left_offset = locatable.left - diff * 2
    end
    Position.new(left: left_offset,
                 up:   locatable.up)
  end

  def active? *space_takers
    space_takers.all? {|s| s.visible? }
  end

  def unwind swap_history
    swap_history.reverse.each do |(c1, c2)|
      cellspace.swap(c2, c1)
    end
  end

  def forward_sort cells
    cells.sort_by(&:left).sort_by(&:up).reverse
  end

  def back_sort cells
    cells.sort_by(&:left).sort_by(&:up)
  end

  def left_sort cells
    cells.sort_by(&:up).sort_by(&:left).reverse
  end

  def right_sort cells
    cells.sort_by(&:up).sort_by(&:left)
  end
end


screen = Screen.new height: WINDOW_HEIGHT, width: WINDOW_WIDTH
puts "pixels: #{screen.pixels.to_a.length}"
cellspace = Cellspace.new
cellspace.populate screen.pixels
painter = Painter.new

line = Line.new length: 10
box = Box.new width: 10
entity = Entity.new
entity.cells = cellspace.for line, Position.new(left: 0, up: 0)
wall = Entity.new
wall.cells = cellspace.for box, Position.new(left: -100, up: 100)

mover = Mover.new
mover.cellspace = cellspace

Shoes.app width: WINDOW_WIDTH, height: WINDOW_HEIGHT, :title => 'gridwork' do
  painter.canvas = Canvas.new self
  keyboard = Keyboard.new self
  keyboard_interpreter = KeyboardInterpreter.new keyboard
  animate FPS do
    begin
      clear
      entity.paint painter
      wall.paint painter
      keyboard_interpreter.directions.each do |direction|
        mover.move entity, direction
      end
    rescue => ex
      puts "EXO: #{ex}"
      puts "  : #{ex.backtrace}"
      raise
    end
  end
end
