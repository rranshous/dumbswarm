require 'shoes'
require 'ostruct'
require_relative 'objs'

FPS = 60
WINDOW_WIDTH=1000
WINDOW_HEIGHT=800

screen = Screen.new height: WINDOW_HEIGHT, width: WINDOW_WIDTH
cellspace = Cellspace.new
cellspace.populate screen.pixels
painter = Painter.new

mover = Mover.new
mover.cellspace = cellspace

friend = Particle.new(cell: cellspace.at(Position.new(left: 0, up: 0)),
                      brain: Brain.new.extend(Seeker),
                      energy: EnergyCell.new(5))
foe    = Particle.new(cell: cellspace.at(Position.new(left: 0, up: 200)),
                      brain: Brain.new.extend(Wanderer),
                      energy: EnergyCell.new(5))

Shoes.app width: WINDOW_WIDTH, height: WINDOW_HEIGHT, :title => 'gridwork' do
  painter.canvas = Canvas.new self
  animate FPS do
    begin
      painter.clear
      friend.observe OpenStruct.new(foes: [foe])
      friend.act mover
      foe.act mover
      friend.paint painter
      foe.paint painter
    rescue => ex
      puts "EXO: #{ex}"
      puts "  : #{ex.backtrace}"
      raise
    end
  end
end
