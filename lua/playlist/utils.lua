local M = {}

function M.re_require(pack)
	package.loaded[pack] = nil
	return require(pack)
end

function M.format(s, tab)
	return (s:gsub("($%b{})", function(w)
		return tab[w:sub(3, -2)] or w
	end))
end

return M
