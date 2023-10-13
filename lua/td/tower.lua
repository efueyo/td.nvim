local Board = require('td.board')
local W = require('td.weapons')
local tower_x = math.floor(Board.width/2)
local tower_y = math.floor(Board.height/2)

local tower = {}

local M = {}

function M.init()
  local tower_health = 500
  tower = {
    level=1,
    x=tower_x,
    y=tower_y,
    health=tower_health,
    initial_health=tower_health,
    weapons = { W.new_gun(1) }
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
    table.insert(tower.weapons, W.new_cannon(1))
  end
  if tower.level == 10 then
    table.insert(tower.weapons, W.new_ice(1))
  end
  if tower.level == 15 then
    table.insert(tower.weapons, W.new_mine(1))
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
  local gun_index = weapon_index(W.GUN)
  if gun_index == nil then
    return false
  end
  local level = tower.weapons[gun_index].level
  tower.weapons[gun_index] = W.new_gun(level+1)
  return true
end

function M.upgrade_cannon()
  local gun_index = weapon_index(W.CANNON)
  if gun_index == nil then
    return false
  end
  local level = tower.weapons[gun_index].level
  tower.weapons[gun_index] = W.new_cannon(level+1)
  return true
end

function M.upgrade_ice()
  local gun_index = weapon_index(W.ICE)
  if gun_index == nil then
    return false
  end
  local level = tower.weapons[gun_index].level
  tower.weapons[gun_index] = W.new_ice(level+1)
  return true
end

function M.upgrade_mine()
  local gun_index = weapon_index(W.MINE)
  if gun_index == nil then
    return false
  end
  local level = tower.weapons[gun_index].level
  tower.weapons[gun_index] = W.new_mine(level+1)
  return true
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
      if weapon.name == W.MINE then
        place_mine(bullet)
      end
      table.insert(bullets, bullet)
    end
  end
  return bullets
end

return M
