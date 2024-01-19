function OnCommand(msg, text, args)
	if not chats[msg.chat.id] then 
		reply_parallel("Sorry, this command is for chats only")
		return
	end



	
	if  not chats[msg.chat.id].data.joinlock then 
		chats[msg.chat.id].data.joinlock = true
		say("Joinlock protection ✅activated✅!")
		say.admin("Activated joinlock at "..(chats[msg.chat.id].data.title or chats[msg.chat.id].title or msg.chat.id))
	else 
		chats[msg.chat.id].data.joinlock = false
		say("Joinlock protection ❌deactivated❌!")
		say.admin("Deactivated joinlock at "..(chats[msg.chat.id].data.title or chats[msg.chat.id].title or msg.chat.id))
	end
	SaveChat(msg.chat.id)
	if chats[msg.chat.id].data.joinlock == true then
		local ret = bot.getChatMember(g_chatid,bot.id)
		local per = "_My permissions:_"
		per = per .. "\ncan *delete messages: "..(ret.result.can_delete_messages and "✅" or "❌!")  .."*"
		per = per .. "\ncan *restrict members: "..(ret.result.can_restrict_members and "✅" or "❌!")  .."*"

		
		reply_markdown(per)
		if not ret.result.can_delete_messages or not ret.result.can_restrict_members then
			say("Cannot fully activate Joinlock because i dont have enought permissions. I need to be able to restrict and delete messages. Can use to check permitions /permitions")
			say.admin("Active fail at "..(chats[msg.chat.id].data.title or msg.chat.id))
			chats[msg.chat.id].data.joinlock = false
			say("Joinlock protection ❌deactivated❌!")
		end
	end


	return true

end

