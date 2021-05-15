function OnCommand(user, msg, args)
	if not chats[user.chat.id] then 
		say("This only works on chats")
		return
	end
	local old
	--
	if args[2] and args[2]:find("easy") then 
		old = chats[user.chat.id].data.easyBot
		chats[user.chat.id].data.easyBot = (not old) and true or nil
		chats[user.chat.id].data.botProtection = true
		say("easy check is "..(chats[user.chat.id].data.easyBot and "enabled" or "disabled").."!")
	elseif args[2] and args[2]:find("nomedia") then 
		old = chats[user.chat.id].data.no_nudes
		chats[user.chat.id].data.no_nudes = (not old) and 1 or nil
		say("nomedia check is "..(chats[user.chat.id].data.no_nudes and "enabled" or "disabled").."!")
	elseif args[2] and args[2]:find("enforce") then 
		old = chats[user.chat.id].data.botEnforced
		chats[user.chat.id].data.botEnforced = (not old) and true or nil
		chats[user.chat.id].data.botProtection = true
		say("enforced check is "..(chats[user.chat.id].data.botEnforced and "enabled" or "disabled").."!")
	elseif args[2] and args[2]:find("superbot") then 
		old = chats[user.chat.id].data.superBot
		chats[user.chat.id].data.superBot = (not old) and true or nil
		chats[user.chat.id].data.botProtection = true
		say("superBot check is "..(chats[user.chat.id].data.superBot and "enabled" or "disabled").."!")
	else
		chats[user.chat.id].data.botProtection = (not chats[user.chat.id].data.botProtection) and true or false
	end
	
	say_markdown(tr("Agora a bot protection está: *%s*", chats[user.chat.id].data.botProtection and tr("Ativada") or tr("Desativada")).."\nEnforced is *"..(chats[user.chat.id].data.botEnforced and "on" or "off").."*\nEasy mode is *"..(chats[user.chat.id].data.easyBot and "on" or "off").."*")
	if chats[user.chat.id].data.botProtection then 
		say("If you want to check this on every user who joins, use /botprotection enforce\nTo check on someone, use:/botcheck username/userid\n\nTo allow easy bot check (single click) use: /botprotection easy")
	end
	SaveChat(user.chat.id) 
end

