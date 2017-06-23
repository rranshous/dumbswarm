class Dude
  def project projector
    projector.circle(self,
                     color: :red, stroke: :black, left: 0, front: 0, radius: 4)
  end
end
