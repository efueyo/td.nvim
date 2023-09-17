local Creeps = require('td.creeps')
local Tower = require('td.tower')

local M = {}

local initial_gold = 100

function M.setTower()
  Tower.init()
end
function M.add_creeps(cs)
  for _, creep in ipairs(cs) do
    table.insert(M._creeps, creep)
  end
end
function M.setCreeps()
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


function M.init()
  M.setTower()
  M.setCreeps()
  M._gold = initial_gold
  M._xp = 0
  M._effects = {}
end

function M.alive()
  return Tower.alive()
end

function M.upgrade_tower()
  local cost = 100
  if M._gold < cost then
    return
  end
  Tower.upgrade()
  M.add_gold(-cost)
end

function M.upgrade_gun()
  local cost = 100
  if M._gold < cost then
    return
  end
  Tower.upgrade_gun()
  M.add_gold(-cost)
end
function M.upgrade_cannon()
  local cost = 100
  if M._gold < cost then
    return
  end
  Tower.upgrade_cannon()
  M.add_gold(-cost)
end

function M.add_gold(gold)
  M._gold = M._gold or 0
  M._gold = M._gold + gold
end

function M.get_state()
  return {
    alive= M.alive(),
    tower= Tower.get(),
    bullets= M._bullets or {},
    creeps= M._creeps or {},
    gold= M._gold or 0,
    xp= M._xp or 0,
    effects= M._effects or {},
  }
end

function M.fire(iteration)
  M._bullets = M._bullets or {}
  for _, bullet in ipairs(Tower.fire(iteration)) do
    table.insert(M._bullets, bullet)
  end
end

function M._get_creeps_in_range(x, y, range)
  local creeps = {}
  for _, creep in ipairs(M._creeps) do
    local distance = math.sqrt((creep.x - x)^2 + (creep.y - y)^2)
    if distance <= range then
      table.insert(creeps, creep)
    end
  end
  return creeps
end

function M._find_closest_creep(x, y)
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

function M.add_effect(effect, x, y, duration)
  table.insert(M._effects, {
    effect= effect,
    x= x,
    y= y,
    duration= duration,
  })
end

function M.update_effects()
  local remaining_effects = {}
  for _, effect in ipairs(M._effects) do
    effect.duration = effect.duration - 1
    if effect.duration > 0 then
      table.insert(remaining_effects, effect)
    end
  end
  M._effects = remaining_effects
end

function M.move_bullets()
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

function M.add_xp(xp)
  M._xp = M._xp or 0
  local mult = 1 + (Tower.get().level - 1) * 0.1
  M._xp = M._xp + (xp * mult)
end

function M.attack_creep(bullet, target)
  local prev_health = target.health
  target.health = target.health - bullet.damage
  local damage = prev_health - math.max(0, target.health)
  M.add_xp(damage)
end

function M.attack_creeps()
  local not_used_bullets = {}
  for _, bullet in ipairs(M._bullets) do
    local target = M._find_closest_creep(bullet.x, bullet.y)
    if target ~= nil then
      local distance = math.sqrt((target.x - bullet.x)^2 + (target.y - bullet.y)^2)
      if target.health > 0 and distance <= 1 then
        if bullet.blast_radius ~= nil then
          local creeps = M._get_creeps_in_range(target.x, target.y, bullet.blast_radius)
          for _, creep in ipairs(creeps) do
            M.attack_creep(bullet, creep)
          end
          -- add effect of fire in all the blast area
          for x = bullet.x - bullet.blast_radius, bullet.x + bullet.blast_radius do
            for y = bullet.y - bullet.blast_radius, bullet.y + bullet.blast_radius do
              M.add_effect('FIRE', x, y, 3)
            end
          end
        else
          M.attack_creep(bullet, target)
        end
      else
        table.insert(not_used_bullets, bullet)
      end
    end
  end
  M._bullets = not_used_bullets
end

function M.move_creeps(iteration)
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

function M.attack_tower(iteration)
  if iteration % 2 ~= 0 then
    return
  end
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

function M.remove_dead_creeps()
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

function M.spawn_creeps(iteration)
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

function M.play_iteration(iteration)
  if not M.alive() then
    return false
  end
  M.fire(iteration)
  M.move_bullets()
  M.remove_dead_creeps()
  M.attack_creeps()
  M.move_creeps(iteration)
  M.attack_tower(iteration)
  M.update_effects()
  -- spawn more creeps every 10 iterations
  if iteration % 10 == 0 then
    M.spawn_creeps(iteration)
  end
  return M.alive()
end


return M
