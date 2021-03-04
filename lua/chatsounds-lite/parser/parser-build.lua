---@type CSL_Parser
local p = ...

local csl_hashtree = dofile("chatsounds-lite/parser/hashtree/hashtree.lua")

local function trim(str) return str:match("^%s*(.-)%s*$") end

local function split(str, sep)
	local tbl = {}
	local before = 1
	for start, final in str:gmatch("()" .. sep .. "()") do
		tbl[#tbl + 1] = str:sub(before, start - 1)
		before = final
	end	
	tbl[#tbl + 1] = str:sub(before, str:len())
	return tbl
end

function p:build_sound(sound_name, input_sounds, category_name)
	-- Sometimes, the names can be just numbers.
	-- That will, of course, interfere with string manipulation.
	sound_name = tostring(sound_name)

	-- Sound names should already be trimmed.
	assert(sound_name == trim(sound_name))

	self.tree:add(split(sound_name, " "), sound_name)
	
	-- reuse existing list if we already have it (add to it!)
	local sounds = self.list[sound_name]
	if not sounds then 
		sounds = {}
		self.list[sound_name] = sounds
	end

	local size = #sounds

	for _, sound_obj in ipairs(input_sounds) do
		size = size + 1
		sound_obj.name = sound_name -- lil' convenience :D
		sound_obj.category = category_name
		sounds[size] = sound_obj
	end
end

function p:build_category(category, category_name)
	for sound_name, sounds in pairs(category) do
		self:build_sound(sound_name, sounds, category_name)
	end
end

--- Accepts Chatsounds' raw data structure
---@param data string[]
function p:build_raw(data)
	for category_name, category in pairs(data) do
		self:build_category(category, category_name)
	end
end

function p:reset()
	self.list = {}
	self.tree = csl_hashtree:new()
end
