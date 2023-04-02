local board = require('td.board')

local SMALL = 'small'
local MEDIUM = 'medium'
local ARMORED = 'armored'

local small = {
  name = SMALL,
  base_health = 100,
  speed = 1,
  damage = 5,
}
local medium = {
  name = MEDIUM,
  base_health = 150,
  speed = 2,
  damage = 7,
}
local armored = {
  name = ARMORED,
  base_health = 300,
  speed = 5,
  damage = 20,
}

local function get_initial_position()
  local side = math.random(1, 4)
  local x, y
  if side == 1 then
    x = math.random(0, board.width-1)
    y = 0
  elseif side == 2 then
    x = board.width-1
    y = math.random(1, board.height - 1)
  elseif side == 3 then
    x = math.random(0, board.width-1)
    y = board.height - 1
  else
    x = 0
    y = math.random(1, board.height - 1)
  end
  return x, y
end

local new = function (creep_type, level)
  local x, y = get_initial_position()
  local creep = {
    name = creep_type.name,
    health = creep_type.base_health * level,
    initial_health = creep_type.base_health * level,
    speed = creep_type.speed,
    damage = creep_type.damage * level,
    x = x,
    y = y,
  }
  return creep
end

local M = {
  small = function (level) return new(small, level) end,
  medium = function (level) return new(medium, level) end,
  armored = function (level, x, y) return new(armored, level) end,
  SMALL = SMALL,
  MEDIUM = MEDIUM,
  ARMORED = ARMORED,
}

return M
