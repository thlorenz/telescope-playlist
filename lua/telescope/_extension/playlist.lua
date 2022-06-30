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

local samples = {
	{
		name = "Super Tune",
		value = "https://something",
		category = "jazz",
	},
	{
		name = "Even Better Tune",
		value = "https://something-better",
		category = "di",
	},
}
local function action(entry)
	vim.notify(vim.inspect(entry))
end

local function search()
	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 40 },
			{ width = 18 },
			{ remaining = true },
		},
	})

	local make_display = function(entry)
		return displayer({
			entry.value .. " " .. entry.name,
			entry.category,
			entry.description,
		})
	end

	pickers.new(opts, {
		prompt_title = "Playlist",
		sorter = conf.generic_sorter(opts),
		finder = finders.new_table({
			results = samples,
			entry_maker = function(entry)
				return {
					ordinal = entry.name .. entry.category,
					display = make_display,

					name = entry.name,
					value = entry.value,
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
reload()

return telescope.register_extension({
	exports = exports,
})
