function OnCommand(msg, text, args)
	if not chats[msg.chat.id] then 
		reply.parallel(tr("default-chat-only"))
		return
	end


	if not args[2] or args[2] == 'help' then 
		nospam.renderSpamStatus(msg.chat.id)
		reply.parallel(tr("nospam-usage"))
		return
	end

	args[2] = collapse_command(args)

	if not chats[msg.chat.id]._tmp.spam then 
		chats[msg.chat.id]._tmp.spam = {}
	end

	if args[2] == "on" then
		chats[msg.chat.id].data.nospam = true
		chats[msg.chat.id]._tmp.spam = {}
		say("Spam protection ✅activated✅!")
		say_admin("Activated spam at "..(chats[msg.chat.id].title or "?"))
	
		local ret = bot.getChatMember(g_chatid,bot.id)
		local per = "_My permissions:_"
		per = per .. "\ncan *delete messages: "..(ret.result.can_delete_messages and "✅" or "❌!")  .."*"
		per = per .. "\ncan *restrict members: "..(ret.result.can_restrict_members and "✅" or "❌!")  .."*"

		
		reply.markdown(per)
		if not ret.result.can_delete_messages or not ret.result.can_restrict_members then
			say(tr("nospam-nopermissions"))
			say_admin("Active nospam fail at "..(chats[msg.chat.id].title or "?"))
		else
			say("Anti-Spam is on!")
			say_admin("Active nospam at "..(chats[msg.chat.id].title or "?"))
		end
	elseif args[2] == "rates" then
		local str = "Rates: \n"
		for i,b in pairs(chats[msg.chat.id]._tmp.spam) do
			local rate = nospam.calculate_rate(b)
			if rate > 0 then
				str = str .. '<a href="tg://user?id='..i..'">'..(b.first_name or 'user'..i)..'</a>'.." - ".. rate.."\n"
			end
		end

		say_html(str)
		
	elseif args[2] == "off" then
		chats[msg.chat.id].data.nospam = false
		chats[msg.chat.id]._tmp.spam = {}
		reply.markdown("Deactivated~")
	elseif args[2]:match("rate (%d+)") then
		local rate =  args[2]:match("rate (%d+)")
		chats[msg.chat.id]._tmp.spam = {}
		chats[msg.chat.id].data.maxSpamMessages = tonumber(rate)
		nospam.renderSpamStatus(msg.chat.id)
	elseif args[2]:match("time (%d+)") then
		local rate =  args[2]:match("time (%d+)")
		chats[msg.chat.id]._tmp.spam = {}
		chats[msg.chat.id].data.maxSpamTime = tonumber(rate)
		nospam.renderSpamStatus(msg.chat.id)
	elseif args[2]:match("action (.+)") then
		local action =  args[2]:match("action (.+)")
		if action == "ban" then 
			chats[msg.chat.id].data.actionSpam = "ban"
		elseif action == "mute" then
			chats[msg.chat.id].data.actionSpam = "mute"
		elseif action == "warn" then
			chats[msg.chat.id].data.actionSpam = "warn"
		elseif action == "lock" then
			chats[msg.chat.id].data.actionSpam = "lock"
		else 
			reply("Unknown action :/")
			return
		end
		chats[msg.chat.id]._tmp.spam = {}
		nospam.renderSpamStatus(msg.chat.id)
		
	end
	SaveChat(msg.chat.id)


	return true

end

