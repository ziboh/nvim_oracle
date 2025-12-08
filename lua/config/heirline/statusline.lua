local components = require 'config.heirline.components'
vim.o.cmdheight = 0

return { -- statusline
  components.RightPadding(components.Mode, 1),
  components.RightPadding(components.FileType, 1),
  components.RightPadding(components.Git, 1),
  components.RightPadding(components.Diagnostics, 1),
  -- components.RightPadding(components.Overseer, 1),
  components.RightPadding(components.SearchOccurrence, 0),
  components.Fill,
  components.MacroRecording,
  components.Fill,
  components.RightPadding(components.ShowCmd),
  -- components.RightPadding(components.LSPActive),
  components.RightPadding(components.Lsp, 1),
  components.RightPadding(components.Rime, 1),
  components.RightPadding(components.SuperMaven, 1),
  components.RightPadding(components.FileCode),
  -- components.RightPadding(components.FileType, 0),
  components.Ruler,
  components.ScrollBar,
}
