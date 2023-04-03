local creeps = require('td.creeps')
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

local get_color_from_health = function(health_ratio)
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


local ns = vim.api.nvim_create_namespace('TD')

local set_health_colors = function(bufnr, state)
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

local creep_symbol = function (creep)
  local symbols = {
    [creeps.SMALL] = 's',
    [creeps.MEDIUM] = 'm',
    [creeps.ARMORED] = '#',
  }
  return symbols[creep.name] or '?'
end

-- n formats the numbers to limit the amount of digits
local function n(num)
  if num > 1e6 then
    return string.format('%.2fm', num / 1e6)
  elseif num > 1e3 then
    return string.format('%.2fk', num / 1e3)
  else
    return tostring(num)
  end
end

local add_summary = function(lines, state)
  lines[2] = lines[2] .. ' Level: ' .. 'TODO'
  lines[3] = lines[3] .. ' Gold: 💰 ' .. n(state.gold)
  lines[4] = lines[4] .. ' Tower: ❤️ ' .. n(state.tower.health)
  lines[5] = lines[5] .. ' Creeps:'
  local offset = 5
  for i, creep in ipairs(state.creeps) do
    local index = offset + i
    if index > board.height then
      goto continue
    end
    lines[index] = lines[index] .. '  ' .. creep.name .. '. ❤️ ' .. n(creep.health) .. ' ⚔️ ' .. n(creep.damage)
    ::continue::
  end
end
-- draw the game state
M.draw = function(state)
  -- create buffer if not exists
  if M._buffer == nil then
    M._buffer = vim.api.nvim_create_buf(true, true)
  end
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
  for _, creep in ipairs(state.creeps) do
    local line = lines[creep.y+1]
    local symbol = creep_symbol(creep)
    lines[creep.y+1] = string.sub(line, 1, creep.x) .. symbol .. string.sub(line, creep.x+2)
  end
  add_summary(lines, state)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  set_health_colors(bufnr, state)
end
return M
