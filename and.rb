require 'shoes'
require 'ostruct'
require 'forwardable'
require_relative 'projector'
require_relative 'dude'
require_relative 'space'
require_relative 'mover'
require_relative 'keyboard'

FPS = 60
WINDOW_WIDTH=900
WINDOW_HEIGHT=1100

center = Position.new(WINDOW_WIDTH / 2, WINDOW_HEIGHT/2)
dude = Dude.new
space = Space.new WINDOW_WIDTH, WINDOW_HEIGHT
mover = Mover.new space
space.add dude, center

Shoes.app width: WINDOW_WIDTH, height: WINDOW_HEIGHT, :title => 'and such' do
  begin
    projector = Projector.new self, space, 10
    keyboard = Keyboard.new self
    keyboard_interpreter = KeyboardInterpreter.new keyboard
    animate FPS do
      begin
        clear
        projector.project dude
        dude.project projector
        keyboard_interpreter.directions.each do |direction|
          mover.push dude, direction
        end
        mover.tick
      rescue => ex
        puts "EX: #{ex}"
        puts "  : #{ex.backtrace}"
        raise
      end
    end
  rescue => ex
    puts "EXO: #{ex}"
    puts "  : #{ex.backtrace}"
    raise
  end
end

