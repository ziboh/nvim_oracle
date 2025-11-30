local M = {}

function M.is_remote()
  if vim.env.SSH_TTY ~= nil or (vim.env.WEZTERM_EXECUTABLE ~= nil and vim.env.XDG_RUNTIME_DIR ~= nil) then
    return true
  else
    return false
  end
end

function M.has_pack_plugin(name)
  local plugins = vim.pack.get({plugin_name})  
  return #plugins > 0 and plugins[1].active == true  
end

return M
