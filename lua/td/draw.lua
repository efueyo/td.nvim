local M = {}

M.draw = function(bufnr, width, height, state)
  local lines = {}
  for _=1, height do
    table.insert(lines, string.rep(' ', width))
  end

  local tower_x = state.tower.x
  local tower_y = state.tower.y
  local tower_line = lines[tower_y]
  lines[tower_y+1] = string.sub(tower_line, 1, tower_x) .. 'T' .. string.sub(tower_line, tower_x+2)
  for _, creep in ipairs(state.creeps) do
    local line = lines[creep.y+1]
    lines[creep.y+1] = string.sub(line, 1, creep.x) .. 'C' .. string.sub(line, creep.x+2)
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end
return M
