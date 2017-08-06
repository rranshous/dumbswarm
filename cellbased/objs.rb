require_relative 'patches'
require_relative 'roles'

# User input objs

class Keyboard

  attr_accessor :keys_down

  def initialize input
    self.setup_listeners input
    self.keys_down = {}
  end

  def pressed? key
    self.keys_down[key] == true
  end

  def setup_listeners input
    input.keydown { |*args| keydown(*args) }
    input.keyup   { |*args| keyup(*args) }
  end

  def keydown key
    self.keys_down[key] = true
  end

  def keyup key
    self.keys_down[key] = false
  end
end

class KeyboardInterpreter
  attr_accessor :keyboard

  def initialize keyboard
    self.keyboard = keyboard
  end

  def directions
    moves = []
    mapping.each do |direction, keys|
      keys.each do |key|
        if keyboard.pressed? key
          moves << direction and break
        end
      end
    end
    moves
  end

  def mapping
    { forward:         [:up, "w"],
      back:            [:down, "s"],
      left:            [:left, "a"],
      right:           [:right, "d"],
      rotate_right:    ["e"],
      rotate_left:     ["q"] }
  end
end


# showing things on screen objs
class Canvas
  attr_accessor :shoe

  def initialize shoe
    self.shoe = shoe
  end

  def fill to_paint
    shoe.nostroke
    shoe.fill shoe.send(to_paint.color)
    shoe.oval left:   to_paint.x(shoe),
              top:    to_paint.y(shoe),
              radius: to_paint.radius
  end

  def clear
    shoe.clear
  end
end

class Pixel
  include Locatable
  def initialize opts
    self.left  = opts[:left]  if !opts[:left].nil?
    self.up    = opts[:up]    if !opts[:up].nil?
  end
end

class Painter
  attr_accessor :canvas, :to_paint

  def initialize
    self.to_paint = {}
  end

  def fill paintable
    if paintable.visible?
      self.to_paint[[:fill, paintable]] = 1
    end
  end

  def paint
    canvas.clear
    to_paint.each do |(operation, paintable), _|
      canvas.send(operation, paintable)
    end
    to_paint.clear
  end
end

class Screen
  attr_accessor :width, :height, :pixels

  def initialize opts
    self.height = opts[:height] if opts[:height]
    self.width  = opts[:width]  if opts[:width]
    self.pixels = self.class.create_pixels self.height, self.width
  end

  def self.create_pixels width, height
    pixels = []
    half_width  = width / 2
    half_height = height / 2
    (-half_width..half_width).each do |w|
      (-half_height..half_height).each do |h|
        pixels << Pixel.new(left: w, up: h)
      end
    end
    pixels
  end
end


# shapes

class Shape
  attr_accessor :fills

  def initialize opts
    self.fills = opts[:fills] || []
    populate_fills opts
  end

  def cells cellspace, center
    fills.map {|fill| cellspace.at Locatable.add(center, fill) }.uniq
  end

  def populate_fills opts
  end
end

class Box < Shape
  def populate_fills opts
    half_width = opts[:width] / 2
    (-half_width..half_width).each do |i|
      self.fills << Position.new(left: i, up: half_width)
      self.fills << Position.new(left: i, up: -half_width)
      self.fills << Position.new(left: half_width, up: i)
      self.fills << Position.new(left: -half_width, up: i)
    end
  end
end

class Line < Shape
  def populate_fills opts
    half_length = opts[:length] / 2
    (-half_length..half_length).each do |i|
      self.fills << Position.new(left: i, up: 0)
    end
  end
end


# positional things

class Position
  include Locatable
  def initialize opts
    self.left  = opts[:left]  if !opts[:left].nil?
    self.up    = opts[:up]    if !opts[:up].nil?
  end
end


# Cells

class Cell
  include Locatable
  include Paintable
  include SpaceTaker

  attr_accessor :content

  def initialize opts
    self.left  = opts[:left]  if !opts[:left].nil?
    self.up    = opts[:up]    if !opts[:up].nil?
  end

  def cells
    [self]
  end

  def empty?
    content.nil?
  end

  def collide other
    content.collide(other.content) if content.respond_to?(:collide)
  end

  def visible?
    !content.empty?
  end

  def to_s
    "<Cell #{left}:#{up}-#{visible?}>"
  end

  def inspect
    to_s
  end
end


# collections of cells

class Cellspace
  attr_accessor :cells

  def initialize
    self.cells = {}
  end

  def populate space
    #space.each do |locatable|
    #  cells[position(locatable)] = Cell.new(left: locatable.left,
    #                                        up: locatable.up)
    #end
  end

  def at locatable
    cells[position(locatable)] ||= Cell.new(left: locatable.left,
                                            up: locatable.up)
  end

  def for shape, center
    shape.cells(self, center)
  end

  def swap cell1, cell2
    left, up               = cell2.left, cell2.up
    cell2.left, cell2.up   = cell1.left, cell1.up
    cell1.left, cell1.up   = left, up
    cells[position(cell1)] = cell1
    cells[position(cell2)] = cell2
  end

  def center cells
    left = cells.sort_by { |c| c.left }.first
    right = cells.sort_by { |c| -c.left }.first
    top = cells.sort_by { |c| c.up }.first
    bottom = cells.sort_by { |c| -c.up }.first
    left_avg = ((left.left + right.left).to_f / 2).to_i
    up_avg = ((top.up + bottom.up).to_f / 2).to_i
    Position.new(left: left_avg, up: up_avg)
  end

  private

  def position locatable
    [locatable.left, locatable.up]
  end
