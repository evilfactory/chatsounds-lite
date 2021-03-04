local p = dofile("scratches/project/parser/main.lua")

do -- tests
    dofile("scratches/pure-lua/debug-utils.lua")
	local parser
	do -- sound creation test
		local input = {
			category1 = {
				["very good"] = {
					{path = "a"}, -- sound1
					{path = "b"}, -- sound2
				},
				["good"] = {{path = "c"}},
			},
		}
		parser = p:new()
		parser:build(input)
	end

    do -- parsing test
        local function ipaired(lista, listb)
            local function iter(s, v)
                v = v + 1
                local val1 = lista[v]
                local val2 = listb[v]
                if not val1 or not val2 then return end
                return v, val1, val2
            end
            return iter, lista, 0
        end
		local sound_names, modifiers = parser:parse("good! good ! ! very good& & very! good")
        for i, a, b in ipaired(sound_names, modifiers) do
            print(("%d, %-10s, %-4s"):format(i, a, "'" .. b .. "'"))
        end
	end
end
