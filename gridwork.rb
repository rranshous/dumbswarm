require 'shoes'

FPS = 60
WINDOW_WIDTH=900
WINDOW_HEIGHT=1100

screen = Screen.new height: WINDOW_HEIGHT, width: WINDOW_WIDTH
cellspace = Cellspace.new
cellspace.populate screen.pixels
canvas = nil
painter = Painter.new canvas

Shoes.app width: WINDOW_WIDTH, height: WINDOW_HEIGHT, :title => 'gridwork' do
  screen.pixels.each do |pixel|
    cellspace.at(pixel).each {|c| c.fill painter }
  end
end

class Cellspace
  attr_accessor :cells

  def initialize
    self.cells = []
  end

  def populate space
    space.each do |locatable|
      cells << Cell.new(left: locatable.left, up: locatable.up)
    end
  end

  def at locatable
    cells.select {|c| c.overlap? locatable }
  end
end

module Locatable
  def left= mag; @left = mag; end
  def left; @left; end
  def right= mag; @right = mag; end
  def right; @right; end

  def overlap? locatable
    left == locatable.left && up == locatable.up
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

class Cell
  include Locatable
  include Paintable

  attr_accessor content

  def initialize opts
    self.left  = opts[:left]  if !opts[:left].nil?
    self.right = opts[:right] if !opts[:right].nil?
  end

  def visible?
    !content.empty?
  end
end

class Pixel
  include Locatable
  def initialize opts
    self.left  = opts[:left]  if !opts[:left].nil?
    self.right = opts[:right] if !opts[:right].nil?
  end
end

class Painter
  attr_accessor :canvas

  def fill paintable
    if paintable.visible?
      canvas.paint paintable.offset
    else
      canvas.clear paintable.offset
    end
  end
end

class Screen
  attr_accessor :width, :height

  def initialize opts
    self.height = opts[:height] if opts[:height]
    self.width  = opts[:width]  if opts[:width]
  end

  def pixels
    Enumerator.new do |yielder|
      (-half_width..half_width).each do |x|
        (-half_height..half_height).reverse.each do |y|
          yielder.call Pixel.new(left: x, up: y)
        end
      end
    end
  end

  def half_width
    width / 2
  end

  def half_height
    height / 2
  end
end
