function OnCommand(msg, text, args)
	if args[2] then 
		args[2] = args[2]:lower()
		if args[2]:find("on") then 
			chats[msg.chat.id].data.dolog = true
			reply(tr("Agora todas as mensagens serão salvadas."))
		elseif args[2]:find("off") then 
			chats[msg.chat.id].data.dolog = true
			reply(tr("Nem uma mensagem será salva mais."))
		elseif args[2]:find("erase") then 
			chats[msg.chat.id].data.lastDelete = os.time()
			os.execute("rm logs/"..msg.chat.id..".txt")
			reply(tr("Log excluido."))
		elseif args[2]:find("get") and not args[2]:find("pget") then 
			reply(tr("Enviando log"))
			bot.sendDocument(g_chatid, "logs/"..msg.chat.id..".txt", chats[g_chatid].title.." Log!"..(chats[msg.chat.id].data.lastDelete and ("Utimo delete "..chats[msg.chat.id].data.lastDelete) or ""))
		elseif args[2]:find("pget") then 
			reply(tr("Enviando log"))
			local ret = bot.sendDocument(msg.from.id, "logs/"..msg.chat.id..".txt", chats[g_chatid].title.." Log!")
			if not ret.ok then 
				reply_parallel(ret.description.."\nMaybe you have to go one time in private with me?")
			end
		else 
			reply(tr("core-logger-desc"))
		end
	else 
		reply(tr("core-logger-desc"))
	end
end

