local GUN = 'Gun'
local CANNON = 'Cannon'
local ICE = 'Ice'
local MINE = 'Mine'

local function new_gun(level)
  local gun = {
    name=GUN,
    damage=10 + 30 * level,
    level=level,
    speed=1,
    blast_radius=nil,
    freeze=0,
  }
  return gun
end

local function new_cannon(level)
  local cannon = {
    name=CANNON,
    damage=100*level,
    level=level,
    speed=5,
    blast_radius=5,
    freeze=0,
  }
  return cannon
end

local function new_ice(level)
  local ice = {
    name=ICE,
    damage=1*level,
    level=level,
    speed= 5 - math.min(2, math.floor(level/2)), -- make ice faster
    blast_radius=nil,
    freeze=1*level,
  }
  return ice
end

local function new_mine(level)
  local mine = {
    name=MINE,
    damage=500 + 500*level,
    level=level,
    speed=5 + math.min(15, level), -- make mine slower
    blast_radius=20,
    freeze=0,
  }
  return mine
end

local M = {
  GUN = GUN,
  CANNON = CANNON,
  ICE = ICE,
  MINE = MINE,
  new_gun = new_gun,
  new_cannon = new_cannon,
  new_ice = new_ice,
  new_mine = new_mine,
}
return M
