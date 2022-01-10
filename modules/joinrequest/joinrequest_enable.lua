function OnCommand(user, msg, args)
	if not chats[user.chat.id] then 
		say("This only works on chats")
		return
	end
	local old


	chats[user.chat.id].data.joinRequest = (not chats[user.chat.id].data.joinRequest) and true or false
	
	
	say.markdown(tr("joinrequests-active", chats[user.chat.id].data.joinRequest and tr("Ativada") or tr("Desativada")))

	SaveChat(user.chat.id) 
end

