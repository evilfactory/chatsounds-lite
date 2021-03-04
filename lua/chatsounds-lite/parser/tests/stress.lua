-- #region start

print("what the fuck")
local cslp = dofile("scratches/project/parser/main.lua")
local ht = dofile([[scratches\project\parser\hashtree\hashtree.lua]])
local htnc = dofile([[scratches\project\parser\hashtree\htn-complete.lua]])

---@class Clock
local clock = {}
clock.num = 0
---@return Clock
function clock:new() return setmetatable({}, {__index = self}) end
function clock:start()
    self.num = self.num + 1
    self.current = os.clock()
end
function clock:stop()
    local num = os.clock()
    self[self.num] = num - self.current
end

-- #endregion

--[=[
do -- tests with hashtree
    dofile("scratches/pure-lua/debug-utils.lua")
    math.randomseed(os.time())
    
    local function gen_sequence(size)
        local seq = {}
        for i = 1, size do
            seq[i] = string.char(math.random(0, 25) + 97)
        end
        return seq
    end
    
    local function gen_all_seq(n, min, max)
        min = min or 1
        max = max or 10
        local sequences = {}
        for i = 1, n do
            sequences[i] = gen_sequence(math.random(min, max))
        end
        return sequences
    end

    local c = clock:new()

    print("start")
    
    -- prebuilt
    c:start()
    local prebuilts = gen_all_seq(100000, 5, 20)
    c:stop()
    print(c[#c], "generate prebuilts")

    -- build tree
    local tree = ht:new()
    c:start()
    for i, v in ipairs(prebuilts) do
        tree:add(v, true)
    end
    c:stop()
    --prebuilts = nil
    print(c[#c], "build tree")

    -- messages
    c:start()
    local sequences = gen_all_seq(1000, 1, 300)
    c:stop()
    print(c[#c], "generate messages")

    -- parse
    local nav = htnc:new()
    c:start()
    for _, v in ipairs(sequences) do
        nav:parse(tree, v)
    end
    c:stop()
    --tree = nil
    print(c[#c], "parse")

    

    -- export
    c:start()
    local results = {}
    for i, start, finish, msg in nav:export() do
        --print(i, start, finish, msg)
        results[i] = msg
    end
    c:stop()
    print(c[#c], "export")
    
    
    for _, v in ipairs(results) do
        --print(v)
    end
end
--]=]

---[=[
do -- tests with hashtree
    dofile("scratches/pure-lua/debug-utils.lua")
    math.randomseed(os.time())
    
    -- #region common

    local function gen_string(size)
        local str = ""
        for i = 1, size do
            str = str .. string.char(math.random(0, 25) + 97)
        end
        return str
    end

    local function gen_sequence(n, size)
        local seq = {}
        for i = 1, n do
            seq[i] = gen_string(size)
        end
        return seq
    end

    local function gen_sequence_str(n, size)
        local str = ""
        for i = 1, n do
            str = str .. " " .. gen_string(size)
        end
        return str
    end
    
    local function gen_all_seq(n, min, max, variation)
        min = min or 1
        max = max or 10
        variation = variation or 2
        local sequences = {}
        for i = 1, n do
            sequences[i] = gen_sequence(math.random(min, max), variation)
        end
        return sequences
    end

    local function gen_all_seq_str(n, min, max, variation)
        min = min or 1
        max = max or 10
        variation = variation or 2
        local sequences = {}
        for i = 1, n do
            sequences[i] = gen_sequence_str(math.random(min, max), variation)
        end
        return sequences
    end

    local c = clock:new()

    -- #endregion
    -- #region build

    print("start")
    
    -- prebuilt
    c:start()
    local prebuilts = gen_all_seq_str(50000/1000, 5, 15, 2)
    c:stop()
    print(c[#c], "generate prebuilts")

    local pbp = {}
    do
        for i, v in ipairs(prebuilts) do
            pbp[v] = {{path="a", length=0, name="not your business."}}
        end
    end
    pbp = {cat1 = pbp}

    -- build
    local parser = cslp:new()
    c:start()
    parser:build(pbp)
    c:stop()
    --prebuilts = nil
    print(c[#c], "build tree")

    -- #endregion
    -- #region parse

    -- messages
    c:start()
    local sequences = gen_all_seq_str(1000/100, 1, 300, 2)
    c:stop()
    print(c[#c], "generate messages")

    -- parse
    c:start()
    for _, v in ipairs(sequences) do
        parser:parse(v)
    end
    c:stop()
    --tree = nil
    print(c[#c], "parse")

    -- #endregion
    -- #region finalize

    -- export
    c:start()
    local results = {}
    --for i, start, finish, msg in nav:export() do
        --print(i, start, finish, msg)
        --results[i] = msg
    --end
    c:stop()
    print(c[#c], "export")
    
    -- #endregion
end
--]=]
