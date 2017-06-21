require_relative 'blob'

module Tracker
  def distance other=nil
    # x2 + y2 = z2 # pthag bitches
    return 0 if other.nil?
    Math.sqrt((self.x - other.x).abs2 + (self.y - other.y).abs2)
  end

  def head_toward other
    return 0 if other.nil?
    self.vector[0] = [[(-(self.x - other.x)), -2].max, 2].min
    self.vector[1] = [[(-(self.y - other.y)), -2].max, 2].min
  end

  def head_away other
    return 0 if other.nil?
    self.vector[0] = [[((self.x - other.x)), -1].max, 1].min
    self.vector[1] = [[((self.y - other.y)), -1].max, 1].min
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
  include Tracker

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
    default = 4
    [self.distance(self.target) / 10, default].max
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
end

class RepelBlob < Blob
  include Tracker

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
end
