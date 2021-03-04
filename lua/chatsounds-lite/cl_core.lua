
-- host the lists yourself or use my current hosted one
chatsoundsLite.soundListURL = "http://evilfactory.tk/nuvem/lists.json"

chatsoundsLite.soundURL =
	"https://raw.githubusercontent.com/Metastruct/garrysmod-chatsounds/master/sound/"

---@class CSL_Parser
chatsoundsLite.parser = chatsoundsLite.parser or
                        	include("chatsounds-lite/parser/main.lua"):new()

chatsoundsLite.modifiers = include("chatsounds-lite/modifier_config.lua")

chatsoundsLite.ParseModifier, chatsoundsLite.CreateModifiedSound =
	include("chatsounds-lite/modifier.lua")(chatsoundsLite.modifiers)

chatsoundsLite.client_only = true

chatsoundsLite.soundQueues = {}

function chatsoundsLite.GetLists(cache)
	cache = cache or false

	if cache and chatsoundsLite.listTXT then
		print("ChatsoundsLite: List cached, ignoring")
		return
	end

	http.Fetch(chatsoundsLite.soundListURL, function(body, length, headers, code)

		chatsoundsLite.listTXT = body

		print("ChatsoundsLite: Loading list!")

		local list = util.JSONToTable(chatsoundsLite.listTXT)

		chatsoundsLite.parser:build_raw(list)

		print("ChatsoundsLite: List Loaded! Length: " .. #chatsoundsLite.listTXT)

	end)
end

function chatsoundsLite.TryServer()
	net.Start("chatsoundslite_server_avaiable")
	net.SendToServer()
end

function chatsoundsLite.AddSoundToQueue(ply, sound, modifier, randomseed)
	
	chatsoundsLite.soundQueues[randomseed] = chatsoundsLite.soundQueues[randomseed] or {}

	table.insert(chatsoundsLite.soundQueues[randomseed], {
		sounddata = sound,
		modifiers = modifier,
		started = false,
        randomseed = randomseed,
        ply = ply
	})

end

function chatsoundsLite.NextSoundQueue(id)
	table.remove(chatsoundsLite.soundQueues[id], 1)
	
	if #chatsoundsLite.soundQueues[id] == 0 then
		chatsoundsLite.soundQueues[id] = nil
	end
end

function chatsoundsLite.PlayMessage(ply, message, randomseed)
	local result, modifiers = chatsoundsLite.parser:parse(message)

	for key, value in ipairs(result) do
		chatsoundsLite.AddSoundToQueue(ply, chatsoundsLite.parser.list[result[key]],
                               		chatsoundsLite.ParseModifier(modifiers[key]),
                               		randomseed)
	end
end

function chatsoundsLite.ProcessQueue(soundid)
	local queue = chatsoundsLite.soundQueues[soundid]
	local q = queue[1]

	if q == nil then
		return
	end

	if q.started == false then

		local rnd = math.floor(util.SharedRandom(q.randomseed, 1, #q.sounddata))

		local defaultsnd = q.sounddata[rnd]

		q.sound = chatsoundsLite.CreateModifiedSound(defaultsnd.path, defaultsnd.length)

		for key, value in pairs(q.modifiers) do

			value.soundstart(q.sound, value.arg, q)

		end

		sound.PlayFile("sound/" .. q.sound.path, "3d", function(s, err)

              
            if err then

                sound.PlayURL(chatsoundsLite.soundURL .. q.sound.path, "3d noplay", function(station)
					if not IsValid(station) then
                        chatsoundsLite.NextSoundQueue(soundid)
                        return
                    end
                    
                    q.station = station

                    station:SetVolume(q.sound.volume)
                    station:SetPlaybackRate(q.sound.pitch)

                    station:Play()

                    q.playStart = CurTime()
                end)
                

			else
                
                sound.PlayFile("sound/" .. q.sound.path, "3d noplay", function(station)
                    if not IsValid(station) then
                        chatsoundsLite.NextSoundQueue(soundid)
                        return
                    end  
 
                    q.station = station   

                    station:SetVolume(q.sound.volume)
                    station:SetPlaybackRate(q.sound.pitch)
                    
                    station:Play()

                    q.playStart = CurTime()
                end) 

			end

		end)

		q.started = true

	else

        if not q.station then return end

        q.station:SetPos(q.ply:GetPos()) 

        if not q.playStart then return end

        q.station:SetVolume(q.sound.volume)
        q.station:SetPlaybackRate(q.sound.pitch)

        if CurTime() > q.playStart + q.sound.length then
			chatsoundsLite.NextSoundQueue(soundid)			
        end
 
	end
end

if pcall(chatsoundsLite.TryServer) then
	print("ChatsoundsLite: Server avaiable!")

	chatsoundsLite.client_only = false
else
	print("ChatsoundsLite: Server not available! fallbacking to client-only")

	chatsoundsLite.client_only = true
end

if chatsoundsLite.client_only then

	hook.Add("OnPlayerChat", "chatsoundslite_chat",
         	function(ply, text, bTeam, bDead)
		text = string.lower(text)
		chatsoundsLite.PlayMessage(ply, text, math.random(1000, 10000))
	end)

else -- server accepted the deal, now he works for us

	net.Receive("chatsoundslite_chat_message", function()
		local ply = net.ReadEntity()
		local msg = net.ReadString()
		local randomseed = net.ReadString()

		chatsoundsLite.PlayMessage(ply, msg, randomseed)
	end)

end

concommand.Add("chatsoundslite_updatelists", function(ply, cmd, args, str)
	chatsoundsLite.GetLists(true)
end)

hook.Add("Think", "chatsoundslite_queue_think", function()
	for key, value in pairs(chatsoundsLite.soundQueues) do
		chatsoundsLite.ProcessQueue(key)
	end
end)


chatsoundsLite.GetLists(true)
