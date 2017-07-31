require 'shoes'
require_relative 'keyboard'

FPS = 10
WINDOW_WIDTH=100
WINDOW_HEIGHT=100

class Canvas
  attr_accessor :shoe

  def initialize shoe
    self.shoe = shoe
  end

  def fill locatable
    print 'f'
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
    space.each do |locatable|
      cells[position(locatable)] = Cell.new(left: locatable.left, up: locatable.up)
    end
  end

  def at locatable
    cells[position(locatable)]
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
    self.fills = opts[:fills] if opts[:fills]
  end

  def cells cellspace, center
    fills.map {|fill| cellspace.at Locatable.add(center, fill) }
  end
end

class Entity
  # include SpaceTaker
  attr_accessor :cells
  include Locatable
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
      forward_sort(space_taker.cells).each do |cell|
        next_pos = Locatable.add cell, Position.new(left: 0, up: 1)
        next_cell = cellspace.at next_pos
        cellspace.swap next_cell, cell
      end
    end
  end

  def forward_sort cells
    cells.sort_by(&:left).sort_by(&:up).reverse
  end
end


screen = Screen.new height: WINDOW_HEIGHT, width: WINDOW_WIDTH
puts "pixels: #{screen.pixels.to_a.length}"
cellspace = Cellspace.new
cellspace.populate screen.pixels
active_cell = cellspace.at(Position.new(left: 10, up: 10))
active_cell.content = true
puts "set content on: #{active_cell}"
puts "cells: #{cellspace.cells.length}"
painter = Painter.new

line = Shape.new(fills: [Position.new(left: 0,  up: 0),
                         Position.new(left: 1,  up: 0),
                         Position.new(left: -1, up: 0)])
entity = Entity.new
entity.cells = cellspace.for line, Position.new(left: 0, up: 0)

mover = Mover.new
mover.cellspace = cellspace

Shoes.app width: WINDOW_WIDTH, height: WINDOW_HEIGHT, :title => 'gridwork' do
  painter.canvas = Canvas.new self
  keyboard = Keyboard.new self
  keyboard_interpreter = KeyboardInterpreter.new keyboard
  animate FPS do
    begin
      puts "start"
      clear

      entity.paint painter

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

      #screen.pixels.each do |pixel|
      #  cell = cellspace.at pixel
      #  cell.fill painter
      #end
      #next_cell = cellspace.at Position.new(left: active_cell.left,
      #                                        up: active_cell.up+1)
      #cellspace.swap next_cell, active_cell
