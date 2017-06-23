require 'shoes'
require 'ostruct'
require 'forwardable'
require_relative 'projector'
require_relative 'dude'
require_relative 'space'

FPS = 30
WINDOW_WIDTH=400
WINDOW_HEIGHT=400
SPEED = WINDOW_WIDTH / 2 / 10

center = OpenStruct.new(left: WINDOW_WIDTH / 2, front: WINDOW_HEIGHT/2)
dude = Dude.new
space = Space.new WINDOW_WIDTH, WINDOW_HEIGHT
space.add dude, center

Shoes.app width: WINDOW_WIDTH, height: WINDOW_HEIGHT, :title => 'and such' do
  keypress do |key|
    case key
    when "w" then space.move dude, :forward, SPEED
    when "s" then space.move dude, :back, SPEED
    when "a" then space.move dude, :left, SPEED
    when "d" then space.move dude, :right, SPEED
    end
  end
  animate FPS do
    begin
      clear
      projector = Projector.new self, space.position_of(dude), 10
      dude.project projector
    rescue => ex
      puts "EX: #{ex}"
    end
  end
end

