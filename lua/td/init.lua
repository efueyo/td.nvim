local draw = require('td.draw').draw
local game = require('td.game')

local M = {
  width=80,
  height=30,
}

M._draw = function ()
  draw(M.width, M.height, game.get_state())
end

M.start = function ()
  game.init(M.width, M.height)
  M._draw()

  local timer = vim.loop.new_timer()
  M.timer = timer
  local iteration = 0
  -- Waits 1000ms, then repeats every 750ms until timer:close().
  timer:start(1000, 750, vim.schedule_wrap(function()
    iteration = iteration + 1
    local still_alive = game.play_iteration(iteration)
    M._draw()
    if not still_alive then
      print('Game over')
      M.stop()
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
