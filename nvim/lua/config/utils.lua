local M = {}

function M.get_monorepo_root()
  local uv = vim.loop
  local cwd = uv.cwd()
  while cwd do
    if uv.fs_stat(cwd .. "/.git") or uv.fs_stat(cwd .. "/packages") then
      return cwd
    end
    local parent = uv.fs_realpath(cwd .. "/..")
    if parent == cwd then
      break
    end
    cwd = parent
  end
  return nil
end

return M
