require 'shoes'
require 'ostruct'
require_relative 'objs'

FPS = 30

WINDOW_WIDTH=1000
WINDOW_HEIGHT=800

screen = Screen.new height: WINDOW_HEIGHT, width: WINDOW_WIDTH
cellspace = Cellspace.new
cellspace.populate screen.pixels
painter = Painter.new

mover = Mover.new
mover.cellspace = cellspace

create_foe = lambda {
  cell = cellspace.at(Position.new(left: rand(-200..200), up: rand(-200..200)))
  Particle.new(cell: cell,
               brain: Brain.new.extend(Wanderer),
               energy: EnergyCell.new(5))
}
cannon = ParticleCannon.new
cannon.position = Position.new(left: -100, up: -100)
foes = ([nil]*100).map{ create_foe.call() }
particles = foes.dup

Shoes.app width: WINDOW_WIDTH, height: WINDOW_HEIGHT, :title => 'gridwork' do
  painter.canvas = Canvas.new self
  animate FPS do |i|
    begin
      painter.clear
      particles.each {|p| p.paint painter }

      particles.each do |particle|
        context = OpenStruct.new(foes: foes.select {|p| p.alive? })
        particle.observe context
        particle.act mover
      end
      cannon.observe OpenStruct.new(particles: particles, cellspace: cellspace)
      cannon.act OpenStruct.new(particles: particles)
    rescue => ex
      puts "EXO: #{ex}"
      puts "  : #{ex.backtrace}"
      raise
    end
  end
end
