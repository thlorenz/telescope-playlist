local M = {}
local renderer = require("playlist.renderer")

function M.generate_pls(entries)
	local playlist = renderer.render_pls(entries)
	local file_path = os.tmpname()
	local file = io.open(file_path, "w")
	file:write(playlist)
	file:close()
	return file_path
end

return M
