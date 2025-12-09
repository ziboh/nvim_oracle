vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.x") },
	"https://github.com/saghen/blink.compat",
})
vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		local opts = {
			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
						kind_resolution = {
							enabled = true,
							blocked_filetypes = { "typescriptreact", "javascriptreact", "vue", "nu", "nushell" },
						},
					},
				},
				menu = {
					border = "single",
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon" },
							{ "source_name" },
						},
						components = {
							source_name = {
								text = function(ctx)
									return "[" .. ctx.source_name .. "]"
								end,
							},
							kind_icon = {
								ellipsis = false,
								text = function(ctx)
									local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
									return kind_icon
								end,
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
							kind = {
								text = function(ctx)
									return "<" .. ctx.kind .. ">"
								end,
							},
						},
						treesitter = { "lsp" },
					},
				},
				documentation = {
					window = { border = "single" },
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				ghost_text = {
					enabled = vim.g.ai_cmp,
				},
			},
			cmdline = {
				enabled = false,
			},
			sources = {
				compat = { "supermaven" },
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					lsp = {
						transform_items = function(_, items)
							-- the default transformer will do this
							for _, item in ipairs(items) do
								if item.kind == require("blink.cmp.types").CompletionItemKind.Snippet then
									item.score_offset = item.score_offset - 3
								end
								local client = vim.lsp.get_client_by_id(item.client_id)
								if client ~= nil then
									if client.name == "rime_ls" then
										item.score_offset = item.score_offset - 3
									end

									item.source_name = client.name
								end
							end

							return items
						end,
					},
					supermaven = {
						enabled = function()
							return vim.g.supermaven_enabled and not vim.g.rime_enabled
						end,
						kind = "Supermaven",
						score_offset = 100,
						async = true,
					},
				},
			},

			keymap = {
				["<Tab>"] = {
					"snippet_forward",
					function() -- sidekick next edit suggestion
						return require("sidekick").nes_jump_or_apply()
					end,
					"fallback",
				},
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<C-y>"] = { "select_and_accept" },
				["<C-n>"] = { "show", "select_next", "fallback_to_mappings" },
			},
			appearance = {
				use_nvim_cmp_as_default = false,
				-- nerd_font_variant = "mono",
				kind_icons = {
					Text = "󰉿",
					Method = "󰊕",
					Function = "󰊕",
					Constructor = "󰒓",

					Field = "󰜢",
					Variable = "󰆦",
					Property = "󰖷",

					Class = "󱡠",
					Interface = "󱡠",
					Struct = "󱡠",
					Module = "󰅩",

					Unit = "󰪚",
					Value = "󰦨",
					Enum = "󰦨",
					EnumMember = "󰦨",

					Keyword = "󰻾",
					Constant = "󰏿",

					Snippet = "󱄽",
					Color = "󰏘",
					File = "󰈔",
					Reference = "󰬲",
					Foler = "󰉋",
					Event = "󱐋",
					Operator = "󰪚",
					TypeParameter = "󰬛",
				},
			},
		}

		-- setup compat sources
		local enabled = opts.sources.default
		for _, source in ipairs(opts.sources.compat or {}) do
			opts.sources.providers[source] = vim.tbl_deep_extend(
				"force",
				{ name = source, module = "blink.compat.source" },
				opts.sources.providers[source] or {}
			)
			if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
				table.insert(enabled, source)
			end
		end

		-- Unset custom prop to pass blink.cmp validation
		opts.sources.compat = nil
		-- check if we need to override symbol kinds
		for _, provider in pairs(opts.sources.providers or {}) do
			if provider.kind then
				local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
				local kind_idx = #CompletionItemKind + 1
				CompletionItemKind[kind_idx] = provider.kind
				CompletionItemKind[provider.kind] = kind_idx

				local transform_items = provider.transform_items
				provider.transform_items = function(ctx, items)
					items = transform_items and transform_items(ctx, items) or items
					for _, item in ipairs(items) do
						item.kind = kind_idx or item.kind
					end
					return items
				end

				provider.kind = nil
			end
		end

		require("blink.cmp").setup(opts)
		vim.api.nvim_exec_autocmds("User", { pattern = "BlinkLoaded" })
	end,
	once = true,
})
