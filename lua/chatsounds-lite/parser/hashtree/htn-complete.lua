local base = include("chatsounds-lite/parser/hashtree/hashtreenav.lua")

---@class CSL_HashTreeNav_Complete : CSL_HashTreeNav
---@field results any[]
---@field results_start number[]
---@field results_end number[]
---@field last_val any
local p = base:new()
function p:_init()
    self.results = {}
    self.results_start = {}
    self.results_finish = {}
end

function p:_post_discover(cont, val)
    self.last_val = val or self.last_val
end

function p:_before_reset()
    if not self.sequence_end then return end
    local i = #self.results + 1
    self.results[i]       = self.last_val
    self.results_start[i] = self.sequence_start
    self.results_finish[i]   = self.sequence_end
end

--- Returns iterator.
---@return number index
---@return number start
---@return number finish
---@return any sequence
function p:export()

    local start = self.results_start
    local finish = self.results_finish

    local iter = function(state, control)
        control = control + 1
        local val = state[control]
        if not val then return nil end
        return control, start[control], finish[control], val
    end

    return iter, self.results, 0
end

return p
