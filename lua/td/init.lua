local draw = require('td.draw')
local game = require('td.game')

local M = {}

M._draw = function ()
  draw.draw(game.get_state())
end

M.set_up_keymaps = function ()
  draw.ensure_buffer()
  local bufnr = draw.get_buffer()
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>t", ":UpgradeTower<CR>", {noremap = true, desc = "Upgrade tower"})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>g", ":UpgradeGun<CR>", {noremap = true, desc = "Upgrade gun"})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader><leader>", ":TDToggle<CR>", {noremap = true, desc = "Toggle game. Start/Stop"})
end

M.start = function ()
  draw.ensure_buffer()
  M.set_up_keymaps()

  game.init()
  M._draw()
  M.run_game()
end

M.run_game = function ()
  if M.timer ~= nil then
    return
  end
  local timer = vim.loop.new_timer()
  if timer == nil then
    print('cannot create timer to start the game')
    return
  end
  M.timer = timer
  if M.iteration == nil then
    M.iteration = 0
  end
  -- Waits 1000ms, then repeats every 750ms until timer:close().
  timer:start(1000, 100, vim.schedule_wrap(function()
    M.iteration = M.iteration + 1
    local still_alive = game.play_iteration(M.iteration)
    M._draw()
    if not still_alive then
      print('Game over')
      M.stop()
    end
  end))
end
M.toggle = function ()
  if M.timer == nil then
    M.run_game()
  else
    M.stop()
  end
end

M.update_tower = function ()
  game.upgrade_tower()
  M._draw()
end
M.upgrade_gun = function ()
  game.upgrade_gun()
  M._draw()
end

M.stop = function ()
  if M.timer ~= nil then
    M.timer:close()
    M.timer = nil
  end
end

vim.api.nvim_create_user_command("StartGame", M.start, {})
vim.api.nvim_create_user_command("TDToggle", M.toggle, {})
vim.api.nvim_create_user_command("StopGame", M.stop, {})
vim.api.nvim_create_user_command("UpgradeTower", M.update_tower, {})
vim.api.nvim_create_user_command("UpgradeGun", M.upgrade_gun, {})
