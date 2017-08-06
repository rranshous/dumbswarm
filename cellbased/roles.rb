
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

  def left_of? locatable
    return false if left.nil?
    left > locatable.left
  end
  def right_of? locatable
    return false if left.nil?
    left < locatable.left
  end
  def above? locatable
    return false if up.nil?
    up > locatable.up
  end
  def below? locatable
    return false if up.nil?
    up < locatable.up
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

  def radius
    @radius ||= 1
  end
  def radius= radius
    @radius = radius
  end

  def color
    @color ||= :black
  end
  def color= color
    @color = color
  end

end

module Wanderer
  def act body, enacter
    body.move([:forward, :back, :left, :right].sample, enacter)
  end
end

module Seeker

  def observe body, context
    @foes = context[:foes]
    if !@foes.include? @foe
      @foe = @foes.sample
    end
  end

  def act body, enacter
    if @foe && @foe.alive?
      if @foe.left_of? body
        body.move :left, enacter
      elsif @foe.right_of? body
        body.move :right, enacter
      end
      if @foe.above? body
        body.move :forward, enacter
      elsif @foe.below? body
        body.move :back, enacter
      end
    end
  end
end

