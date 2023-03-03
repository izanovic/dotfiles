-- Telescope functions
-- require('telescope').load_extension('fzy_native')
local folder = "./"
local M = {}

M.search_project_files = function()
  require('telescope.builtin').find_files({
      promt_title = "< Project Files >",
      cwd = folder,
  })
end

M.search_word_in_project = function()
  require('telescope.builtin').live_grep({
      promt_title = "< Project Files >",
      cwd = folder,
  })
end


M.toggle_project_folder = function()
  if folder == "./" then
    folder = "./src/"
  else
    folder = "./"
  end
end

return M
