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
                      energy: EnergyCell.new(100))
friend.cell.color = :red
friend.cell.radius = 5
create_foe = lambda {
  cell = cellspace.at(Position.new(left: rand(-200..200), up: rand(-200..200)))
  Particle.new(cell: cell,
               brain: Brain.new.extend(Wanderer),
               energy: EnergyCell.new(5))
}
foes = ([nil]*100).map{ create_foe.call() }
particles = [friend] + foes

Shoes.app width: WINDOW_WIDTH, height: WINDOW_HEIGHT, :title => 'gridwork' do
  painter.canvas = Canvas.new self
  animate FPS do
    begin
      painter.clear
      particles.each do |particle|
        particle.observe OpenStruct.new(foes: foes)
        particle.act mover
        particle.paint painter
      end
    rescue => ex
      puts "EXO: #{ex}"
      puts "  : #{ex.backtrace}"
      raise
    end
  end
end
