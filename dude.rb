class DudeAvatar
  def project projector
    projector.circle(fill: :red, stroke: :black, left: 0, front: 0, radius: 4)
  end
end

class Dude
  extend Forwardable

  def_delegator :dude_avatar, :project

  def dude_avatar
    DudeAvatar.new
  end
end
