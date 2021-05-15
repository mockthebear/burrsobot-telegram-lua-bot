function OnCommand(msg, text, args)
	if not chats[msg.chat.id] then 
		reply_parallel("Sorry, this command is for chats only")
		return
	end


	local ret = bot.getChatMember(g_chatid,bot.id)
	local per = tr("core-security-coms")

	if noraid then
		per = per .."\n▶️/noraid "..(chats[msg.chat.id].data.noraid  and (tr("core-security-active")) or tr("core-security-inactive")).. "\n➖<code>Enable anti raider check and black list</code>\n"
	end
	if antibot then
		per = per .."\n▶️/botprotection "..(chats[msg.chat.id].data.botProtection and tr("core-security-active") or tr("core-security-inactive")).. "\n➖<code>Check every time a user joins if he is a bot. If so, it must complete a captcha to stay in the chat</code>\n"
	end
	if antibot then
		per = per .."\n▶️/nomedia "..(chats[msg.chat.id].data.no_nudes  and tr("core-security-active") or tr("core-security-inactive")).. "\n➖<code>When a user join, he is restricted for 5 minutes to send media. (Necessary the /botprotection command to be on)</code>\n"
	end
	if nospam then
		per = per .."\n▶️/nospam "..(chats[msg.chat.id].data.nospam  and tr("core-security-active") or tr("core-security-inactive")).. "\n➖<code>Enable anti spam function</code>\n"
	end 
	per = per .. "\n".. tr("core-security-permissions").."\n\n"
	per = per .. tr("core-security-candel", (ret.result.can_delete_messages and "✅" or "❌!"))
	per = per .. tr("core-security-cankick", (ret.result.can_restrict_members and "✅" or "❌!"))


	if not ret.result.can_delete_messages or not ret.result.can_restrict_members then
		per = per .. tr("core-security-fail")
	end
		
	reply_html(per)
		

	return true

end

