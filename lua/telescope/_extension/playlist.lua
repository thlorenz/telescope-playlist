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

local playlist = [[
[playlist]
NumberOfEntries=8
File1=http://fr1.nexuscast.com:8004/juicestow
Title1=Juice Stowmarket
Length1=0
File2=http://hoth.alonhosting.com:2480/stream
Title2=Online Radio
Length20
File3=http://stream.hosting078.nl:8042/stream
Title3=Radio Uniek Rotterdam
Length3=0
File4=http://wav.carbonwav.com:1200/stream
Title4=Podcast
Length4=0
File5=http://wav.carbonwav.com:1150/stream
Title5=Independent Music
Length5=0
File5=https://listen.di.fm/premium_high/00sclubhits.pls?ds8932irop22df
Title5=with token
Length5=0
File5=http://ec01.streaminghd.net.ar:1580/stream
Title5=Online Radio
Length5=0
]]

local function reload(pack)
	package.loaded[pack] = nil
	return require(pack)
end

local parser = reload("playlist.parser")
local vlc = reload("playlist.vlc")
local samples = parser.parse_pls(playlist)

local function action(entry)
	vlc.open(entry.value)
	vim.notify("Playlist: opening '" .. entry.name .. "'", "info")
end

local function search()
	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 30 },
			{ width = 25 },
			{ remaining = true },
		},
	})

	local make_display = function(entry)
		return displayer({
			entry.name,
			entry.category,
			parser.cut_token_from_url(entry.value),
		})
	end

	pickers.new(opts, {
		prompt_title = "Playlist",
		sorter = conf.generic_sorter(opts),
		finder = finders.new_table({
			results = samples,
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
reload()

return telescope.register_extension({
	exports = exports,
})
