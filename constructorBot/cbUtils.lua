-- Collection of utility functions for the ConstructBot library

-- Runs func untill it returns either true or nil
function tillDone(func)
  local r = {func()}
  while(next(r) ~= nil and r[1] ~= true) do
    r = {func()}
  end
end

-- Runs tillDone(func) num times
-- This means func will be ran until it returns nil or true a total of num times
-- at wich point this method will return
function runMany(func, num)
  local toMove = num
  while(toMove > 0) do
    tillDone(func)
    toMove = toMove-1
  end
end
