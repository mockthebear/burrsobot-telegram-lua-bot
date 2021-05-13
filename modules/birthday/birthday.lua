local birthday = {
	priority = DEFAULT_PRIORITY,
}

--[ONCE] runs when the load is finished
function birthday.load()

end

--[ONCE] runs when eveything is ready
function birthday.ready()

end

--Runs at the begin of the frame
function birthday.frame()

end

--Runs some times
function birthday.save()

end


function birthday.revertbd(chatid)
	if chats[chatid] and chats[chatid].data.birthday then
		local f = io.open("../cache/chatphoto-"..chatid..".jpg", "r")
		if not f then 
			return
		end	
		f:close()
		bot.deleteChatPhoto(chatid)
		bot.setChatPhoto(chatid, "../cache/chatphoto-"..chatid..".jpg")
		bot.unpinChatMessage(chatid, chats[chatid].data.birthday_pinned)
		chats[chatid].data.birthday = nil
		chats[chatid].data.birthday_pinned = nil
		SaveChat(chatid)
		
		return true
	end
end
function birthday.congratulations_congratulations_congratulations_congratulations(chat, id)
    if users[id] then
    	local f = io.open("../cache/chatphoto-"..chat..".jpg", "r")
		if not f then 
			local chatData = bot.getChat(chat)
			if not chatData or not chatData.result or not chatData.result.photo then 
				say("error")
				return false
			end	
			local ret = bot.downloadFile(chatData.result.photo.big_file_id or chatData.result.photo.small_file_id, "../cache/chatphoto-"..chat..".jpg")
		else 
			f:close()
		end
		

        local uid = users[id].telegramid
        if not uid then 
            say("Failed to get user id.")
            return false
        end
        local res = bot.getUserProfilePhotos(id, 0, 1)
        if res and res.ok then 
            if res.result.total_count == 0 then 
                say.html(tr("bd-nophoto"))
                local rete = say.html(tr("bd-bd", formatUserHtml(users[id])))
                if rete.ok then 
                    local msgid = rete.result.message_id
                    bot.pinChatMessage(chat, msgid)
                    return msgid
                end
                return false
            end
            local ibgs = res.result.photos[1]
            local image = ibgs[#ibgs]
            local ret = bot.downloadFile(image.file_id, "bg.jpg")
            if ret.success then 
                bot.setChatPhoto(chat, "bg.jpg")
                local rete = say.html(tr("bd-bd", formatUserHtml(users[id])))
                if rete.ok then 
                    local msgid = rete.result.message_id
                    bot.pinChatMessage(chat, msgid)
                    return msgid
                end
            else 
                say(tr("bd-failed-user-photo"))
            end
        else 
            say(tr("bd-failed-user-photo"))
        end
        
    else    
        say(tr("bd-failed-user"))
    end
end


function birthday.onDay()
	for i,b in pairs(chats) do 
		if birthday.revertbd(i) then 
			g_chatid = i
			g_lang = b.lang or b.data.lang or LANG_US
			say(tr("bd-reverted-auto"))
		end
	end
end
function birthday.onNewChatPhoto(msg)
	if msg.from.is_bot then 
		return
	end
	if msg.new_chat_photo then
		local fid = msg.new_chat_photo[3].file_id
		local ret = bot.downloadFile(fid, "../cache/chatphoto-"..msg.chat.id..".jpg")
		if not ret or not ret.success then
			reply.delete("Photo saved~")
		end
	end
end

function birthday.loadCommands()
	addCommand( "bd"						, MODE_CHATADMS, getModulePath().."/bd.lua", 2 , "bd-desc")
	addCommand( "revertbd"					, MODE_CHATADMS, getModulePath().."/revertbd.lua", 2 , "bd-r-desc"  )
end

function birthday.loadTranslation()

	g_locale[LANG_US]["bd-desc"] = "Announces someones birthday. Use like /bd @username or replying ot a user message. This will change the profile picture of the chat and pin a message. Changes are undone at midnight"
	g_locale[LANG_BR]["bd-desc"] = "Anuncia o aniver'sario de alguem. Use assim: /bd @username ou respondendo a mensagem de alguem. Isso vai mudar a foto do grupo e vai fixar uma mensagem. As mudanças serão desfeitas meia noite."

	g_locale[LANG_US]["bd-r-desc"] = "Undo what /bd does"
	g_locale[LANG_BR]["bd-r-desc"] = "Desfaz o /bd"

	g_locale[LANG_US]["bd-reverted"] = "BD reverted~"
	g_locale[LANG_BR]["bd-reverted"] = "Revertido o BD"

	g_locale[LANG_US]["bd-reverted-auto"] = "BD reverted automatically~"
	g_locale[LANG_BR]["bd-reverted-auto"] = "Revertido o BD automaticamente"


	g_locale[LANG_US]["bd-failed-user-photo"] = "Failed to get user photo"
	g_locale[LANG_BR]["bd-failed-user-photo"] = "Falha ao baixar foto do usuário"

	g_locale[LANG_US]["bd-failed-user"] = "Não encontrei o usuário"
	g_locale[LANG_BR]["bd-failed-user"] = "Não encontrei o usuário"

	g_locale[LANG_US]["bd-bd"] = "OH MY GOSH ITS %s's birthday!!!!!"
	g_locale[LANG_BR]["bd-bd"] = "AI MEU DESU É ANIVERSÁRIO DE %s"

	g_locale[LANG_US]["bd-nophoto"] = "Cannot access user profile pic. He or her need to send a /start on private with me. Sorry its telegram rules."
	g_locale[LANG_BR]["bd-nophoto"] = "Não foi possivel acessar foto do usuário, ele precisa ir no privado e dar /start comigo. Desculpa, o telegram é assim"
end


return birthday


	