class Mover
  attr_accessor :space, :vectors

  def initialize space
    self.space = space
    self.vectors = {}
  end

  def push thing, direction
    case direction
    when :forward then vector(thing).front += 1
    when :back    then vector(thing).front -= 1
    when :left    then vector(thing).left  += 1
    when :right   then vector(thing).left  -= 1
    end
  end

  def tick
    vectors.each do |thing, vector|
      space.move thing, :forward, vector(thing).front
      space.move thing, :left,    vector(thing).left
    end
  end

  def vector thing
    self.vectors[thing] ||= Vector.new
  end
end
