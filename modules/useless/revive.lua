function OnCommand(msg, text, args)
	local c = math.random(1, msg.message_id)
		
	if args[2] and tonumber(args[2]) then
		c = tonumber(args[2])
	end
	say("Revivendo uma mensagem ("..c.."):")
	local ret = bot.sendMessage(msg.chat.id,"Essa.",nil,true,false,c)
	if not ret.ok then 
		say("faiou msg id "..c )
	end
end

