function OnCommand(msg, text, args)
	if not chats[msg.chat.id] then 
		reply_parallel("This command is for groupchats only")
		return
	end

	if args[2] == 'enforce' then
		chats[msg.chat.id].data.noraid = 2
		say("No direct media protection ✅activated and enforced✅!")
	else
		if not chats[msg.chat.id].data.no_nudes ~= 1 then 
			chats[msg.chat.id].data.no_nudes = 1
			say("No direct media protection ✅activated✅!")
		else 
			chats[msg.chat.id].data.no_nudes = 0
			say("No direct media protection ❌deactivated❌!")
		end
	end
	SaveChat(msg.chat.id)
	if chats[msg.chat.id].data.no_nudes then
		local ret = bot.getChatMember(g_chatid,bot.id)
		local per = "_My permissions:_"
		per = per .. "\ncan *delete messages: "..(ret.result.can_delete_messages and "✅" or "❌!")  .."*"
		per = per .. "\ncan *restrict members: "..(ret.result.can_restrict_members and "✅" or "❌!")  .."*"

		
		reply_markdown(per)
		if not ret.result.can_delete_messages or not ret.result.can_restrict_members then
			say("Cannot fully activate direct media system because I dont have enought permissions. I need to be able to restrict and delete messages. Can use to check permitions /permitions")
		else
			say("Fully working now.")
		end
	end


	return true

end

