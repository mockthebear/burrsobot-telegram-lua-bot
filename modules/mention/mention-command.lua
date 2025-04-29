function OnCommand(msg, text, args)
	local uname = msg.from.username
	if args[2] then 
		uname = uname:gsub("@", ""):lower()
	end
	if chats[msg.chat.id] then 
		if  mention.marked[msg.chat.id] and  mention.marked[msg.chat.id][uname] and # mention.marked[msg.chat.id][uname] > 0 then 
			local tt =  mention.marked[msg.chat.id][uname]
			local auxTT = tt[#tt]
			local endLine = #tt == 1 and "" or tr("\n*Ainda existem %d mençoes. Repita o comando para ve-las.*", #tt-1)
			local ret = bot.sendMessage(msg.chat.id ,tr("A menção mais recente é essa.")..endLine, "Markdown",true,false, auxTT[1])
			if ret.ok then
				if not ret.result.reply_to_message then 
					bot.editMessageText(msg.chat.id, ret.result.message_id, nil, tr("A menção foi apagada, quem te marcou foi @%s a o texto dizia:\n%s\n\n", auxTT[3], auxTT[2])..endLine)
				end
			else 
				local ret = bot.sendMessage(msg.chat.id, tr("A menção foi apagada, quem te marcou foi @%s a o texto dizia:\n`%s`\n\n", auxTT[3], auxTT[2])..endLine, "Markdown")
				if not ret.ok then 
					say(tr("A menção foi apagada, quem te marcou foi @%s a o texto dizia:\n`%s`\n\n", auxTT[3], auxTT[2])..endLine)
				end
			end
			tt[#tt] = nil
		else 
			local lastDT = os.time()-g_startup
		    local hour = math.floor(lastDT/3600)
		    local min =  math.floor( (lastDT%3600)/60 )
		    local plural = hour > 1 and "s" or ""
		    local plural2 = min > 1 and "s" or ""
			say(tr("Desculpe, nem uma menção a @%s na%s utima%s %d hora%s e %d minuto%s.", uname, plural,plural,hour,plural,min,plural2))
		end
	else 
		say(tr("Sorry, this cant be used here, only in group chats."))
	end
end