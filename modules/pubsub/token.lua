function OnCommand(msg, text, attrs, targetChat)
	if targetChat ~= msg.chat.id then 
		pubsub.storePhoto(targetChat)
		local tok = pubsub.generateChatToken(targetChat, msg.from.id, msg.from.first_name)
		bot.sendMessage(msg.chat.id, "Access link:\n"..tok, "HTML")
	else
		local keyb = {}
	    keyb[1] = {}

	    keyb[1][1] = {text = tr("Get panel link"), callback_data = "panel:token" } 

	    local kb = cjson.encode({inline_keyboard = keyb})
	    pubsub.storePhoto(msg.chat.id)

	   bot.sendMessage(msg.chat.id, tr("Click to open chat panel (Admin only)"), "", true, false, msg.message_id, kb)
	end
end