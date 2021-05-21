function OnCommand(msg, text, args)
	if not chats[msg.chat.id] then 
		reply(tr("default-chat-only"))
		return
	end

	local rulesMessage = ""
	if args[2] == 'clear' then 
		chats[msg.chat.id].data.rules = nil
		SaveChat(msg.chat.id)
		reply(tr("rules-clear"))
		return
	end
	if not args[2] then
		if not msg.reply_to_message then 
			reply(tr("rules-use-again"))
			return
		else 
			rulesMessage = entitiesToHTML(msg.reply_to_message)
		end
	else 
		rulesMessage = entitiesToHTML(msg)
		--Cut off the command
		rulesMessage = rulesMessage:gsub("/([a-zA-Z@]+)%s", "")
	end

	local oldRules = chats[msg.chat.id].data.rules
	chats[msg.chat.id].data.rules = rulesMessage
	local saidOk = say.html(tr("rules-set", chats[msg.chat.id].data.rules))
	if not saidOk.ok then 
		chats[msg.chat.id].data.rules = oldRules
		reply(tr("rules-error-setting", saidOk.description))
	end
	SaveChat(msg.chat.id)
end

