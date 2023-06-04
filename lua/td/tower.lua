local Board = require('td.board')
local tower_x = math.floor(Board.width/2)
local tower_y = math.floor(Board.height/2)

local tower = {}

local M = {}

local weaponGun = {
  name='Gun',
  damage=40,
  level=1,
  speed=1,
  blast_radius=nil,
}

local weaponCannon = {
  name='Cannon',
  damage=100,
  level=1,
  speed=5,
  blast_radius=5,
}

function M.init()
  local tower_health = 500
  tower = {
    level=1,
    x=tower_x,
    y=tower_y,
    health=tower_health,
    initial_health=tower_health,
    weapons = { weaponGun }
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
    table.insert(tower.weapons, weaponCannon)
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
  local gun_index = weapon_index(weaponGun.name)
  tower.weapons[gun_index].damage = tower.weapons[gun_index].damage + 30
  tower.weapons[gun_index].level = tower.weapons[gun_index].level + 1
end

function M.upgrade_cannon()
  local gun_index = weapon_index(weaponCannon.name)
  tower.weapons[gun_index].damage = tower.weapons[gun_index].damage + 100
  tower.weapons[gun_index].level = tower.weapons[gun_index].level + 1
end

function M.fire(iteration)
  local bullets = {}
  for _, weapon in ipairs(tower.weapons) do
    if iteration % weapon.speed == 0 then
      local bullet = {
        x=tower.x,
        y=tower.y,
        damage=weapon.damage,
        name=weapon.name,
        blast_radius=weapon.blast_radius,
      }
      table.insert(bullets, bullet)
    end
  end
  return bullets
end

return M
