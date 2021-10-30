-- System for autocrafting Compact Machines recipes

local serialization = require("serialization")
require("inventory")

-- Where the recipes database should be stored
local RECIPE_DB_LOC = "/home/recipesdb.db"

-- Database storing all known items
local recipes = {}

-- Recipe is an object describing instructions to build a specified item
local Recipe = {}
Recipe.__index = Recipe

-- Constructor for Recipe
-- Parameters: name of the item being crafted, items needed,
-- function that builds the item
function Recipe:new(name, items, recipe)
  local o = {}
  setmetatable(o,self)
  o.name = name
  o.items = items
  o.recipe = recipe
  return o
end

-- Ingredient is the description of a stack of items that is needed in the
-- crafting of an item
Ingredient = {}
Ingredient.__index = Ingredient

-- Constructor for Ingredient
-- Parameters: name of the desired item, what slot is needs to be placed in,
-- how many of said item need to be in the slot
function Ingredient:new(name, slot, ammount)
  local o = {}
  setmetatable(o, self)
  o.name = name
  o.slot = slot
  o.ammount = ammount
  return o
end

-- Gets the robot to moveto and retrieve the specified ingredient
function Ingredient:get()
  pickupItem(self.name, self.slot, self.ammount)
end

-- Saves the recipe table to the file RECIPE_DB_LOC
function saveRecipesTable()
  local f = io.open(RECIPE_DB_LOC, "w")
  f:write(serialization.serialize(recipes))
  f:close()
end

-- Loads the recipe table from the file RECIPE_DB_LOC
-- If the file does not exist it will be created
function loadRecipesTable()
  local f = io.open(RECIPE_DB_LOC, "r")
  if not f then
    saveRecipesTable()
  end
  recipes = serialization.unserialize(f:read())
  f:close()
end

-- Autoload the content of the database into the recipe table
loadRecipesTable()

-- Clears the contents of the recipe table
-- Useful as the computers have low memory
function clearItemTable()
  items = {}
end

-- Add a recipe to the database
-- Note: to save the recipe you must call saveRecipesTable
function addRecipe(name, recipe, ...)
  local r = Recipe:new(name, table.pack(...), recipe)
  recipes[name] = r
end

-- Automatically gets the robot to retrieve all the items needed to fulfil a
-- recipe.
local function getItems(items)
  for i=1, items.n do
    items[i]:get()
  end
end

-- Crafts the desired item.
-- If the desired item is not in the database false will be returned.
-- Note: this does not pick up the crafted item
function craft(name)
  local recipe = recipes[name]
  if recipe == nil then
    return false
  end
  getItems(recipe["items"])
  recipe["recipe"]()
end
