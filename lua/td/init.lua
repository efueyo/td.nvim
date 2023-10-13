local draw = require('td.draw')
local game = require('td.game')

local M = {}

function M._draw()
  draw.draw(game.get_state(), M.is_running())
end

function M.is_running()
  return M.timer ~= nil
end

function M.set_up_keymaps()
  draw.ensure_buffer()
  local bufnr = draw.get_buffer()
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>t", "", {noremap = true, desc = "Upgrade tower", callback = M.update_tower})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>g", "", {noremap = true, desc = "Upgrade gun", callback = M.upgrade_gun})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>c", "", {noremap = true, desc = "Upgrade cannon", callback = M.upgrade_cannon})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>i", "", {noremap = true, desc = "Upgrade ice", callback = M.upgrade_ice})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>m", "", {noremap = true, desc = "Upgrade ice", callback = M.upgrade_mine})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader><leader>", "", {noremap = true, desc = "Toggle game. Start/Stop", callback = M.toggle})
  vim.api.nvim_buf_set_keymap(bufnr, "n", "?", "", {noremap = true, desc = "Print instructions", callback = M.print_instructions})
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

function M.upgrade_mine()
  game.upgrade_mine()
  M._draw()
end

function M.stop()
  if M.timer ~= nil then
    M.timer:close()
    M.timer = nil
  end
  M._draw()
end

function M.print_instructions()
  M.stop()
  local content = {
    "Welcome to TD Nvim instructions. The game has been paused.",
    "",
    "Upgrade your tower to get new weapons.",
    "Upgrade your weapons to defeat stronger creeps.",
    "Each upgrade costs more than the preivous.",
    "",
    "Here are some keymaps and commands that you might find useful:",
    " 🏰 '<leader>t' to update your Tower or :UpgradeTower.",
    " 🏹 '<leader>g' to update your Gun or :UpgradeGun.",
    " 💣 '<leader>c' to update your Cannon or :UpgradeCannon.",
    " ❄️  '<leader>i' to update your Ice or :UpgradeIce.",
    " 🧨 '<leader>m' to update your Mine or :UpgradeMine.",
    " 🚾 '<leader><leader>' to pause/resume the game.",
    " ❓ '?' to display this information.",
    "",
    "Remember to press <leader><leader> to resume the game after closing",
    "this window.",
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, content)
  local opts = {
    relative= 'editor',
    width= 70,
    height= 18,
    col= 15,
    row= 5,
    anchor= 'NW',
    style= 'minimal',
    border='single',
    title='TD Nvim',
    title_pos='center',
  }
  vim.api.nvim_open_win(buf, true, opts)
end

vim.api.nvim_create_user_command("StartGame", M.start, {})
vim.api.nvim_create_user_command("TDToggle", M.toggle, {})
vim.api.nvim_create_user_command("StopGame", M.stop, {})
vim.api.nvim_create_user_command("UpgradeTower", M.update_tower, {})
vim.api.nvim_create_user_command("UpgradeGun", M.upgrade_gun, {})
vim.api.nvim_create_user_command("UpgradeCannon", M.upgrade_cannon, {})
vim.api.nvim_create_user_command("UpgradeIce", M.upgrade_ice, {})
vim.api.nvim_create_user_command("UpgradeMine", M.upgrade_mine, {})
