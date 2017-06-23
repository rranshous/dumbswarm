class Space
  attr_accessor :width, :height, :things

  def initialize width, height
    self.width = width
    self.height = height
    self.things = {}
  end

  def add thing, position
    things[thing] = position
  end

  def position_of thing
    things[thing]
  end

  def move thing, direction, distance=1
    case direction
    when :forward then things[thing].front -= distance
    when :back    then things[thing].front += distance
    when :left    then things[thing].left  -= distance
    when :right   then things[thing].left  += distance
    end
  end
end
