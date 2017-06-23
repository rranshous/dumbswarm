class Keyboard

  attr_accessor :keys_down

  def initialize input
    self.setup_listeners input
    self.keys_down = {}
  end

  def pressed? key
    self.keys_down[key] == true
  end

  def setup_listeners input
    input.keydown { |*args| keydown(*args) }
    input.keyup   { |*args| keyup(*args) }
  end

  def keydown key
    self.keys_down[key] = true
  end

  def keyup key
    self.keys_down[key] = false
  end
end

class KeyboardInterpreter
  attr_accessor :target, :keyboard, :mover

  def initialize target, keyboard, mover
    self.keyboard = keyboard
    self.mover = mover
    self.target = target
  end

  def tick
    mapping.each do |direction, keys|
      keys.each do |key|
        mover.push target, direction if keyboard.pressed? key
      end
    end
    #mover.push target, :forward if keyboard.pressed? :up
    #mover.push target, :back    if keyboard.pressed? :down
    #mover.push target, :left    if keyboard.pressed? :left
    #mover.push target, :right   if keyboard.pressed? :right
  end

  def mapping
    { forward: [:up, "w"],
      back:    [:down, "s"],
      left:    [:left, "a"],
      right:   [:right, "d"] }
  end
end
