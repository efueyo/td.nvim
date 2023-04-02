local M = {}

M.setTower = function ()
  local tower_x = math.floor(M.width/2)
  local tower_y = math.floor(M.height/2)
  local tower_health = 100
  local tower = {x=tower_x, y=tower_y, health=tower_health}
  M._tower = tower
end
M.setCreeps = function ()
  local creep_positions = {
      {x=0, y=0, health=60},
      {x=10, y=0, health=10},
      {x=45, y=0, health=40},
      {x=55, y=0, health=100},
      {x=0, y=10, health=120},
      {x=0, y=14, health=200},
      {x=78, y=00, health=2000},
  }
  M._creeps = creep_positions
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
M.play_iteration = function (iteration)
  if not M.alive() then
    return false
  end
  -- Move creeps towards tower
  for _, creep in ipairs(M._creeps) do
      if creep.health > 0 then
          if creep.x < M._tower.x then
              creep.x = creep.x + 1
          elseif creep.x > M._tower.x then
              creep.x = creep.x - 1
          end
          if creep.y < M._tower.y then
              creep.y = creep.y + 1
          elseif creep.y > M._tower.y then
              creep.y = creep.y - 1
          end

          -- Check if creep is in range of tower and decrease health
          local distance = math.sqrt((creep.x - M._tower.x)^2 + (creep.y - M._tower.y)^2)
          creep.health = creep.health - 10
          print('Creep hit: ' .. creep.health)
          if distance <= 3 then
              M._tower.health = M._tower.health - 10
              print('Tower hit: ' .. M._tower.health)
          end
      end
  end
  return M.alive()
end


return M
