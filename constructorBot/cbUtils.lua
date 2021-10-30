-- Collection of utility functions for the ConstructBot library


-- runs func till it returns true
function tillDone(func)
  while(not func()) do end
end

-- runs func, num times
function runMany(func, num)
  local toMove = num
  while(toMove > 0) do
    if (func()) then
      toMove = toMove-1
    end
  end
end
