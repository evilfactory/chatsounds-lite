---@type CSL_Parser
local p = ...

local csl_htn_complete = dofile("chatsounds-lite/parser/hashtree/htn-complete.lua")

-- this works fairly well. use it.
-- "oh but why doesnt it use fancier regex stuff?"
-- because i want it to work with regex groups. that's why, you snob.
--- mind you, the sep will be thrown into a regex.
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

--- Splits a token into a word and a modifier.
local function parse_token(word)
	-- this baby will find the last alfanumeric character and cut it there.
	local start = word:find("[^%a%d]") or word:len() + 1
	return word:sub(1, start - 1), word:sub(start)
end

--- Returns paired lists of words and modifiers
--- trying to separate words from modifiers
--- and merging elements
local function first_pass(tokens)

	local words = {}
	local mods = {}

	for _, token in ipairs(tokens) do

		local word, mod = parse_token(token)
		--print(i, token, word, mod)
		local len = #words + 1
		
		-- add mod to previous element
		if word == "" then
			assert(mod ~= "")

			if len > 1 then  
				mods[len - 1] = mods[len - 1] .. mod
				mod = ""
			end
		else
			words[len] = word
			mods[len] = mod
		end
	end

	return words, mods
end
--- Adds empty elements after elements with tokens
local function second_pass(words, mods)

	-- this assertion is fine and all i guess
	assert(#words == #mods) -- it aint gonna hurt anybody.

	local new_words = {}
	local new_mods = {}

	for i = 1, #words do

		local len = #new_words + 1
		new_words[len] = words[i]
		new_mods[len] = mods[i]

		if mods[i] ~= "" then
			new_words[len + 1] = ""
			new_mods[len + 1] = ""
		end

	end

	return new_words, new_mods

end

--- Returns paired lists of sound_names and modifiers
---@param input string[]
---@return string[] sound_names
---@return string[] modifiers
function p:parse(input)
	local tokens = split(input, "%s+")
	
	local words, mods = second_pass(first_pass(tokens))

	local nav = csl_htn_complete:new()
	nav:parse(self.tree, words)

	local captures, modifiers = {}, {}

	for i, start, finish, str in nav:export() do
		captures[i] = str
		modifiers[i] = mods[finish]
	end
	return captures, modifiers
end



--- Returns list of end-nodes for suggestion
local function predict_nodes(self, sequence)
	local tree = self.tree
	
	-- constant for hashtree
	--
	-- one could argue it isnt best practice to implement an exterior module
	-- based on an interior one (hashtree), as if we were expected to know
	-- hashtree's implementation.
	--
	-- heres my answer: C has crazy null constants so why cant lua?
	-- https://ewontfix.com/11/ yes, it is crazy
	local NULL = true
	
	local len = #sequence

	local hashset = {}

	local function find_with(level_offset)
		local node = tree.map
		for level = level_offset, len do
			local value = sequence[level]
			node = node[value]
			if not node then return end
		end
		hashset[node] = true
	end

	for i = 1, len do
		find_with(i)
	end

	return hashset
end

--- Returns list of n values from child sequences of the nodes.
---@param self CSL_Parser
local function suggest(nodes, limit)
	local NULL = true

	local hashset = {}
	local n = 0

	limit = limit or 50

	local function collect(node)
		if n >= limit then return end
		for k, v in pairs(node) do
			if k == NULL then
				if not hashset[v] then
					n = n + 1
				end
				if n > limit then return end
				hashset[v] = true
			else
				collect(v)
			end
		end
	end

	for node, _ in pairs(nodes) do
		collect(node)
	end

	return hashset
end

--- Returns value suggestions
---@param input string[]
function p:predict(input, limit)
	local tokens = split(input, "%s+")
	local words = second_pass(first_pass(tokens))
	local nodes = predict_nodes(self, words)
	local suggestions = suggest(nodes, limit)
	return suggestions
end
