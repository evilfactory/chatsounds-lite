---@class CSL_HashTreeNav
--- Alone, this class returns nothing.
--- You are able to customize it's returns.
---@field null any

---@field input any[]

---@field node any[]
---@field head number
---@field max number
---@field sequence_start number
---@field sequence_end number
local p = {}

---@return CSL_HashTreeNav
function p:new()
	return setmetatable({}, {__index = self})
end

local function discover(self)
    self.head = self.head + 1

    local token = self.input[self.head]

    --print(self.head, self.sequence_start, self.sequence_end)

    --unable to continue: stop and let us export the sequence
    local next_node = self.node[token]
    if not next_node then 
        return false 
    end

    self.node = next_node

    -- we can continue searching for a larger sequence
    local final_value = next_node[self.null]
    if not final_value then 
        return true
    end

    -- we found a sequence and can continue searching for a larger one
    self.sequence_end = self.head
    return true, final_value
end

--- Called with state and final_value:
--- When the sequence ends (meaning it found an invalid value), it returns false  
--- When the sequence can continue, it returns true  
--- When the sequence has found an end, it returns true, sequence_value  
---   Note that the nav will continue searching for a larger sequence.
---
---@param will_continue_searching boolean
---@param sequence_value any
function p:_post_discover(will_continue_searching, sequence_value) end

function p:_before_reset() end

local function reset(self)
    self.head = self.sequence_end or self.sequence_start -- reset our head
    self.sequence_start = self.head + 1 -- self evident.
    self.sequence_end = nil -- no sequences have been found at the start
    self.node = self.map -- new sequence, back to root node.
end

function p:_post_reset() end

function p:_init() end

---@param hashtree CSL_HashTree
---@param input any[]
function p:parse(hashtree, input)
    self.null = hashtree.null

    self.map = hashtree.map

    self.input = input

    self.node = self.map
    self.max = #input
    self.head = 0

    self.sequence_start = 1

    self:_init()

    while self.head < self.max do
        local cont, res = true
        repeat
            cont, res = discover(self)
            self:_post_discover(cont, res)
        until not cont
        self:_before_reset()
        reset(self)
        self:_post_reset()
    end
end

---@return any
function p:export() end

return p
