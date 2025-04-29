if not lastWarnHere then 
	lastWarnHere = {}
end
function OnCommand(msg, text, args, targetChat)
	
	if targetChat ~= msg.chat.id then
		if chats[targetChat] then 
			local keyb = {}
			keyb[1] = {}
			keyb[1][1] = {text = "Portugues 🇧🇷", callback_data = "start:br" }
			keyb[1][2] = {text = "English 🇺🇸", callback_data = "start:us" }
			local kb = cjson.encode({inline_keyboard = keyb})
			bot.sendMessage(msg.chat.id, "*Authorized!!!*\n.\n.\n.\n.\n.\nIf you want to start using me...\nBefore that... Wich language do you use?\n\n*Oi, antes de começar, qual lingua você usa?*", "Markdown", true, false, nil, kb)
		end
		return
	end

	if not chats[msg.chat.id] then 
		reply_parallel("Sorry, this command is for chats only")
		return
	end

	if not chats[msg.chat.id].data.warnWords then 
		chats[msg.chat.id].data.warnWords = {}
	end

	if not args[2] or args[2]:len() <= 2 then 
		reply(tr("Por favor, use o comando assim:  /notifyme (keyword com pelo menos 3 letras)"))
		return
	end
	args[2] = args[2]:lower()
	local str = ""
	if not chats[msg.chat.id].data.warnWords[args[2]] then 
		chats[msg.chat.id].data.warnWords[args[2]] = {}
	end
	local lst = chats[msg.chat.id].data.warnWords[args[2]]
	if lst[msg.from.id] then 
		chats[msg.chat.id].data.warnWords[args[2]][msg.from.id] = nil
		str = str .. tr("Removido %s na lista de notificação.\n", formatUserHtml(msg))
	else
		chats[msg.chat.id].data.warnWords[args[2]][msg.from.id] = 1
		str = str .. tr("Adicionado %s na lista de notificação.\n", formatUserHtml(msg))
	end
	if not lastWarnHere[g_chatid] or lastWarnHere[g_chatid] < os.time() then
		str = str .. tr("\nÉ bom lembrar que existem outros 2 comandos:\n*/notifypurge , um para remover tudo\n */notifyinterval para definir intervalo minimo de avisos\n\n")
		lastWarnHere[g_chatid] = os.time() + 600
	end
	local kb = nil
	if not users[msg.from.id].private then 
		local keyb = {}
		keyb[1] = {}
		keyb[1][1] = { text = tr("Autorizar o bot mandar private"), url = "https://telegram.me/burrsobot?start="..g_chatid.."_notifyme"} 
		kb = cjson.encode({inline_keyboard = keyb })
		str = str .. tr("\nParece que você não autorizou ainda eu mandar privates pra você. Basta ir no private comigo e dar /start ou clicar no botão abaixo\n")
	end
	
	bot.sendMessage(g_chatid, str, "HTML", true, false, g_msg.message_id, kb)
	SaveChat(msg.chat.id)	
	SaveUser(msg.from.id)
end