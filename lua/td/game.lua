local Creeps = require('td.creeps')
local Board = require('td.board')

local M = {}

M.setTower = function ()
  local tower_x = math.floor(Board.width/2)
  local tower_y = math.floor(Board.height/2)
  local tower_health = 100
  local tower = {x=tower_x, y=tower_y, health=tower_health}
  M._tower = tower
end
M.add_creeps = function(cs)
  for _, creep in ipairs(cs) do
    table.insert(M._creeps, creep)
  end
end
M.setCreeps = function ()
  local initial_creeps = {
    Creeps.small(1),
    Creeps.small(1),
    Creeps.small(1),
    Creeps.small(1),
    Creeps.small(1),
    Creeps.medium(1),
    Creeps.armored(10),
  }
  M._creeps = initial_creeps
end


M.init = function ()
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
    local damage = 40
    creep.health = creep.health - damage
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

M.remove_dead_creeps = function ()
  local new_creeps = {}
  for _, creep in ipairs(M._creeps) do
    if creep.health > 0 then
      table.insert(new_creeps, creep)
    end
  end
  M._creeps = new_creeps
end

M.spawn_creeps = function (iteration)
  local creep_types = {Creeps.SMALL, Creeps.MEDIUM, Creeps.ARMORED}
  local num_creeps_by_type = {
    [Creeps.SMALL] = 10,
    [Creeps.MEDIUM] = 3,
    [Creeps.ARMORED] = 1,
  }
  local creep_factory = {
    [Creeps.SMALL] = Creeps.small,
    [Creeps.MEDIUM] = Creeps.medium,
    [Creeps.ARMORED] = Creeps.armored,
  }
  local creep_type = creep_types[math.random(1, #creep_types)]
  local level = math.floor(iteration / 10)
  local num_creeps = num_creeps_by_type[creep_type]
  local new_creeps = {}
  for _=1,num_creeps do
    table.insert(new_creeps, creep_factory[creep_type](level))
  end
  M.add_creeps(new_creeps)
end

M.play_iteration = function (iteration)
  if not M.alive() then
    return false
  end
  M.remove_dead_creeps()
  M.attack_creeps()
  M.move_creeps(iteration)
  M.attack_tower()
  -- spawn more creeps every 10 iterations
  if iteration % 10 == 0 then
    M.spawn_creeps(iteration)
  end
  return M.alive()
end


return M
