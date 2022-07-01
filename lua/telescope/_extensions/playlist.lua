local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This plugin requires nvim-telescope/telescope.nvim")
	return
end

local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local MultiSelect = require("telescope.pickers.multi")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local action_state = require("telescope.actions.state")

local loader = require("playlist.loader")
local parser = require("playlist.parser")
local open = require("playlist.open")
local generator = require("playlist.generator")

local config = {}
local picker = nil

-- Loading playlist when the extension is used for the first time and then caching it
local playlist = nil
local function search()
	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 20 },
			{ width = 50 },
			{ remaining = true },
		},
	})

	local make_display = function(entry)
		local value = parser.cut_token_from_url(entry.value)
		return displayer({
			entry.category,
			entry.name,
			value,
		})
	end

	if not config.cache or playlist == nil then
		playlist = loader.load(config.paths)
	end

	local function action(entry)
		local entries = picker:get_multi_selection()
		if entries ~= nil and #entries > 0 then
			local playlist_file = generator.generate_pls(entries)
			config.open("file://" .. playlist_file)
		elseif entry ~= nil then
			config.open(entry.value)
			vim.notify("Playlist: opening '" .. entry.name .. "'", "info")
		end
	end

	local function attach_mappings(prompt_bufnr)
		actions.select_default:replace(function()
			local playlist_item = action_state.get_selected_entry()
			actions.close(prompt_bufnr)
			action(playlist_item)
		end)
		return true
	end

	picker = pickers.new(opts, {
		prompt_title = "Playlist",
		sorter = conf.generic_sorter(opts),
		finder = finders.new_table({
			results = playlist,
			entry_maker = function(entry)
				return {
					ordinal = entry.category .. entry.title,
					display = make_display,

					name = entry.title,
					value = entry.file,
					category = entry.category,
				}
			end,
		}),
		attach_mappings = attach_mappings,
	})

	picker:find()
end

local exports = { playlist = search }
local function set_config(opt_name, value, default)
	config[opt_name] = value == nil and default or value
end

-- use this while hacking on this extension to quickly reload it and see the results
local function reload()
	set_config("paths", {
		Jazz = "/Volumes/d/dotfiles/bash/scripts/playlists/jazz-all.pls",
		DI = "/Volumes/d/dotfiles/bash/scripts/playlists/di-all.pls",
		["CC0 RFM NCM"] = "/Volumes/d/dotfiles/bash/scripts/playlists/cc0-rfm-ncm.pls",
	}, {})
	set_config("cache", true, true)
	set_config("open", open.open, open.open)
	local manager = require("telescope._extensions").manager
	manager.playlist = exports
end
-- reload()

return telescope.register_extension({
	setup = function(opts)
		set_config("paths", opts.paths, {})
		set_config("cache", opts.cache, true)
		set_config("open", opts.open, open.open)
	end,
	exports = exports,
})
