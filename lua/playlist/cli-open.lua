local M = {}

local status_ok, plenary = pcall(require, "plenary")
if not status_ok then
	vim.notify(
		"Failed to load plenary which is required for the playlist plugin",
		"error"
	)
	return
end

function M.open(url)
	local cmd = "open " .. url

	plenary.Job
		:new({
			command = "open",
			args = { url },
			on_exit = function(j, return_val)
				if return_val ~= 0 then
					print(
						"Opening in via 'open' failed "
							.. vim.inspect(j:result())
					)
				end
			end,
		})
		:start()
end

return M
