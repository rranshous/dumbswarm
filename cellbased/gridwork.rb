require 'shoes'
require_relative 'objs'

FPS = 60
WINDOW_WIDTH=1000
WINDOW_HEIGHT=1000


screen = Screen.new height: WINDOW_HEIGHT, width: WINDOW_WIDTH
puts "pixels: #{screen.pixels.to_a.length}"
cellspace = Cellspace.new
painter = Painter.new

line = Line.new length: 40
box = Box.new width: 20
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
