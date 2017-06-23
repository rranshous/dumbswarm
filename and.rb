require 'shoes'
require 'ostruct'
require 'forwardable'
require_relative 'projector'
require_relative 'dude'
require_relative 'space'
require_relative 'mover'

FPS = 30
WINDOW_WIDTH=400
WINDOW_HEIGHT=400
SPEED = WINDOW_WIDTH / 2 / 10

center = OpenStruct.new(left: WINDOW_WIDTH / 2, front: WINDOW_HEIGHT/2)
dude = Dude.new
space = Space.new WINDOW_WIDTH, WINDOW_HEIGHT
mover = Mover.new space
space.add dude, center

Shoes.app width: WINDOW_WIDTH, height: WINDOW_HEIGHT, :title => 'and such' do
  keypress do |key|
    case key
    when "w" then mover.push dude, :forward
    when "s" then mover.push dude, :back
    when "a" then mover.push dude, :left
    when "d" then mover.push dude, :right
    end
  end
  animate FPS do
    begin
      clear
      projector = Projector.new self, space.position_of(dude), 10
      dude.project projector
      mover.tick
    rescue => ex
      puts "EX: #{ex}"
    end
  end
end

