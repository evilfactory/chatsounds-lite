--[[
local modifiers = { {mod="%%", args=false}, 
                    {mod="!!", args=false}, 
                    {mod="%", args=true}, 
                    {mod="!", args=false} }

--]] 

local function CleanString(str)
	return string.gsub(str, "%p", "%%%1")
end

local function ModifierFactory(modifiers)

	local function ParseModifier(str, initial)
		local initial = initial or {}

		if str == nil then
			return initial
		end

		for key, value in ipairs(modifiers) do

			local mod = value.mod
			local args = value.args

			local i = string.find(str, CleanString(mod))

			if i then
				str = str:gsub(CleanString(mod), "", 1)

				if args then

					local arg = ""

					for j = i, #str do
						local c = str:sub(j, j)

						local good = tonumber(c) ~= nil

						if not good and c ~= "." then
							break
						end

						arg = arg .. c
					end

					table.insert(initial, {
						mod = mod,
						soundstart = value.soundstart,
						think = value.think,
						arg = arg,
					})

				else
					table.insert(initial, {
						mod = mod,
						soundstart = value.soundstart,
						think = value.think,
					})
				end

				return ParseModifier(str, initial)
			end
        end
        

		return initial

    end
    

    function CreateModifiedSound(path, length)

        local snd = {}

        snd.path = path
        snd.volume = 1
        snd.pitch = 1
        snd.length = length

        function snd:SetPath(path)
            self.path = path
        end

        function snd:SetVolume(vol)
            self.volume = vol
        end

        function snd:SetPitch(pt)
            self.pitch = pt
        end

        function snd:SetLength(l)
            self.length = l
        end

        return snd

    end


	return ParseModifier, CreateModifiedSound

end

return ModifierFactory
