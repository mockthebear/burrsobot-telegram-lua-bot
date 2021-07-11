function OnCommand(msg, text, args)
	if not chats[msg.chat.id] then 
		reply(tr("default-chat-only"))
		return
	end
	if not msg.reply_to_message then 
		reply(tr("welcome-send-again-reply"))
		welcome.SendWelcomeAndValidate(msg, nil, tr("welcome-message-thisdefault"))
		return
	end

	local rollback = chats[msg.chat.id].data.welcome

	if msg.reply_to_message.text or args[2] then
		local welcome = ""
		if args[2] then 
			welcome = entitiesToHTML(msg)
			--Cut off the command
			welcome = welcome:gsub("^/([a-zA-Z@])%s", "", 1)
		else 
			welcome = entitiesToHTML(msg.reply_to_message)
		end
		chats[msg.chat.id].data.welcome = welcome
		say(tr("welcome-set-message"))
	elseif msg.reply_to_message.photo then
		chats[msg.chat.id].data.welcome = "IIMI:"..msg.reply_to_message.photo[1].file_id..":"..(entitiesToHTML(msg.reply_to_message) or "?")
		say(tr("welcome-set-image") )
	elseif msg.reply_to_message.sticker then
		chats[msg.chat.id].data.welcome = "STCKR:"..msg.reply_to_message.sticker.file_id
		say(tr("welcome-set-sticker"))
	elseif msg.reply_to_message.document then
		chats[msg.chat.id].data.welcome = "IIDI:"..msg.reply_to_message.document.file_id..":"..(entitiesToHTML(msg.reply_to_message) or "?")
		say(tr("welcome-set-document"))
	else
		reply("huh?")
	end

	--say(chats[msg.chat.id].data.welcome)

	local success, err = welcome.SendWelcomeAndValidate(msg, nil, "<b>---------TEST-----------</b>\n")
	if success then
		SaveChat(msg.chat.id) 
	else 
		chats[msg.chat.id].data.welcome = rollback
		reply(tr("welcome-set-error", err))
	end

	
end