end

class Entity
  include SpaceTaker
  include Paintable

  def visible?
    true
  end

  def paint painter
    cells.each do |cell|
      cell.paint painter
    end
  end
end

require 'forwardable'
class Particle
  extend  Forwardable

  include SpaceTaker
  include Paintable
  include Locatable # risky b/c i don't want all the methods that come with it
  attr_accessor :cell, :brain, :energy

  def initialize opts
    self.cell   = opts[:cell]
    self.brain  = opts[:brain]
    self.energy = opts[:energy]
  end

  def observe context
    brain.observe self, context if alive?
  end

  def act enacter
    brain.act self, enacter if alive?
  end

  def move direction, enacter
    enacter.move(self, direction) if alive?
  end

  def collide other_thing
    hit other_thing
  end

  def hit other_thing
    other_thing.take_damage self
  end

  def take_damage other_thing
    energy.subtract other_thing.hit_damage
    die if out_of_energy?
  end

  def paint painter
    cell.paint(painter) if alive?
  end

  def hit_damage
    1
  end

  def out_of_energy?
    energy.empty?
  end

  def die
    self.cell.content = nil
    self.cell = nil
  end

  def dead?
    self.cell.nil?
  end

  def alive?
    !dead?
  end

  def left
    alive? ? cell.left : nil
  end

  def up
    alive? ? cell.up : nil
  end

  def cells
    [cell]
  end

  def cell= cell
    cell.content = self if !cell.nil?
    @cell = cell
  end
end

class ParticleCannon
  include Locatable

  def observe context
    pos = Locatable.add(self, Position.new(left: 1, up: 0))
    @next_cell = context.cellspace.at pos
  end

  def act context
    if @next_cell.empty?
      particle = Particle.new(cell: @next_cell,
                              brain: Brain.new.extend(Seeker),
                              energy: EnergyCell.new(1))
      particle.cell.color = :red
      context.particles.push(particle)
    end
    @next_cell = nil
  end
end

class Brain
  def act body, enacter
  end

  def observe body, context
  end
end

class EnergyCell
  attr_accessor :charge

  def initialize charge
    self.charge = charge
  end

  def subtract mag
    self.charge -= mag
  end

  def empty?
    charge <= 0
  end

  def to_s
    "<EnergyCell##{self.object_id} #{charge}>"
  end
  def inspect
    to_s
  end
end


# cell affectors

class Mover
  attr_accessor :cellspace

  def move space_taker, direction
    case direction
    when :forward
      _move forward_sort(space_taker.cells), 0, 1
    when :back
      _move back_sort(space_taker.cells), 0, -1
    when :left
      _move left_sort(space_taker.cells), 1, 0
    when :right
      _move right_sort(space_taker.cells), -1, 0
    when :rotate_right
      rotate space_taker, -15
    when :rotate_left
      rotate space_taker, 15
    end
  end

  private

  def _move cells, left, up
    swap_history = []
    cells.each do |cell|
      next_pos = Locatable.add cell, Position.new(left: left, up: up)
      next_cell = cellspace.at next_pos
      if active?(cell, next_cell)
        notify_collision(cell, next_cell)
        unwind swap_history
        return false
      end
      swap_history << [cell, next_cell]
      cellspace.swap(cell, next_cell)
    end
    true
  end

  def active? *space_takers
    space_takers.all? {|s| s.visible? }
  end

  def unwind swap_history
    swap_history.reverse.each do |(c1, c2)|
      cellspace.swap(c2, c1)
    end
  end

  def notify_collision s1, s2
    s1.collide s2
    s2.collide s1
  end

  def forward_sort cells
    cells.sort_by(&:left).sort_by(&:up).reverse
  end

  def back_sort cells
    cells.sort_by(&:left).sort_by(&:up)
  end

  def left_sort cells
    cells.sort_by(&:up).sort_by(&:left).reverse
  end

  def right_sort cells
    cells.sort_by(&:up).sort_by(&:left)
  end
end

# functional

class WorkSet
  def initialize
    @enumerators = []
    @blocks = []
  end
  def add &blk
    @enumerators << Enumerator.new(&blk)
    @blocks << blk
  end
  def to_enum
    blocks = @blocks
    Enumerator.new do |y|
      loop do
        blocks.each do |blk|
          begin
            blk.call y
          rescue => ex
            puts "EXW: #{ex}"
            puts "  : #{ex.backtrace}"
          end
        end
      end
    end
  end
end
