local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	error("This plugin requires nvim-telescope/telescope.nvim")
	return
end

local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local action_state = require("telescope.actions.state")

local loader = require("playlist.loader")
local parser = require("playlist.parser")
local vlc = require("playlist.vlc")

local config = {}

local function action(entry)
	if entry ~= nil then
		vlc.open(entry.value)
		vim.notify("Playlist: opening '" .. entry.name .. "'", "info")
	end
end

-- Loading playlist when the extension is used for the first time and then caching it
local playlist = nil
local function search()
	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 30 },
			{ width = 10 },
			{ remaining = true },
		},
	})

	local make_display = function(entry)
		local value = parser.cut_token_from_url(entry.value)
		return displayer({
			entry.name,
			entry.category,
			value,
		})
	end

	if not config.cache or playlist == nil then
		playlist = loader.load(config.paths)
	end

	pickers.new(opts, {
		prompt_title = "Playlist",
		sorter = conf.generic_sorter(opts),
		finder = finders.new_table({
			results = playlist,
			entry_maker = function(entry)
				return {
					ordinal = entry.title .. entry.category,
					display = make_display,

					name = entry.title,
					value = entry.file,
					category = entry.category,
				}
			end,
		}),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				local playlist_item = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				action(playlist_item)
			end)
			return true
		end,
	}):find()
end

local exports = { playlist = search }

-- use this while hacking on this extension to quickly reload it and see the results
local function reload()
	local manager = require("telescope._extensions").manager
	manager.playlist = exports
end
-- reload()

local function set_config(opt_name, value, default)
	config[opt_name] = value == nil and default or value
end

return telescope.register_extension({
	setup = function(opts)
		set_config("paths", opts.paths, {})
		set_config("cache", opts.cache, true)
	end,
	exports = exports,
})
