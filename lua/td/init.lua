local M = {}
-- M._width = vim.fn.winwidth(0)
-- M._height = vim.fn.winheight(0)
M._width = 80
M._height = 30

M._buffer = nil

M.draw = function ()
  local lines = {}
  for _=1, M._height do
    table.insert(lines, string.rep(' ', M._width))
  end
  vim.api.nvim_buf_set_lines(M._buffer, 0, -1, false, lines)
  M.drawCreeps()
  M.drawTower()
end
M.setTower = function ()
  local tower_x = math.floor(M._width/2)
  local tower_y = math.floor(M._height/2)
  local tower_health = 100
  M._tower = {x=tower_x, y=tower_y, health=tower_health}
end
M.drawTower = function ()
  local tower_x = M._tower.x
  local tower_y = M._tower.y
  -- local tower_health = M._tower.health
  local line = vim.api.nvim_buf_get_lines(M._buffer, tower_y, tower_y+1, false)[1]
  local new_line = string.sub(line, 1, tower_x) .. 'T' .. string.sub(line, tower_x+2)
  vim.api.nvim_buf_set_lines(M._buffer, tower_y, tower_y+1, false, {new_line})
end
M.setCreeps = function ()
  local creep_positions = {
      {x=0, y=0, health=100},
      {x=10, y=0, health=100},
      {x=45, y=0, health=100}
  }
  M._creep_positions = creep_positions
end
M.drawCreeps = function ()
  for _, creep in ipairs(M._creep_positions) do
    local line = vim.api.nvim_buf_get_lines(M._buffer, creep.y, creep.y+1, false)[1]
    local new_line = string.sub(line, 1, creep.x) .. 'C' .. string.sub(line, creep.x+2)
    vim.api.nvim_buf_set_lines(M._buffer, creep.y, creep.y+1, false, {new_line})
  end
end

M.play_iteration = function ()
  if M._tower.health <= 0 then
    return false
  end
  -- MoTe creeps towards tower
  for _, creep in ipairs(M._creep_positions) do
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
          if distance <= 3 then
              creep.health = creep.health - 10
              M._tower.health = M._tower.health - 10
          end
      end
  end
  return true
end

M.start = function ()
  -- create buffer if not exists
  if M._buffer == nil then
    M._buffer = vim.api.nvim_create_buf(true, true)
  end
  vim.api.nvim_set_current_buf(M._buffer)
  M.setTower()
  M.setCreeps()
  M.draw()

  local timer = vim.loop.new_timer()
  -- Waits 1000ms, then repeats every 750ms until timer:close().
  timer:start(1000, 750, vim.schedule_wrap(function()
    local still_alive = M.play_iteration()
    M.draw()
    if not still_alive then
      print('Game over')
      timer:close()
    end
  end))
end


vim.api.nvim_create_user_command("StartGame", M.start, {})
