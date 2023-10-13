local board = require('td.board')

local NANO = 'nano'
local MINI = 'mini'
local SMALL = 'small'
local MEDIUM = 'medium'
local ARMORED = 'armored'
local HERO = 'hero'

local nano = {
  name = NANO,
  base_health = 5,
  speed = 2,
  damage = 2,
  base_reward = 1,
}
local mini = {
  name = MINI,
  base_health = 10,
  speed = 2,
  damage = 1,
  base_reward = 2,
}
local small = {
  name = SMALL,
  base_health = 50,
  speed = 3,
  damage = 5,
  base_reward = 5,
}
local medium = {
  name = MEDIUM,
  base_health = 80,
  speed = 8,
  damage = 7,
  base_reward = 9,
}
local armored = {
  name = ARMORED,
  base_health = 150,
  speed = 12,
  damage = 20,
  base_reward = 20,
}
local hero = {
  name = HERO,
  base_health = 350,
  speed = 10,
  damage = 50,
  base_reward = 40,
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
    reward = creep_type.base_reward * level,
    x = x,
    y = y,
    effects = {},
  }
  return creep
end

local M = {
  nano = function (level) return new(nano, level) end,
  mini = function (level) return new(mini, level) end,
  small = function (level) return new(small, level) end,
  medium = function (level) return new(medium, level) end,
  armored = function (level) return new(armored, level) end,
  hero = function (level) return new(hero, level) end,
  NANO = NANO,
  MINI = MINI,
  SMALL = SMALL,
  MEDIUM = MEDIUM,
  ARMORED = ARMORED,
  HERO = HERO,
}

return M
