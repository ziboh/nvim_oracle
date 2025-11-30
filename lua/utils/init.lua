local M = {}

function M.is_remote()
  if vim.env.SSH_TTY ~= nil or (vim.env.WEZTERM_EXECUTABLE ~= nil and vim.env.XDG_RUNTIME_DIR ~= nil) then
    return true
  else
    return false
  end
end

-- 判断某个插件是否启动
function M.has(name)
  local ok, plugins = pcall(vim.pack.get, {plugin_name})  
  if not ok then  
    return false  -- 插件未安装或其他错误  
  end  
  return #plugins > 0 and plugins[1].active == true  
end

return M
