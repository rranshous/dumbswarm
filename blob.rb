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

