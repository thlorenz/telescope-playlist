local M = {}

local file_rx = "File%d+=(.+)$"
local title_rx = "Title%d+=(.+)$"
local token_url_rx = "(.+)?"

function M.parse_pls(lines, category)
	category = category or "uncategorized"

	local current_file = nil
	local entries = {}
	local idx = 1

	for _, line in pairs(lines) do
		local file = line:match(file_rx)
		if file ~= nil then
			current_file = file
		end
		local title = line:match(title_rx)
		if title ~= nil then
			assert(current_file ~= nil, "playlist has title without file")
			entries[idx] = {
				title = title,
				file = current_file,
				category = category,
			}
			idx = idx + 1
			current_file = nil
		end
	end
	return entries
end

function M.cut_token_from_url(url)
	local noq = url:match(token_url_rx)
	if noq ~= nil then
		return noq
	else
		return url
	end
end

return M
