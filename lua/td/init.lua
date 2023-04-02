local draw = require('td.draw').draw

local M = {
  width=80,
  height=30,
}
M._buffer = nil

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

M.play_iteration = function ()
  if M._tower.health <= 0 then
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
  return true
end

M.get_state = function ()
  return {
    tower=M._tower,
    creeps=M._creeps
  }
end
M._draw = function ()
  draw(M.width, M.height, M.get_state())
end
M.start = function ()
  M.setTower()
  M.setCreeps()
  M._draw()

  local timer = vim.loop.new_timer()
  M.timer = timer
  -- Waits 1000ms, then repeats every 750ms until timer:close().
  timer:start(1000, 750, vim.schedule_wrap(function()
    local still_alive = M.play_iteration()
    M._draw()
    if not still_alive then
      print('Game over')
      timer:close()
    end
  end))
end

M.stop = function ()
  if M.timer ~= nil then
    M.timer:close()
    M.timer = nil
  end
end

vim.api.nvim_create_user_command("StartGame", M.start, {})
vim.api.nvim_create_user_command("StopGame", M.stop, {})
