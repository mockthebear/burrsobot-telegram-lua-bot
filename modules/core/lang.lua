function OnCommand(msg, text, args)

	local langNames = ""
	local selected = 0
	for i,b in pairs(g_locale.langs) do 
		langNames = langNames .. b..", "
		if args[2] and (args[2]:lower() == i or args[2]:lower() == b) then 
			selected = i
		end
	end
	if args[2] and selected == 0 then 
		reply(tr("core-lang-nosuch", langNames))
		return
	end

	if not args[2] then 
		reply(tr("core-lang-avaliable", langNames))
		return
	end


	if msg.chat.type == "private" then
		local old = users[msg.from.id].lang
		users[msg.from.id].lang = selected
		g_lang = selected
		say.html(tr("core-lang-private", langName(users[msg.from.id].lang), langNames))
		SaveUser(msg.from.id)
	else
		if isUserChatAdmin(msg.chat.id, msg.from.id) then
			chats[msg.chat.id].data.lang = selected		
			g_lang = selected
			say.html(tr("core-lang-chat", langName(chats[msg.chat.id].data.lang), langNames))
			SaveChat(msg.chat.id)
		else 
			say.delete(tr("default-command-chatdmin"))
		end
	end
end

