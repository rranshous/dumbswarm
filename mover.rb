class Mover
  attr_accessor :space, :pending_moves

  def initialize space
    self.space = space
    self.pending_moves = {}
  end

  def push thing, direction
    enqueue_push thing, direction
  end

  def tick
    pending_moves.each do |thing, moves|
      next_move = moves.shift
      space.move thing, next_move
      moves << next_move if moves.empty?
    end
  end

  def enqueue_push thing, direction
    (pending_moves[thing] ||= []) << direction
  end
end
