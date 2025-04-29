function OnCommand(msg, aaa, args)
	if not chats[msg.chat.id] then 
		say(tr("This only works on chats"))
		return
	end

	if not args[3] then 
		reply.parallel(tr("reply-usage"))
		return
	end
	
	local usr = getUserByUsername(args[2])

	if not usr or not users[usr.id] then
		reply.parallel(tr("Cant find this user"))
		return 
	end

	local from,to = msg.text:find(args[2])
	local text = msg.text:sub(to+2, -1)

	if text == 'stop' then 
		chats[msg.chat.id].data.reply = chats[msg.chat.id].data.reply or {}
		chats[msg.chat.id].data.reply[usr.id] = nil
		reply.html("Ok")
		SaveUser(usr.id)
		SaveChat(msg.chat.id)
		return
	end


	chats[msg.chat.id].data.reply = chats[msg.chat.id].data.reply or {}
	chats[msg.chat.id].data.reply[usr.id] = text
	reply.html(tr("Now every hour when %s say something I'll reply with:\n<code>%s</code>\nTo stop use /reply @user stop", formatUserHtml(usr), text:htmlFix()))
	SaveUser(usr.id)
	SaveChat(msg.chat.id)
	return
end