class Mover
  attr_accessor :space, :vectors

  def initialize space
    self.space = space
    self.vectors = {}
  end

  def push thing, direction, force=0.1
    case direction
    when :forward then vector(thing).front += force
    when :back    then vector(thing).front -= force
    when :left    then vector(thing).left  += force
    when :right   then vector(thing).left  -= force
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
