require 'pry'
require_relative 'position_data_validator'

class ToyRobot
  include PositionDataValidator

  attr_accessor :position_and_facing

  def send_method(command, position_data)
    if command
      if position_data
        send(command, position_data)
      elsif valid_place_command_has_been_issued? && on_table?
        send(command)
      end
    end
  end

  private

  def valid_place_command_has_been_issued?
    !position_and_facing.nil?
  end

  def place(position_data) #=> {x: 0, y: 1, facing: west}
    @position_and_facing = 
    {
      x: position_data[0].to_i,
      y: position_data[1].to_i,
      facing: position_data[2]
    }
  end

  # TURN RIGHT
  #          N
  #          |--------+
  #          |        |
  #          |        v
  # W--------|--------E
  # |        |        ^
  # |        |        |
  # |        |        |
  # +------> S--------+

  def right
    change_direction({
      'north' => 'east',
      'east' => 'east',
      'south' => 'east',
      'west' => 'south',
    })
  end

  # TURN LEFT
  #          N
  # +--------|<-------+
  # |        |        |
  # v        |        |
  # W--------|--------E
  # ^        |
  # |        |
  # |        |
  # +------  S

  def left
    change_direction({
      'north' => 'west',
      'east' => 'north',
      'south' => 'west',
      'west' => 'west',
    })
  end

  def change_direction(directions_hash)
    new_direction = directions_hash[position_and_facing[:facing]]
    position_and_facing[:facing] = new_direction
  end

  def report
    puts position_and_facing.values
  end

  #   x:0,y:5         x:5,y:5
  #    +----------------+
  #    |                |
  #    |                |
  #    |                |
  #    |                |
  #    |                |
  #    |                |
  #    +----------------+
  #   x:0,y:0        x:5,y:0

  def movement_instructions
    {
      #'facing' => how to increment or decrement current x and y coordinates.
      'east'  =>  {x: 1,  y: 0},
      'west'  =>  {x: -1, y: 0},
      'north' =>  {x: 0,  y: 1},
      'south' =>  {x: 0,  y: -1}
    }
  end

  def move
    robot_facing_direction = position_and_facing[:facing]
    unless at_edge_facing_outward?(robot_facing_direction)
      position_and_facing[:x] += movement_instructions[robot_facing_direction][:x]
      position_and_facing[:y] += movement_instructions[robot_facing_direction][:y]
    end
  end

  def at_edge_facing_outward?(direction)
    relevant_border_axis_coordinate = {
      'east'  =>  ['x', 5],
      'west'  =>  ['x', 0],
      'north' =>  ['y', 5],
      'south' =>  ['y', 0]
    }[direction]
    robot_axis_coordinate = position_and_facing[relevant_border_axis_coordinate.first.to_sym]
    robot_axis_coordinate == relevant_border_axis_coordinate.last
  end

  def on_table?
    if !position_and_facing.nil?
      position_and_facing[:x].between?(0, 5) && position_and_facing[:y].between?(0, 5)
    end
  end
end
