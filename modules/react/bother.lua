function OnCommand(msg, aaa, args)
	if not chats[msg.chat.id] then 
		say(tr("This only works on chats"))
		return
	end

	if not args[2]  then 
		reply.html(tr("Use like:\n<code>/bother @username 🥰</code>\nOr use <code>/bother @username stop</code> to remove the reaction"))
		return 
	end

	local valid = {"👍", "👎", "❤", "🔥", "🥰", "👏", "😁", "🤔", "🤯", "😱", "🤬", "😢", "🎉", "🤩", "🤮", "💩", "🙏", "👌", "🕊", "🤡", "🥱", "🥴", "😍", "🐳", "❤‍🔥", "🌚", "🌭", "💯", "🤣", "⚡", "🍌", "🏆", "💔", "🤨", "😐", "🍓", "🍾", "💋", "🖕", "😈", "😴", "😭", "🤓", "👻", "👨‍💻", "👀", "🎃", "🙈", "😇", "😨", "🤝", "✍", "🤗", "🫡", "🎅", "🎄", "☃", "💅", "🤪", "🗿", "🆒", "💘", "🙉", "🦄", "😘", "💊", "🙊", "😎", "👾", "🤷‍♂", "🤷", "🤷‍♀", "😡"}
	local usr = getUserByUsername(args[2])

	local emoji = args[3]


	if not usr or not users[usr.id] then
		say.parallel(tr("Cant find this user"))
		return 
	end

	if emoji == 'stop' then 
		chats[msg.chat.id].data.bother = chats[msg.chat.id].data.bother or {}
		chats[msg.chat.id].data.bother[usr.id] = nil
		reply.html("Ok")
		SaveUser(usr.id)
		SaveChat(msg.chat.id)
		return
	end

	local valids = ""
	for a,c in pairs(valid) do 
		valids = valids .. c
		if c == emoji then  
			chats[msg.chat.id].data.bother = chats[msg.chat.id].data.bother or {}
			chats[msg.chat.id].data.bother[usr.id] = emoji
			reply.html(tr("Now every msg from %s will be reacted with %s.\nTo stop use <code>/bother @username stop</code>", formatUserHtml(usr), emoji))
			SaveUser(usr.id)
			SaveChat(msg.chat.id)
			return
		end
	end

	reply.html(tr("Emoji not valid.\nAvaliable: ")..valids)

end