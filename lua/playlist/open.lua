local M = {}

local vlc = require("playlist.vlc")
local cli_open = require("playlist.cli-open")

function M.open(url)
	-- YouTube streams do play in VLC, but lots of times they stutter for some reason
	if url:match("youtube.com") then
		cli_open.open(url)
	else
		vlc.open(url, true)
	end
end

return M
