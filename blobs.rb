class Blob

  SIZE_SCALER = 4

  attr_accessor :x, :y, :size, :vector

  def initialize
    self.x = self.start_x
    self.y = self.start_y
    self.vector = self.start_vector
  end

  def start_x
    raise NotImplimentedError
  end

  def start_y
    raise NotImplimentedError
  end

  def start_vector
    raise NotImplimentedError
  end

  def size
    raise NotImplimentedError
  end

  def fill_color
    raise NotImplimentedError
  end

  def stroke_color
    raise NotImplimentedError
  end

  def update_vector neighbors
  end

  def render pallete
    pallete.fill pallete.public_send(self.fill_color)
    pallete.stroke pallete.public_send(self.stroke_color)
    pallete.oval(self.y, self.x, radius: self.size * SIZE_SCALER, center: true)
  end

  def tick neighbors
    self.update_vector neighbors
    self.update_position
  end

  def update_position
    self.x += self.vector[0]
    self.y += self.vector[1]
  end
end

class WonderBlob < Blob

  def start_x
    rand(20..300)
  end

  def start_y
    rand(20..300)
  end

  def start_vector
    [rand(0..1), rand(0..1)]
  end

  def size
    10
  end

  def fill_color
    :green
  end

  def stroke_color
    :yellow
  end

  def update_position
    self.x += self.vector[0] if rand(0..1) == 0
    self.y += self.vector[1] if rand(0..1) == 0
  end
end

class FollowBlob < Blob
  attr_accessor :target

  def start_x
    rand(0..400)
  end

  def start_y
    rand(0..200)
  end

  def start_vector
    [rand(0..1), rand(0..1)]
  end

  def size
    2
  end

  def fill_color
    :red
  end

  def stroke_color
    :yellow
  end

  def update_vector neighbors
    self.target ||= neighbors.sample
    self.head_toward self.target
  end

  def head_toward other
    self.vector[0] = [[(-(self.x - other.x)), -2].max, 2].min
    self.vector[1] = [[(-(self.y - other.y)), -2].max, 2].min
  end
end

class RepelBlob < Blob
  attr_accessor :target

  def start_x
    rand(0..200)
  end

  def start_y
    rand(0..400)
  end

  def start_vector
    [rand(0..1), rand(0..1)]
  end

  def size
    4
  end

  def fill_color
    :blue
  end

  def stroke_color
    :yellow
  end

  def update_vector neighbors
    self.target = neighbors.sample
    self.head_away self.target
  end

  def head_away other
    self.vector[0] = [[((self.x - other.x)), -1].max, 1].min
    self.vector[1] = [[((self.y - other.y)), -1].max, 1].min
  end
end
