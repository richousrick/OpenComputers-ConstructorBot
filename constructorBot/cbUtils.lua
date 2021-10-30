-- Collection of utility functions for the ConstructBot library

-- runs func untill it returns either true or nil
function tillDone(func)
  local r = {func()}
  while(next(r) ~= nil and r[1] ~= true) do
    r = {func()}
  end
end

-- runs func, num times
function runMany(func, num)
  local toMove = num
  while(toMove > 0) do
    tillDone(func)
    toMove = toMove-1
  end
end
