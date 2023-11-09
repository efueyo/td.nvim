-- for local development use
-- Reload command will clear the plugin cache and reload the plugin
-- you can get the Reload command with :so %
vim.api.nvim_create_user_command('Reload', function ()
 package.loaded.td = nil
 package.loaded['td.draw'] = nil
 package.loaded['td.game'] = nil
 package.loaded['td.creeps'] = nil
 package.loaded['td.board'] = nil
 package.loaded['td.weapons'] = nil
 require('td')
end, {})
