function OnCommand(msg, aaa, args)
	if not chats[msg.chat.id] then 
		say("This only works on chats")
		return
	end

	if not args[2] and not msg.reply_to_message then 
		say("Use like:\n/botcheck @username\n/botcheck 33872  (user id)\nOr reply a message the USER SENT with this command.")
		return 
	end

	local usr = getTargetUser(msg, true)


	if not usr or not users[usr.id] then
		say.parallel("Cant find this user")
		return 
	end
	local cm = bot.getChatMember(g_chatid, usr.id)
	if cm.ok then 
		antibot.forceBotCheck(msg, tr("ordens do adm"))
	else 
		say.parallel("Cant find userid "..lid)
		return 
	end
end