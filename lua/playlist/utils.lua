local M = {}

function M.re_require(pack)
	package.loaded[pack] = nil
	return require(pack)
end

return M
