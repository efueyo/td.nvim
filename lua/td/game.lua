local creeps = require('td.creeps')

local M = {}

M.setTower = function ()
  local tower_x = math.floor(M.width/2)
  local tower_y = math.floor(M.height/2)
  local tower_health = 100
  local tower = {x=tower_x, y=tower_y, health=tower_health}
  M._tower = tower
end
M.setCreeps = function ()
  local initial_creeps = {
    creeps.small(1, 0, 0),
    creeps.small(1, 10, 0),
    creeps.small(1, 45, 0),
    creeps.small(1, 55, 0),
    creeps.small(1, 0, 10),
    creeps.medium(1, 0, 14),
    creeps.armored(10, 78, 0),
  }
  M._creeps = initial_creeps
end


M.init = function (width, height)
  M.width = width
  M.height = height
  M.setTower()
  M.setCreeps()
end

M.alive = function ()
  return M._tower.health > 0
end

M.get_state = function ()
  return {
    alive= M.alive(),
    tower=M._tower,
    creeps=M._creeps
  }
end

M.attack_creeps = function ()
  for _, creep in ipairs(M._creeps) do
    creep.health = creep.health - 10
  end
end
M.move_creeps = function (iteration)
  for _, creep in ipairs(M._creeps) do
    if creep.health <= 0 then
      goto continue
    end
    if iteration % creep.speed ~= 0 then
      goto continue
    end
    local init_x = creep.x
    local init_y = creep.y
    if creep.x < M._tower.x then
        creep.x = init_x + 1
    elseif creep.x > M._tower.x then
        creep.x = init_x - 1
    end
    if creep.y < M._tower.y then
        creep.y = init_y + 1
    elseif creep.y > M._tower.y then
        creep.y = init_y - 1
    end
    -- avoid placing the creep on top of the tower
    if creep.x == M._tower.x and creep.y == M._tower.y then
      creep.x = init_x
      creep.y = init_y
    end
    ::continue::
  end
end

M.attack_tower = function ()
  for _, creep in ipairs(M._creeps) do
    if creep.health <= 0 then
      goto continue
    end
    local distance = math.sqrt((creep.x - M._tower.x)^2 + (creep.y - M._tower.y)^2)
    if distance <= 3 then
      M._tower.health = M._tower.health - 10
      print('Tower hit: ' .. M._tower.health)
    end
    ::continue::
  end
end

M.play_iteration = function (iteration)
  if not M.alive() then
    return false
  end
  M.attack_creeps()
  M.move_creeps(iteration)
  M.attack_tower()
  return M.alive()
end


return M