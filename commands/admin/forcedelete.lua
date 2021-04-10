function OnCommand(msg, aaa, args)
	if msg.reply_to_message then 
		if #chats[msg.chat.id].adms == 0 then
			cacheAdministrators(msg)
		end
		local adms = ""
		for i,b in pairs(chats[msg.chat.id].adms) do 
			adms = adms .. (type(i) == "string" and ("@"..i..", ") or "")
		end
		local ret = bot.deleteMessage(msg.chat.id, msg.reply_to_message.message_id)

		if not ret or not ret.ok then 
			say("Cannot delete that message.")
			return
		end
		local mdata = parseMessageDataToStr(msg.reply_to_message)
		bot.sendMessage(g_chatid,
		"Attention admins "..adms.."\nThe user @"..msg.from.username.." deleted the message "..msg.reply_to_message.message_id.."!\n\nMessage data:\n"..mdata, "HTML")
	else 
		say("Reply to a valid msg")
	end
end