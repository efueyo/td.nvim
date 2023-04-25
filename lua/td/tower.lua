local Board = require('td.board')
local tower_x = math.floor(Board.width/2)
local tower_y = math.floor(Board.height/2)

local tower = {}

local M = {}


M.init = function()
  local tower_health = 500
  tower = {
    level=1,
    x=tower_x,
    y=tower_y,
    health=tower_health,
    initial_health=tower_health,
    weapons = {
      {
        name='Gun',
        damage=40,
        level=1,
        speed=1,
      },
    }
  }
end

M.get = function()
  return tower
end

M.alive = function()
  return tower.health > 0
end

M.upgrade = function()
  tower.level = tower.level + 1
  tower.initial_health = tower.initial_health + 50
  tower.health = tower.initial_health
end

M.upgrade_gun = function()
  local gun_index = 1 -- fix this coupling with index inside weapons list
  tower.weapons[1].damage = tower.weapons[1].damage + 30
  tower.weapons[1].level = tower.weapons[1].level + 1
end

M.fire = function (iteration)
  local bullets = {}
  for _, weapon in ipairs(tower.weapons) do
    if iteration % weapon.speed == 0 then
      local bullet = {
        x=tower.x,
        y=tower.y,
        damage=weapon.damage,
      }
      table.insert(bullets, bullet)
    end
  end
  return bullets
end

return M