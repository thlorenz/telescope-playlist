local M = {}

local file_rx = "File%d+=(.+)$"
local title_rx = "Title%d+=(.+)$"

function M.parse_pls(playlist, category)
	category = category or "uncategorized"

	local lines = playlist:gmatch("([^\n]*)\n?")
	local current_file = nil
	local entries = {}
	local idx = 1

	for line in lines do
		local file = line:match(file_rx)
		if file ~= nil then
			current_file = file
		end
		local title = line:match(title_rx)
		if title ~= nil then
			assert(current_file ~= nil, "playlist has title without file")
			entries[idx] = { title = title, file = current_file, category = category }
			idx = idx + 1
			current_file = nil
		end
	end
	return entries
end

return M
