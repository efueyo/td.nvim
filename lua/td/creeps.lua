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

local new = function (creep_type, level, x, y)
  local creep = {
    name = creep_type.name,
    health = creep_type.base_health * level,
    speed = creep_type.speed,
    damage = creep_type.damage * level,
    x = x,
    y = y,
  }
  return creep
end

local M = {
  small = function (level, x, y) return new(small, level, x, y) end,
  medium = function (level, x, y) return new(medium, level, x, y) end,
  armored = function (level, x, y) return new(armored, level, x, y) end,
  SMALL = SMALL,
  MEDIUM = MEDIUM,
  ARMORED = ARMORED,
}

return M
