function OnCommand(msg, aaa, args, targetChat)
	--If used trought another call
	if targetChat ~= msg.chat.id then
		if chats[targetChat] and chats[targetChat].data.rules then
			local JSON = require("JSON")
			local keyb = {}
			keyb[1] = {}
			keyb[1][1] = { text = "Start bot", url = "https://telegram.me/"..g_botname.."?start=start"} 
			kb = JSON:encode({inline_keyboard = keyb })
			local ret = bot.sendMessage(msg.chat.id,tr("rules-rules-button").." <b>"..chats[targetChat].title.."</b>\n"..chats[targetChat].data.rules , "HTML",true,false, nil, kb)
			if not ret.ok then 
				say.admin("error on rules of "..targetChat.." due: "..ret.description)
				bot.sendMessage(msg.chat.id,tr("rules-rules-button").." *"..chats[targetChat].title.."*\n"..chats[targetChat].data.rules , "",true,false, nil, kb)
			end
		else 
			local ret = bot.sendMessage(msg.chat.id, tr("rules-norules"), "HTML",true,false, nil)
			if not ret.ok then 
				--bot.sendMessage(msg.chat.id,aux, "",true,false, nil)
			end
		end
		return
	end


	if chats[msg.chat.id] then
		if chats[msg.chat.id].data.rules then 
			if chats[msg.chat.id].data.rulesPvt then
				local keyb = {}
				keyb[1] = {}
				keyb[1][1] = { text = tr("rules-rules-button"), url = "https://telegram.me/"..g_botname.."?start="..targetChat.."_rules"} 
				local JSON = require("JSON")
				local kb = JSON:encode({inline_keyboard = keyb })
				bot.sendMessage(g_chatid, tr("rules-click"), nil, true, false, nil, kb)
			else
				reply.html(chats[msg.chat.id].data.rules)
			end
		else 
			reply(tr("rules-no-rules-set"))
		end
	else 
		reply(tr("default-chat-only"))
	end
end