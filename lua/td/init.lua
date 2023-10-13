local draw = require('td.draw')
local game = require('td.game')

local M = {}

function M._draw()
  draw.draw(game.get_state())
end

function M.set_up_keymaps()
  draw.ensure_buffer()
  local bufnr = draw.get_buffer()
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>t", "", {noremap = true, desc = "Upgrade tower", callback = M.update_tower})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>g", "", {noremap = true, desc = "Upgrade gun", callback = M.upgrade_gun})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>c", "", {noremap = true, desc = "Upgrade cannon", callback = M.upgrade_cannon})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>i", "", {noremap = true, desc = "Upgrade ice", callback = M.upgrade_ice})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader><leader>", "", {noremap = true, desc = "Toggle game. Start/Stop", callback = M.toggle})
end

function M.start()
  draw.ensure_buffer()
  M.set_up_keymaps()

  M.iteration = 0
  game.init()
  M._draw()
  M.run_game()
end

function M.run_game()
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
  timer:start(1000, 200, vim.schedule_wrap(function()
    M.iteration = M.iteration + 1
    local still_alive = game.play_iteration(M.iteration)
    M._draw()
    if not still_alive then
      print('Game over')
      M.stop()
    end
  end))
end
function M.toggle()
  if M.timer == nil then
    M.run_game()
  else
    M.stop()
  end
end

function M.update_tower()
  game.upgrade_tower()
  M._draw()
end
function M.upgrade_gun()
  game.upgrade_gun()
  M._draw()
end

function M.upgrade_cannon()
  game.upgrade_cannon()
  M._draw()
end

function M.upgrade_ice()
  game.upgrade_ice()
  M._draw()
end

function M.stop()
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
