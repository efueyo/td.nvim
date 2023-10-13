local Creeps = require('td.creeps')
local Effects = require('td.effects')
local Weapons = require('td.weapons')
local board = require('td.board')
local M = {}


-- colors
local colors = {
  Health_90 = '#A6FF00',
  Health_70 = '#C4FF00',
  Health_50 = '#E9FF00',
  Health_30 = '#FFC600',
  Health_10 = '#FF4700',
  Health_00 = '#FF0000'
}

local effects_colors = {
    [Effects.FIRE] = '#BD270A',
    [Effects.ICE] = '#46C9E8',
}

local function get_color_from_health(health_ratio)
  if health_ratio >= 90 then
    return 'Health_90'
  elseif health_ratio >= 70 then
    return 'Health_70'
  elseif health_ratio >= 50 then
    return 'Health_50'
  elseif health_ratio >= 30 then
    return 'Health_30'
  elseif health_ratio >= 10 then
    return 'Health_10'
  else
    return 'Health_00'
  end
end

-- define highlight groups
for group, color in pairs(colors) do
  vim.cmd('highlight clear ' .. group)
  vim.cmd('highlight ' .. group .. ' guifg=' .. color)
end
for group, color in pairs(effects_colors) do
  vim.cmd('highlight clear ' .. group)
  vim.cmd('highlight ' .. group .. ' guibg=' .. color)
end


local ns = vim.api.nvim_create_namespace('TD')

local function set_health_colors(bufnr, state)
  -- color tower
  local tower_health = state.tower.health
  local tower_health_ratio = math.floor(tower_health / state.tower.initial_health * 100)
  local tower_color = get_color_from_health(tower_health_ratio)
  local tower_line = state.tower.y
  local tower_start_col = state.tower.x
  local tower_end_col = state.tower.x + 1
  vim.api.nvim_buf_add_highlight(bufnr, ns, tower_color, tower_line, tower_start_col, tower_end_col)
  -- color creeps
  for _, creep in ipairs(state.creeps) do
    local health = creep.health
    local health_ratio = math.floor(health / creep.initial_health * 100)
    local color = get_color_from_health(health_ratio)
    local line = creep.y
    local start_col = creep.x
    local end_col = creep.x + 1
    vim.api.nvim_buf_add_highlight(bufnr, ns, color, line, start_col, end_col)
  end
end

local function set_effects(bufnr, state)
  for _, effect in ipairs(state.effects) do
    local line = effect.y
    local start_col = effect.x
    local end_col = effect.x + 1
    local name = effect.effect
    -- check if it is a valid effect
    if not effects_colors[name] or
      line < 0 or line > board.height or
      start_col < 0 or end_col > board.width then
      goto continue
    end
    vim.api.nvim_buf_add_highlight(bufnr, ns, name, line, start_col, end_col)
    ::continue::
  end
  for _, creep in ipairs(state.creeps) do
    for _, name in ipairs(creep.effects) do
      local line = creep.y
      local start_col = creep.x
      local end_col = creep.x + 1
      if effects_colors[name] then
        vim.api.nvim_buf_add_highlight(bufnr, ns, name, line, start_col, end_col)
      end
    end
  end

end
local function creep_symbol(creep)
  local symbols = {
    [Creeps.NANO] = '^',
    [Creeps.MINI] = '\'',
    [Creeps.SMALL] = 's',
    [Creeps.MEDIUM] = 'm',
    [Creeps.ARMORED] = '#',
    [Creeps.HERO] = '@',
  }
  return symbols[creep.name] or '?'
end

local function bullet_symbol(bullet)
  local symbols = {
    [Weapons.GUN] = 'o',
    [Weapons.CANNON] = 'O',
    [Weapons.ICE] = '*',
    [Weapons.MINE] = 'x',
  }
  return symbols[bullet.name] or '?'
end

-- n formats the numbers to limit the amount of digits
local function n(num)
  if num > 1e6 then
    return string.format('%.2fM', num / 1e6)
  elseif num > 1e3 then
    return string.format('%.2fK', num / 1e3)
  else
    return tostring(num)
  end
end

local function add_summary(lines, state)
  if not state.alive then
    lines[1] = lines[1] .. '☠️ Game over ☠️'
  end
  lines[2] = lines[2] .. ' XP: ' .. n(state.xp)
  lines[3] = lines[3] .. ' Gold: 💰 ' .. n(state.gold)
  lines[4] = lines[4] .. ' Next Upgrade: 💰 ' .. n(state.upgrade_cost)
  lines[5] = lines[5] .. ' Tower(' .. state.tower.level .. '): ❤️ ' .. n(state.tower.health)
  local offset = 5
  for i, weapon in ipairs(state.tower.weapons) do
    local index = offset + i
    lines[index] = lines[index] .. '  ' .. weapon.name .. '(' .. weapon.level ..') ⚔️ ' .. n(weapon.damage)
  end
  offset = 4 + #state.tower.weapons + 1
  lines[offset+1] = lines[offset+1] .. ' Creeps:'
  for i, creep in ipairs(state.creeps) do
    local index = offset + 1 + i
    if index > board.height then
      goto continue
    end
    lines[index] = lines[index] .. '  ' .. creep.name .. ' ❤️ ' .. n(creep.health) .. ' ⚔️ ' .. n(creep.damage).. ' 🪙' .. n(creep.reward)
    ::continue::
  end
end
M._buffer = nil
function M.set_buffer(bufnr)
  M._buffer = bufnr
end
function M.get_buffer()
  return M._buffer
end
function M.ensure_buffer()
  if M._buffer == nil then
    M._buffer = vim.api.nvim_create_buf(true, true)
  end
end
-- draw the game state
function M.draw(state)
  -- create buffer if not exists
  M.ensure_buffer()
  local bufnr = M._buffer
  vim.api.nvim_set_current_buf(bufnr)
  local lines = {}
  for _=1, board.height do
    table.insert(lines, string.rep(' ', board.width))
  end

  local tower_x = state.tower.x
  local tower_y = state.tower.y
  local tower_line = lines[tower_y]
  lines[tower_y+1] = string.sub(tower_line, 1, tower_x) .. 'T' .. string.sub(tower_line, tower_x+2)
  for _, bullet in ipairs(state.bullets) do
    local line = lines[bullet.y+1]
    local symbol = bullet_symbol(bullet)
    lines[bullet.y+1] = string.sub(line, 1, bullet.x) .. symbol .. string.sub(line, bullet.x+2)
  end
  for _, creep in ipairs(state.creeps) do
    local line = lines[creep.y+1]
    local symbol = creep_symbol(creep)
    lines[creep.y+1] = string.sub(line, 1, creep.x) .. symbol .. string.sub(line, creep.x+2)
  end
  add_summary(lines, state)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  set_health_colors(bufnr, state)
  set_effects(bufnr, state)
end
return M
