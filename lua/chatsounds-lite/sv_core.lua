util.AddNetworkString("chatsoundslite_server_avaiable") 
util.AddNetworkString("chatsoundslite_chat_message")

hook.Add("PlayerSay", "chatsoundslite_chat", function( ply, text )
    net.Start("chatsoundslite_chat_message")
    net.WriteEntity(ply) -- player
    net.WriteString(string.lower(text)) -- message
    net.WriteString(math.random(1000, 10000)) -- random seed
    net.Broadcast()
end)