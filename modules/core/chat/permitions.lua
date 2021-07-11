function OnCommand(msg, text, args)
	if not chats[msg.chat.id] then 
		reply_parallel("Sorry, this command is for chats only")
		return
	end
	local ret = bot.getChatMember(g_chatid,bot.id)
	local per = "_My permissions:_"

	per = per .. "\ncan *promote members: "..(ret.result.can_promote_members and "✅" or "❌") .."*"
	per = per .. "\ncan *be edited: "..(ret.result.can_be_edited and "✅" or "❌") .."*"
	per = per .. "\ncan *pin messages: "..(ret.result.can_pin_messages and "✅" or "❌") .."*"
	per = per .. "\ncan *delete messages: "..(ret.result.can_delete_messages and "✅" or "❌!")  .."*"
	per = per .. "\ncan *restrict members: "..(ret.result.can_restrict_members and "✅" or "❌!")  .."*"
	if not ret.result.can_delete_messages or not ret.result.can_restrict_members then
		per = per .. "\n\n*! means its necessary for /botprotection or /noraid*"
	end
	per = per .. "\n\nStatus: *".. ret.result.status.."*"

	reply_markdown(per)
end
