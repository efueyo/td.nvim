local api = vim.api
if not api.nvim_create_user_command then
  return
end
local cmd = api.nvim_create_user_command

cmd("TDStart", function() require('td').start() end, {})
cmd("TDToggle", function() require('td').toggle() end, {})
cmd("TDStop", function() require('td').stop() end, {})
cmd("UpgradeTower", function() require('td').update_tower() end, {})
cmd("UpgradeGun", function() require('td').upgrade_gun() end, {})
cmd("UpgradeCannon", function() require('td').upgrade_cannon() end, {})
cmd("UpgradeIce", function() require('td').upgrade_ice() end, {})
cmd("UpgradeMine", function() require('td').upgrade_mine() end, {})
