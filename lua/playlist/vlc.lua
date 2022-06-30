local M = {}

local status_ok, plenary = pcall(require, "plenary")
if not status_ok then
	vim.notify(
		"Failed to load plenary which is required for the playlist plugin"
	)
	return
end

function M.open(url, play)
	play = play or false
	assert(
		vim.fn.executable("osascript") == 1,
		"at this point this extension requires running on OSX with osacript to open an entry"
	)
	local play_str = ""
	if play then
		play_str = [[

  play
]]
	end

	local cmd = [[
tell application "VLC"
  OpenURL "]] .. url .. [["]] .. play_str .. [[

end tell]]

	plenary.Job
		:new({
			command = "osascript",
			args = { "-e", cmd },
			on_exit = function(j, return_val)
				if return_val ~= 0 then
					print("Opening in VLC failed " .. vim.inspect(j:result()))
				end
			end,
		})
		:start()
end

M.open("http://hoth.alonhosting.com:2480/stream", true)

return M
