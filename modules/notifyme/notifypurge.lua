function OnCommand(msg, text, args, targetChat)
	if msg.chat.type == "private" then 
		reply_parallel("Sorry, this command is for chats only")
		return 
	end
	if msg.chat.type == "private" then 
		local rem = ""
		for a, chat in pairs(chats) do
			if chat.data.warnWords then
				for word, dat in pairs(chat[a].data.warnWords) do 
					if dat[msg.from.id] then 
						chat.data.warnWords[word] = nil
						rem = rem .. word .. " on chat "..chat.name.."\n"
					end
				end
			end
		end
		if rem == "" then 
			reply(tr("Você não tem nem uma keyword de aviso."))
		else
			reply(tr("Removido aviso das seguintes palavras:\n")..rem)
		end
	else
		if not chats[msg.chat.id].data.warnWords then 
			chats[msg.chat.id].data.warnWords = {}
		end

		if not chats[msg.chat.id].data.warnWords then 
			chats[msg.chat.id].data.warnWords = {}
		end
		local rem = ""
		for word, dat in pairs(chats[msg.chat.id].data.warnWords) do 
			if dat[msg.from.id] then 
				chats[msg.chat.id].data.warnWords[word] = nil
				rem = rem .. word .. "\n"
			end
		end
		if rem == "" then 
			reply(tr("Você não tem nem uma keyword de aviso."))
		else
			reply(tr("Removido aviso das seguintes palavras:\n")..rem)
		end
	end
	SaveChat(msg.chat.id)
end