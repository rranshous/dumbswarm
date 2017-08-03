
module Locatable
  def left= mag; @left = mag; end
  def left; @left; end
  def up= mag; @up = mag; end
  def up; @up; end

  def position= locatable
    self.left = locatable.left
    self.up   = locatable.up
  end

  def overlap? locatable
    left == locatable.left && up == locatable.up
  end

  def x space
    (space.width / 2) - left
  end

  def y space
    (space.height / 2) - up
  end

  def self.add l1, l2
    Position.new(left: l1.left + l2.left,
                 up:   l1.up   + l2.up)
  end
end

module SpaceTaker
  def collide spacetaker1, spacetaker2
  end

  def cells= cells
    @cells = cells
  end

  def cells= cells
    @cells = cells
    cells.each {|c| c.content = self }
  end
end

module Paintable
  def visible?
    false
  end

  def paint painter
    painter.fill self
  end
end

module Wanderer
  def act body, enacter
    case rand(4)
    when 0 then body.move :forward, enacter
    when 1 then body.move :backward, enacter
    when 2 then body.move :left, enacter
    when 3 then body.move :right, enacter
    end
  end
end

module Seeker

  def observe body, context
    @foes = context[:foes]
    @foe = @foes.first
  end

  def act body, enacter
    if @foe.alive?
      if @foe.left > body.left
        body.move :left, enacter
      elsif @foe.left < body.left
        body.move :right, enacter
      end
      if @foe.up > body.up
        body.move :forward, enacter
      elsif @foe.up < body.up
        body.move :back, enacter
      end
    end
  end
end

