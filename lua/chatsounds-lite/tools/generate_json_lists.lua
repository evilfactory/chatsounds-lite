c = {}
L = {}

json = dofile("json.lua")

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

local list = {}

local currentList = ""

local meta = {
    __newindex = function(tbl, key, val)
        if list[currentList][key] == nil then
            list[currentList][key] = {}
        end
        
        for k, value in pairs(val) do
            table.insert(list[currentList][key], value)            
        end

    end
}

setmetatable(L, meta)

function c.StartList(l)
    list[l] = {}
    currentList = l

    print("started list: " .. l)
end

function c.EndList()

end


dofile("lists-send-merged.lua")
dofile("lists-nosend-merged.lua")


local file = io.open("lists.json", "w")

file:write(json.encode(list))

file:close(file)

