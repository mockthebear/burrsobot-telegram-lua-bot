function OnCommand(msg, text, args)
	if not msg.reply_to_message then 
		reply("Send this command replying to a message!")
		return
	end
	local m = msg.reply_to_message

	local str = "Elements:"
	for i,b in pairs(m) do 
		str = str .. "\n<b>"..i..""
		if type(b) == "table" then
			str = str .. "</b><code>"
			for a,c in pairs(b) do 
				str = str .. "\n		"..a.." = "..cjson.encode(c):htmlFix()..""
			end
			str = str .. "</code>"
		else 
			str = str .. " = "..tostring(b):htmlFix().."</b>"
		end
		str = str .. "\n----------------------------"
	end
	local sent = bot.sendMessage(g_chatid,str, "HTML" ,true,false,g_msg.message_id)
	if not sent or not sent.okj then 
		say.big(cjson.encode(m))
	end
end
