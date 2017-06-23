class Projector
  attr_accessor :canvas, :offset, :scale

  def initialize canvas, offset, scale=1
    self.canvas = canvas
    self.offset = offset
    self.scale = scale
  end

  def circle opts
    args = { center: true }
    args[:left] = (opts[:left] || 0) + offset.left
    args[:top] = (opts[:front] || 0) + offset.front
    args[:radius] = (opts[:radius] || 1) * scale
    color = opts[:color] || :blue
    canvas.fill canvas.send(color)
    canvas.oval args
  end
end
