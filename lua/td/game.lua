local Creeps = require('td.creeps')
local Board = require('td.board')
local Tower = require('td.tower')

local M = {}

M.setTower = function ()
  Tower.init()
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
  return Tower.alive()
end

M.upgrade_tower = function ()
  local cost = 100
  if M._gold < cost then
    return
  end
  Tower.upgrade()
  M.add_gold(-cost)
end

M.upgrade_gun = function ()
  local cost = 100
  if M._gold < cost then
    return
  end
  Tower.upgrade_gun()
  M.add_gold(-cost)
end

M.add_gold = function (gold)
  M._gold = M._gold or 0
  M._gold = M._gold + gold
end

M.get_state = function ()
  return {
    alive= M.alive(),
    tower= Tower.get(),
    bullets= M._bullets or {},
    creeps= M._creeps or {},
    gold= M._gold or 0,
  }
end

M.fire = function (iteration)
  M._bullets = M._bullets or {}
  for _, bullet in ipairs(Tower.fire(iteration)) do
    table.insert(M._bullets, bullet)
  end
end
M._find_closest_creep = function (x, y)
  local closest_creep = nil
  local closest_distance = nil
  for _, creep in ipairs(M._creeps) do
    local distance = math.sqrt((creep.x - x)^2 + (creep.y - y)^2)
    if closest_distance == nil or distance < closest_distance then
      closest_distance = distance
      closest_creep = creep
    end
  end
  return closest_creep
end
M.move_bullets = function ()
  -- if no creeps, remove all bullets
  if M._creeps == nil or #M._creeps == 0 then
    M._bullets = {}
  end

  for _, bullet in ipairs(M._bullets) do
    local init_x = bullet.x
    local init_y = bullet.y
    local target = M._find_closest_creep(bullet.x, bullet.y)
    if bullet.x < target.x then
        bullet.x = init_x + 1
    elseif bullet.x > target.x then
        bullet.x = init_x - 1
    end
    if bullet.y < target.y then
        bullet.y = init_y + 1
    elseif bullet.y > target.y then
        bullet.y = init_y - 1
    end
  end
end

M.attack_creeps = function ()
  local not_used_bullets = {}
  for _, bullet in ipairs(M._bullets) do
    local target = M._find_closest_creep(bullet.x, bullet.y)
    if target ~= nil then
      local distance = math.sqrt((target.x - bullet.x)^2 + (target.y - bullet.y)^2)
      if target.health > 0 and distance <= 1 then
        target.health = target.health - bullet.damage
      else
        table.insert(not_used_bullets, bullet)
      end
    end
  end
  M._bullets = not_used_bullets
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
    if creep.x < Tower.get().x then
        creep.x = init_x + 1
    elseif creep.x > Tower.get().x then
        creep.x = init_x - 1
    end
    if creep.y < Tower.get().y then
        creep.y = init_y + 1
    elseif creep.y > Tower.get().y then
        creep.y = init_y - 1
    end
    -- avoid placing the creep on top of the tower
    if creep.x == Tower.get().x and creep.y == Tower.get().y then
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
    local distance = math.sqrt((creep.x - Tower.get().x)^2 + (creep.y - Tower.get().y)^2)
    if distance <= 3 then
      Tower.get().health = Tower.get().health - creep.damage
      print('Tower hit: ' .. Tower.get().health)
    end
    ::continue::
  end
end

M.remove_dead_creeps = function ()
  local new_creeps = {}
  for _, creep in ipairs(M._creeps) do
    if creep.health > 0 then
      table.insert(new_creeps, creep)
    else
      M.add_gold(creep.reward)
    end
  end
  M._creeps = new_creeps
end

M.spawn_creeps = function (iteration)
  local creep_types = {Creeps.MINI, Creeps.SMALL, Creeps.MEDIUM, Creeps.ARMORED}
  local num_creeps_by_type = {
    [Creeps.MINI] = 15,
    [Creeps.SMALL] = 7,
    [Creeps.MEDIUM] = 3,
    [Creeps.ARMORED] = 1,
  }
  local creep_factory = {
    [Creeps.MINI] = Creeps.mini,
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
  M.fire(iteration)
  M.move_bullets()
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
