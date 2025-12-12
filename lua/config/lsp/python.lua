local opts = {
	servers = {
		ruff = {
			cmd_env = { RUFF_TRACE = "messages" },
			init_options = {
				settings = {
					logLevel = "error",
				},
			},
		},
		pyright = {},
	},
	setup = {
		pyright = function()
			Snacks.util.lsp.on({ name = "pyright" }, function(_, client)
				-- Disable hover in favor of Pyright
				client.server_capabilities.hoverProvider = true
			end)
		end,
	},
}
return opts
