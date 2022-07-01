local M = {}

local parser = require("playlist.parser")

local function file_exists(file)
	local f = io.open(file, "rb")
	if f then
		f:close()
	end
	return f ~= nil
end

local function lines_from(file)
	assert(file_exists(file), file .. " not found")
	local lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	return lines
end

local function file_extension(url)
	return url:match("^.+(%..+)$")
end

function load_playlist(path, category)
	local lines = lines_from(path)
	local ext = file_extension(path)
	if ext == ".pls" then
		return parser.parse_pls(lines, category)
	end
	vim.notify(
		"Playlists of extension " .. ext .. " are not supported yet.",
		"error"
	)
end

function M.load(playlists)
	local results = {}
	for k, v in pairs(playlists) do
		local loaded = load_playlist(v, k)
		if loaded ~= nil then
			for _, v in pairs(loaded) do
				results[#results + 1] = v
			end
		end
	end
	return results
end

return M
