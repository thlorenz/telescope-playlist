local M = {}

local format = require("playlist.utils").format

local function render_pls_entry(entry)
	return format(
		[[File${idx}=${url}
Title${idx}=${title}
Length=0 ]],
		{ idx = entry.index, url = entry.value, title = entry.name }
	)
end

local function render_pls_entries(entries)
	local s = ""
	for _, entry in pairs(entries) do
		s = s .. render_pls_entry(entry) .. "\n"
	end
	return s
end

function M.render_pls(entries)
	return [[[playlist]
NumberOfEntries=]] .. #entries .. "\n" .. render_pls_entries(entries)
end

return M
