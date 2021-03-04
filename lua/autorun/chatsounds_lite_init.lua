print("ChatsoundsLite!")

local function search(dir, func, path) 
    local path = path or "LUA" 
    local files, dirs = file.Find(dir .. "/*", path) 
    for i, v in ipairs(files) do 
        func(dir .. "/" .. v, v) 
    end 
    for i, v in ipairs(dirs) do
        if v ~= "tools" then 
			search(dir .. "/" .. v, func, path) 
		end
    end 
end

loadfile = CompileFile
dofile = include

chatsoundsLite = {}

if SERVER then 

    search("chatsounds-lite", function (file)
        print(file)
        AddCSLuaFile(file)
    end, "LUA")

    include("chatsounds-lite/sv_core.lua")

else
 
	include("chatsounds-lite/cl_core.lua")
	-- include("chatsounds-lite/autocomplete.lua")

end 