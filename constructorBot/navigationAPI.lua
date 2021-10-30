-- Library to help navigation

local robot = require("robot")
require("cbUtils")

-- Init location
-- Note: Y is vertical axis
local xPos, yPos, zPos, orientation = 0,0,0,0


-- NAVIGATION WRAPPERS

  -- Updates the position if moved in the current facing by the specified number of blocks
  local function moved(count)
    if (orientation == 0) then
      zPos = zPos - count
    elseif(orientation == 1) then
      xPos = xPos + count
    elseif(orientation == 2) then
      zPos = zPos + count
    else
      xPos = xPos - count
    end
  end

  -- Moves the robot back one block
  function back()
    if(robot.back()) then
      moved(-1)
      return true
    else
      return false
    end
  end

  -- Moves the robot foward one block
  function forward()
    if(robot.forward()) then
      moved(1)
      return true
    else
      return false
    end
  end

  -- Rotates the robot clockwise
  function clockwise()
    if(robot.turnRight()) then
      orientation = (orientation + 1) % 4
      return true
    else
      return false
    end
  end

  -- Rotates the robot anticlockwise
  function antiClockwise()
    if(robot.turnLeft()) then
      orientation = (orientation - 1) % 4
      return true
    else
      return false
    end
  end

  -- Moves the robot up one block
  function up()
    if(robot.up()) then
      yPos = yPos + 1
      return true
    else
      return false
    end
  end

  -- Moves the robot up one block
  function down()
    if(robot.down()) then
      yPos = yPos - 1
      return true
    else
      return false
    end
  end



-- ABSOLUTE NAVIGATION

  -- Face the desired direction
  function facePos(target)
    if (orientation +1)%4 == target then
      robot.turnRight()
    elseif (orientation +2)%4 == target then
      robot.turnAround()
    elseif (orientation -1)%4 == target then
      robot.turnLeft()
    end
    orientation = target
  end

  -- Move to x,z,y
  function moveTo(x, z, y)
    y = y or yPos
    -- move to X
    if x < xPos then
      facePos(3)
      runMany(robot.forward, xPos-x)
      xPos = x
    elseif x > xPos then
      facePos(1)
      runMany(robot.forward,x-xPos)
      xPos = x
    end
    -- move to z
    if z < zPos then
      facePos(0)
      runMany(robot.forward,zPos-z)
      zPos = z
    elseif z > zPos then
      facePos(2)
      runMany(robot.forward,z-zPos)
      zPos = z
    end
    -- move to y
    if y < yPos then
      runMany(robot.down,yPos-y)
      yPos = y
    elseif y > yPos then
      runMany(robot.up,y-yPos)
      yPos = y
    end
  end

  -- Go to 0,0,0 and face 0
  function home()
    moveTo(0,0,0)
    facePos(0)
  end
