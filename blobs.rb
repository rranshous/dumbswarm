
class WonderBlob

  attr_accessor :x, :y, :radius, :vector

  def initialize
    self.x, self.y = [rand(0..400), rand(0..400)]
    self.vector = [rand(-1..1), rand(-1..1)]
    self.radius = rand(10..100)
  end

  def render pallete
    pallete.fill pallete.green
    pallete.stroke pallete.yellow
    pallete.oval @y, @x, radius: self.radius
  end

  def tick _
    self.x += vector[0] if rand(0..1) == 0
    self.y += vector[1] if rand(0..1) == 0
  end
end

class FollowBlob

  attr_accessor :x, :y, :radius, :vector, :target

  def initialize
    self.x, self.y = [rand(0..400), rand(0..400)]
    self.vector = [rand(-1..1), rand(-1..1)]
    self.radius = rand(10..30)
  end

  def render pallete
    pallete.fill pallete.red
    pallete.stroke pallete.yellow
    pallete.oval(@y, @x, radius: self.radius, center: true)
  end

  def tick neighbors
    self.target ||= neighbors.sample
    self.head_toward(self.target)
    self.update_position
  end

  def head_toward other
    self.vector[0] = [[(-(self.x - other.x)), -1].max, 1].min
    self.vector[1] = [[(-(self.y - other.y)), -1].max, 1].min
  end

  def update_position
    self.x += self.vector[0]
    self.y += self.vector[1]
  end
end

class RepelBlob
  attr_accessor :x, :y, :radius, :vector, :target

  def initialize
    self.x, self.y = [rand(0..400), rand(0..400)]
    self.vector = [rand(-1..1), rand(-1..1)]
    self.radius = rand(10..30)
  end

  def render pallete
    pallete.fill pallete.blue
    pallete.stroke pallete.yellow
    pallete.oval(@y, @x, radius: self.radius, center: true)
  end

  def tick neighbors
    self.target ||= neighbors.sample
    self.head_away(self.target)
    self.update_position
  end

  def head_away other
    self.vector[0] = [[((self.x - other.x)), -1].max, 1].min
    self.vector[1] = [[((self.y - other.y)), -1].max, 1].min
  end

  def update_position
    self.x += self.vector[0]
    self.y += self.vector[1]
  end
end
