---@class CSL_HashTree
local p = {null = true}

---@return CSL_HashTree
function p:new()
	return setmetatable({map = {}}, {__index = self})
end

-- #region Construction

--- v must NOT be a table
function p:add(list_k, value)
	local map = self.map
	local tbl = map
	local size = #list_k
	for i, token in ipairs(list_k) do
		tbl[token] = tbl[token] or {}
		tbl = tbl[token]
	end
	tbl[self.null] = value
end

-- #endregion

return p
