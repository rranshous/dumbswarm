class Projector
  attr_accessor :canvas, :locator, :scale

  def initialize canvas, locator, scale=1
    self.canvas = canvas
    self.scale = scale
    self.locator = locator
  end

  def project thing
    thing.project self
  end

  def circle thing, opts
    args = { center: true }
    args[:left] = (opts[:left] || 0) + locator.position(thing).left
    args[:top] = (opts[:front] || 0) + locator.position(thing).front
    args[:radius] = (opts[:radius] || 1) * scale
    color = opts[:color] || :blue
    canvas.fill canvas.send(color)
    canvas.oval args
  end
end
