class Space
  attr_accessor :width, :height, :things

  def initialize width, height
    self.width  = width
    self.height = height
    self.things = {}
  end

  def add thing, position
    things[thing] = position
  end

  def move thing, direction, distance=1
    case direction
    when :forward then position(thing).front -= distance
    when :back    then position(thing).front += distance
    when :left    then position(thing).left  -= distance
    when :right   then position(thing).left  += distance
    end
  end

  def position thing
    things[thing]
  end
end

class Vector
  attr_accessor :left, :front

  def initialize left=0, front=0
    self.left = left
    self.front = front
  end
end

class Position < Vector
end
