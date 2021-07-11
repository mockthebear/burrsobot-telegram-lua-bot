local bansticker = {}

function bansticker.onStickerReceive(msg)
	if chats[msg.chat.id] then
		local del = false
		if chats[msg.chat.id].data.bansticker and chats[msg.chat.id].data.bansticker[msg.sticker.file_unique_id] then 
			deploy_deleteMessage(msg.chat.id, msg.message_id)
			del = true
		end
		if chats[msg.chat.id].data.banpack and chats[msg.chat.id].data.banpack[msg.sticker.set_name] then 
			deploy_deleteMessage(msg.chat.id, msg.message_id)
			del = true
		end
		if del and chats[msg.chat.id].data.banmsg then 
			say(chats[msg.chat.id].data.banmsg)
		end

		if msg.reply_to_message and msg.reply_to_message.from.id and (msg.sticker.file_unique_id == "AgADmwADuY2UHQ" or msg.sticker.file_unique_id == "AgADuBEAAvEIjwY") then 
            if isUserChatAdmin(msg.chat.id, msg.from.id)  then
				local ret = bot.restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, os.time() +50, false, false, false, false)
				if not ret.ok then 
					reply.html("Failed to mute "..formatUserHtml(msg.reply_to_message.from).." because: "..ret.description)
				else 
					local wut = reply.html("Muted "..formatUserHtml(msg.reply_to_message.from).." for 50 seconds.")
					scheduleEvent(6, function()
						bot.deleteMessage(wut.result.chat.id,wut.result.message_id)
					end)
					scheduleEvent(50, function()
						bot.restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, 0, true, true, true, true)
					end)
				end
			else 
				reply("You need to be admin to mute!")
			end
		end
	end
end

function bansticker.load()
	-- body
end

function bansticker.loadCommands()
	LoadCommand(nil, "bansticker" , MODE_CHATADMS, getModulePath().."/banpack.lua", 2, "Bane um sticker ou um pack. Use /bansticker *pack* para banir o pack inteiro.\n/bansticker msg \"nao pode\". para uma mensagem ao deletar"  )
end

function bansticker.loadTranslation()
    g_locale[LANG_US]["Bane um sticker ou um pack. Use /bansticker *pack* para banir o pack inteiro.\n/bansticker msg \"nao pode\". para uma mensagem ao deletar"] = "Reply using /bansticker to ban a single sticker or /bansticker pack to ban the whole pack.\nor /bansticker msg \"not allowed here\" to set a deletion message.\n/bansticker clear to delete all bans"
    g_locale[LANG_US]["Use assim: /bansticker msg \"Nao pode isso aqui jovem.\""] = "Use like that: /banpack msg \"this is not allowed here\""
    g_locale[LANG_US]["Lista limpa!"] = "Ban list cleared!"
    g_locale[LANG_US]["Sticker pack *%s* banido!"] = "Sticker pack *%s* banned!"
	g_locale[LANG_US]["Sticker pack *%s* desbanido!"] = "Sticker pack *%s* unbanned!"
	g_locale[LANG_US]["Sticker *%s* banido! Use */bansticker pack* para banir o pack inteiro."] = "Sticker *%s* banned! use */bansticker pack* to ban the whole pack."
	g_locale[LANG_US]["Sticker *%s* desbanido!"] = "Sticker *%s* unbanned."
	g_locale[LANG_US]["Use isso respondendo em um sticker."] = "Use this command replying in a sticker."
	g_locale[LANG_US]["Bane um sticker. Use /banpack pack para banir o pack inteiro.\n/banpack msg \"nao pode\". para uma mensagem ao deletar"] = "Bans a sticker. Use /banpack pack to ban the whole pack. and /banpack msg \"Not allowed!\" to set a custom message"
	
end


return bansticker