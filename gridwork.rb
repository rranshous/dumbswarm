require 'shoes'

FPS = 1
WINDOW_WIDTH=100
WINDOW_HEIGHT=100

class Canvas
  attr_accessor :shoe

  def initialize shoe
    self.shoe = shoe
    puts 'new canvas'
  end

  def paint locatable
    print 'p'
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
    puts 'new cellspace'
  end

  def populate space
    space.each do |locatable|
      cells[position(locatable)] = Cell.new(left: locatable.left, up: locatable.up)
    end
  end

  def at locatable
    cells[position(locatable)]
  end

  def position locatable
    [locatable.left, locatable.up]
  end
end

module Locatable
  def left= mag; @left = mag; end
  def left; @left; end
  def up= mag; @up = mag; end
  def up; @up; end

  def overlap? locatable
    left == locatable.left && up == locatable.up
  end

  def x(space)
    (space.width / 2) + left
  end

  def y(space)
    (space.height / 2) - up
  end
end

module Paintable
  def visible?
    false
  end

  def fill painter
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
    puts 'new cell'
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
    puts 'new pixel'
  end
end

class Painter
  attr_accessor :canvas

  def fill paintable
    if paintable.visible?
      canvas.paint paintable
    end
  end
end

class Screen
  attr_accessor :width, :height, :pixels

  def initialize opts
    self.height = opts[:height] if opts[:height]
    self.width  = opts[:width]  if opts[:width]
    self.pixels = self.class.create_pixels self.height, self.width
    puts 'new screen'
  end

  def self.create_pixels width, height
    pixels = []
    half_width  = width / 2
    half_height = height / 2
    (-half_width..half_width).each do |w|
      (-half_height..half_height).to_a.reverse.each do |h|
        pixels << Pixel.new(left: w, up: h)
      end
    end
    pixels
  end
end


screen = Screen.new height: WINDOW_HEIGHT, width: WINDOW_WIDTH
puts "pixels: #{screen.pixels.to_a.length}"
cellspace = Cellspace.new
cellspace.populate screen.pixels
puts "cells: #{cellspace.cells.length}"
painter = Painter.new

Shoes.app width: WINDOW_WIDTH, height: WINDOW_HEIGHT, :title => 'gridwork' do
  painter.canvas = Canvas.new self
  animate FPS do
    begin
      puts "start"
      clear
      screen.pixels.each do |pixel|
        cell = cellspace.at(pixel)
        cell.fill painter
      end
    rescue => ex
      puts "EXO: #{ex}"
      puts "  : #{ex.backtrace}"
      raise
    end
  end
end
