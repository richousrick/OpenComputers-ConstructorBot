-- Library for storing locations of items and blocks to be used by the robot

local serialization = require("serialization")
local robot = require("robot")
require("navigationAPI")

-- Where the items database should be stored
ITEM_DB_LOC = "/home/itemsdb.db"

-- Datebase storing all known items
local items = {}

-- Item is a type referencing the location of an item,
-- alongside functions for retrieving them
local Item = {}
Item.__index = Item

-- Constructor for item
-- Parameters: name of the item, coordinates and bearing of the item
function Item:new(name, xPos, zPos, yPos, orientation)
  local o = {}
  setmetatable(o,self)
  o.name = name
  o.xPos = xPos
  o.yPos = yPos
  o.zPos = zPos
  o.orientation = orientation
  return o
end

-- Saves the item table to the file ITEM_DB_LOC
function saveItemTable()
  local f = io.open(ITEM_DB_LOC, "w")
  f:write(serialization.serialize(items))
  f:close()
end

-- Loads the item table from the file ITEM_DB_LOC
-- If the file does not exist it will be created
function loadItemTable()
  local f = io.open(ITEM_DB_LOC, "r")
  if not f then
    saveItemTable()
  end
  items = serialization.unserialize(f:read())
  f:close()
end

-- Autoload the content of the database into the item table
loadItemTable()

-- Clears the contents of the item table
-- Useful as the computers have low memory
function clearItemTable()
  items = {}
end


-- Add an item to the database
-- Note: to save the item you must call saveItemTable
function addItem(name, xPos, zPos, yPos, orientation)
  local i = Item:new(name, xPos, zPos, yPos, orientation)
  items[name] = i
end

-- Test if the specified item exists
function hasItem(name)
  return items[name] ~= nil
end

-- Retrieve the specified item
function getItem(name)
  return items[name]
end

-- Makes the robot automatically retrieve the item
-- Parameters: name of the item to retireive,
-- slot the item should be moved into (slots are 1 indexed),
-- ammout of the item to retrieve
function pickupItem(name, slot, ammount)
  i = getItem(name)
  if i == nil then
    return false
  end
  robot.select(slot)
  moveTo(i["xPos"], i["zPos"], i["yPos"])
  facePos(i["orientation"])
  robot.suck(ammount)
end
