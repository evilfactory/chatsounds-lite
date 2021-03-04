---@class CSL_Parser
---@field tree HashTree
local p = {}

---@return CSL_Parser
function p:new() 
    ---@type CSL_Parser
    local obj = {}
    setmetatable(obj, {__index = self}) 
    obj:reset()
    return obj
end

-- Partial class definitions :D
loadfile("chatsounds-lite/parser/parser-build.lua")(p)
loadfile("chatsounds-lite/parser/parser-parse.lua")(p)
-- Go EmmyLua! (and sumneko's Lua)

-- (also, fuck gmod lua file limit)

return p
