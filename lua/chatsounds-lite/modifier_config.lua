local modifiers = {}


modifiers[1] = {
    mod = "!!",
    args = false,
    
    soundstart = function(snd, args)
        snd:SetVolume(6)
    end,

    think = function(snd, args)

    end,
}

modifiers[2] = {
    mod = "!",
    args = false,

    soundstart = function(snd, args)

        snd:SetVolume(2)
    end,

    think = function(snd, args)

    end,
}

modifiers[3] = {
    mod = "#",
    args = true,    

    soundstart = function(snd, args, q)
        local arg = tonumber(args)
        if arg == nil then return end
        if q.sounddata[arg] == nil then return end
        snd:SetPath(q.sounddata[arg].path)
        snd:SetLength(q.sounddata[arg].length)

    end,

    think = function(snd, args)

    end,

}

modifiers[4] = {
    mod = "*",
    args = true,    

    soundstart = function(snd, args)

    end,

    think = function(snd, args)

    end,

}


modifiers[5] = {
    mod = "%",
    args = true,
    
    soundstart = function(snd, args)
        if tonumber(args) == nil then return end
        snd:SetPitch(tonumber(args) / 100)
        snd:SetLength(snd.length / (tonumber(args) / 100))
    end,

    think = function(snd, args)

    end,

}

return modifiers