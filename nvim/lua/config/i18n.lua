local M = {}

function M.wrap_in_translation()
  local start_col = vim.fn.col("v")
  local end_col = vim.fn.col(".")
  if start_col > end_col then
    start_col, end_col = end_col, start_col
  end

  local line = vim.api.nvim_get_current_line()
  local selected_text = line:sub(start_col, end_col)

  -- Remove surrounding quotes if present and matching
  if #selected_text >= 2 then
    local first_char = selected_text:sub(1, 1)
    local last_char = selected_text:sub(-1)
    if (first_char == last_char) and (first_char == '"' or first_char == "'") then
      selected_text = selected_text:sub(2, -2)
    end
  end

  local replaced = "$t('" .. selected_text .. "')"
  local new_line = line:sub(1, start_col - 1) .. replaced .. line:sub(end_col + 1)
  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

function M.add_to_translation_files()
  vim.cmd("normal! vi'y")
  local text = vim.fn.getreg('"')

  if text == "" then
    vim.notify("No text found with va'", vim.log.levels.WARN)
    return
  end

  local files = {
    "src/i18n/en-US/pages.ts",
    "src/i18n/nl-NL/pages.ts",
  }

  for _, file_path in ipairs(files) do
    local lines = {}
    for line in io.lines(file_path) do
      lines[#lines + 1] = line
    end
    table.insert(lines, #lines, "  '" .. text .. "': '" .. text .. "',")

    local f = io.open(file_path, "w")
    if f then
      f:write(table.concat(lines, "\n") .. "\n")
      f:close()
      vim.notify("Added translation key '" .. text .. "' to " .. file_path)
    else
      vim.notify("Failed to open file: " .. file_path, vim.log.levels.ERROR)
    end
  end
end

return M
