function OnCommand(msg)
    if msg.chat.type == "private" then 
    	local ret = bot.sendDocument(msg.chat.id, "/var/lib/redis/dump.rdb", "Redis backup")

    	reply("Res:"..cjson.encode(ret))
    end
end

--