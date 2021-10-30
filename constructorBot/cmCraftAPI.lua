-- API To help autocrafting Compact Machines 3d recipes

-- You may note the heavy use of tillDone, this is a safety mechanism.
-- It causes the robot to halt in cases where it cannot follow the instructions.
-- If fail-fast is not desired or required the tillDone wrappers can be removed
-- resulting in a fail-silent implementation.

local robot = require("robot")
require("navigationAPI")


-- Crafting grid location
-- This is the coordinates of the robot when orientation is 0, it is inside the
-- grafting grid and its front (0) left (3) and bottom sides are on the border
-- of the grid

local craftingX, craftingZ, craftingY = 2,3,0

-- NAVIGATION UTILS

  -- Moves to the start of the crafting grid
  function start()
    moveTo(craftingX, craftingZ, craftingY)
    facePos(0)
  end


-- CONSTRUCTION UTILS

  -- Places the currently selected block and backs up one block
  function place()
    tillDone(robot.place)
    tillDone(back)
  end

  -- Places the currently selected block in a line len long
  function line(len)
    runMany(place, len -1)
    if(len > 0) then
      tillDone(robot.place)
    end
  end

  -- Creates a line and turns at the end
  -- Parameters: len length of th line to make,
  -- t turn function to use
  -- This method is used as a small optimisation to constrution speed
  function lineTurn(len, t)
    line(len-1)
    tillDone(t)
    tillDone(back)
    tillDone(robot.place)
    tillDone(t)
    tillDone(back)
  end

  -- Places the currently selected block in a line len long, and repositions
  -- itself ready to make a pass on top of the line just made.
  -- i.e. calling this method n times build a wall len long and n high
  function lastLine(len)
    line(len-1)
    tillDone(up)
    tillDone(robot.placeDown)
    tillDone(clockwise)
    tillDone(clockwise)
    tillDone(back)
  end

-- Builds a size x size x 1 plate of the selected material
-- Parameters: orientation if -1 then the plate will be built left,
-- size the diameter of the square being placed.
--  i.e. if size is 3 starting at pos 0,1 facing 0 the plate will be from (0,0)
-- to (-2, 2) if orientation is -1, otherwise it will end at (2,2)
function plate(orientation, size)
  size = size or 3
  local t = true
  local t1 , t2 = antiClockwise, clockwise
  if(orientation == -1) then
    t1 = clockwise
    t2 = antiClockwise
  end

  for i=1, size- 1 do
    if t then
      lineTurn(size, t1)
    else
      lineTurn(size, t2)
    end
    t = not t
  end
  lastLine(size)
end

-- Builds a size x size x 1 plate of the selected material, with the middle most
-- block being a different type to the outer ones.
-- Parameters: orientation if -1 then the plate will be built left,
-- size the diameter of the square being placed, should be odd.
-- item1 slot containing the material for the outer blocks to be placed
-- item 2 slot containing the middle block.
--  i.e. if size is 3 starting at pos 0,1 facing 0 the plate will be from (0,0)
-- to (-2, 2) if orientation is -1, otherwise it will end at (2,2)
function yolk(orientation, size, item1, item2)
  size = size or 3
  item1 = item1 or 1
  item2 = item2 or 2

  local radius = (size-1)/2
  local t = true
  local t1 , t2 = antiClockwise, clockwise
  if(orientation == -1) then
    t1 = clockwise
    t2 = antiClockwise
  end

  -- build first half of plate
  robot.select(item1)
  for i=1, radius do
    if t then
      lineTurn(size, t1)
    else
      lineTurn(size, t2)
    end
    t = not t
  end

  -- build first half of middle line
  line(radius)
  tillDone(back)
  -- place yolk
  robot.select(item2)
  if radius > 1 then -- conditional allows quick turn optimisation to be used
    place()
  else
    tillDone(robot.place)
  end
  -- build second half of middle line
  robot.select(item1)
  if t then
    lineTurn(radius, t1)
  else
    lineTurn(radius, t2)
  end
  t = not t

  -- build last half
  for i=1, radius- 1 do
    robot.select(item1)
    if t then
      lineTurn(size, t1)
    else
      lineTurn(size, t2)
    end
    t = not t
  end
  lastLine(size)
end

-- Crafts a 3x3x3 cube with a different middle block and uses a catalyst
-- Parameters: slot1 slot containing the blocks for the outer shell,
-- slot2 slot containing the block in the center of the cube,
-- slot3 slot containing the catalyst used in crafting
function buildEgg3(slot1, slot2, slot3)
  slot1 = slot1 or 1
  slot2 = slot2 or 2
  slot3 = slot3 or 3
  -- move to build pos
  start()
  -- select first slot
  robot.select(slot1)
  -- build first layer
  plate(1)
  -- build second layer
  yolk(1, 3, slot1, slot2)
  -- build third layer
  plate(1)
  -- drop catalyst
  clockwise()
  up()
  robot.select(slot3)
  robot.drop(1)
  -- reset
  home()
end
