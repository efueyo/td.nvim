local Board = require('td.board')
local tower_x = math.floor(Board.width/2)
local tower_y = math.floor(Board.height/2)

local tower = {}

local M = {}

local gunName = 'Gun'
local cannonName = 'Cannon'
local iceName = 'Ice'
local mineName = 'Mine'

local function new_gun()
  local gun = {
    name=gunName,
    damage=40,
    level=1,
    speed=1,
    blast_radius=nil,
    freeze=0,
  }
  return gun
end

local function new_cannon()
  local cannon = {
    name=cannonName,
    damage=100,
    level=1,
    speed=5,
    blast_radius=5,
    freeze=0,
  }
  return cannon
end

local function new_ice()
  local ice = {
    name=iceName,
    damage=1,
    level=1,
    speed=5,
    blast_radius=nil,
    freeze=1,
  }
  return ice
end

local function new_mine()
  local mine = {
    name=mineName,
    damage=1000,
    level=1,
    speed=5,
    blast_radius=30,
    freeze=0,
  }
  return mine
end

function M.init()
  local tower_health = 500
  tower = {
    level=1,
    x=tower_x,
    y=tower_y,
    health=tower_health,
    initial_health=tower_health,
    weapons = { new_gun() }
  }
end

function M.get()
  return tower
end

function M.alive()
  return tower.health > 0
end

function M.upgrade()
  tower.level = tower.level + 1
  tower.initial_health = tower.initial_health + 50
  tower.health = tower.initial_health
  if tower.level == 5 then
    table.insert(tower.weapons, new_cannon())
  end
  if tower.level == 10 then
    table.insert(tower.weapons, new_ice())
  end
  if tower.level == 15 then
    table.insert(tower.weapons, new_mine())
  end
end

function M.level()
  return tower.level
end

local function weapon_index(name)
  for i, weapon in ipairs(tower.weapons) do
    if weapon.name == name then
      return i
    end
  end
  return nil
end

function M.upgrade_gun()
  local gun_index = weapon_index(gunName)
  if gun_index == nil then
    return
  end
  tower.weapons[gun_index].damage = tower.weapons[gun_index].damage + 30
  tower.weapons[gun_index].level = tower.weapons[gun_index].level + 1
end

function M.upgrade_cannon()
  local gun_index = weapon_index(cannonName)
  if gun_index == nil then
    return
  end
  tower.weapons[gun_index].damage = tower.weapons[gun_index].damage + 100
  tower.weapons[gun_index].level = tower.weapons[gun_index].level + 1
end

function M.upgrade_ice()
  local gun_index = weapon_index(iceName)
  if gun_index == nil then
    return
  end
  tower.weapons[gun_index].damage = tower.weapons[gun_index].damage + 1
  tower.weapons[gun_index].freeze = tower.weapons[gun_index].freeze + 1
  tower.weapons[gun_index].level = tower.weapons[gun_index].level + 1
end

function M.upgrade_mine()
  local gun_index = weapon_index(mineName)
  if gun_index == nil then
    return
  end
  tower.weapons[gun_index].damage = tower.weapons[gun_index].damage + 1000
  tower.weapons[gun_index].level = tower.weapons[gun_index].level + 1
end

local function place_mine(bullet)
  bullet.x = math.random(0, Board.width-1)
  bullet.y = math.random(1, Board.height - 1)
end

function M.fire(iteration)
  local bullets = {}
  for _, weapon in ipairs(tower.weapons) do
    if weapon.speed > 0 and iteration % weapon.speed == 0 then
      local bullet = {
        x=tower.x,
        y=tower.y,
        damage=weapon.damage,
        name=weapon.name,
        blast_radius=weapon.blast_radius,
        freeze=weapon.freeze,
      }
      if weapon.name == mineName then
        place_mine(bullet)
      end
      table.insert(bullets, bullet)
    end
  end
  return bullets
end

return M
