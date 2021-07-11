local joinlock = {
	inside_lockeds = {},
	priority = DEFAULT_PRIORITY - 1000150,
}
local cjson = require("cjson")
--[ONCE] runs when the load is finished
function joinlock.load()
	if pubsub then
				
		pubsub.registerExternalVariable("chat", "joinlock", {type="boolean"}, true, "Enable Join Lock", "General")
	end
	--
	if core then  
		--core.addStartOption("Anti raid", "*grr*", "joinlock", function() return tr("joinlock-start-desc") end )
	end
end

--[ONCE] runs when eveything is ready
function joinlock.ready()

end

--Runs at the begin of the frame
function joinlock.frame()

end


function joinlock.onPhotoReceive(msg)
	return joinlock.checkUserMessage(msg, true)
end

function joinlock.onDocumentReceive(msg)
	return joinlock.checkUserMessage(msg, true)
end


function joinlock.onAudioReceive(msg)
	return joinlock.checkUserMessage(msg, false)
end

function joinlock.onStickerReceive(msg)
	return joinlock.checkUserMessage(msg, false)
end
 
function joinlock.onTextReceive(msg)
	return  joinlock.checkUserMessage(msg, false)

end

function joinlock.checkUserMessage(msg, countMessage)
	if msg.isChat then

		local chatMain = chats[msg.chat.id]
		local chatObj = chats[msg.chat.id].data
		local enabled = chatObj.joinlock 

		if enabled then
			if joinlock.inside_lockeds[msg.from.id] then 
				bot.deleteMessage(msg.chat.id, msg.message_id)
				return  KILL_EXECUTION
			end
		end
	end
	return nil, false
end

--Runs some times
function joinlock.onNewChatParticipant(msg)
	if msg.isChat then
		local chatObj = chats[msg.chat.id].data
		local enabled = chatObj.joinlock 
		if enabled then
			joinlock.inside_lockeds[msg.new_chat_participant.id] = true
			bot.restrictChatMember(msg.chat.id, msg.new_chat_participant.id, -1, false, false, false, false)

			local adms = ""

			for i,b in pairs(chats[g_chatid]._tmp.adms) do 
				if i ~= g_id and i > 1000 then
					if users[i] then 
						adms = adms ..formatUserHtml({from=users[i] }).." "
					else 
						adms = adms ..formatUserHtml({from={id=i, first_name="Admin "..i} }).." "
					end
				end
			end
			

			local keyb = {}
		    keyb[1] = {}

		    keyb[1][1] = { text = tr("joinlock-release"), callback_data = "joinlock:release:"..msg.new_chat_participant.id..":"..msg.chat.id} 


		    local kb = cjson.encode({inline_keyboard = keyb })

		    bot.sendMessage(msg.chat.id, tr("joinlock-message", formatUserHtml(msg.new_chat_participant), adms) , "HTML", true, false, msg.message_id, kb)

			return  KILL_EXECUTION
		end
	end
end


function joinlock.onCallbackQueryReceive(msg)
	if msg.message then
		if msg.data:match("joinlock:release:(%d+):([%d%-]+)") then
			local id, chat = msg.data:match("joinlock:release:(%d+):([%d%-]+)")
			chat = tonumber(chat)
			id = tonumber(id)
			if chats[chat] and isUserChatAdmin(chat, msg.from.id) or isUserBotAdmin(msg.from.id)  then
				deploy_answerCallbackQuery(msg.id, "Released~", "true")
				
				bot.restrictChatMember(chat, id, -1, true, true, true, true)

				deploy_deleteMessage(chat, msg.message.message_id)

				if joinlock.inside_lockeds[id] then
					joinlock.inside_lockeds[id] = nil
					if not chats[chat].data.disable_welcome then
						msg.chat = {
							id = chat
						}
						msg.from.id = id
						msg.from.first_name = users[id].first_name or "?"
						msg.from.username = users[id].username
						msg.message_id = nil

						welcome.sendWelcomeMessage(msg)
					end
				end

			else 
				if msg.from.id == id then 
					bot.answerCallbackQuery(msg.id, tr("joinlock-no-u"), "true")
				else 
					bot.answerCallbackQuery(msg.id, tr("joinlock-onlyadm"), "true")
				end
			end

		end
	end
end


function joinlock.loadTranslation()
	g_locale[LANG_US]["joinlock-command-helper"] = "Make users be locked upon joining until an admin releases it."
	g_locale[LANG_BR]["joinlock-command-helper"] = "Faz novos usuários ficarem bloqueados de mandar mensagens até que um admin desbloqueie."	

	g_locale[LANG_US]["joinlock-release"] = "Release user"
	g_locale[LANG_BR]["joinlock-release"] = "Liberar usuário"


	g_locale[LANG_US]["joinlock-onlyadm"] = "Sorry, thats only for chat admin"
	g_locale[LANG_BR]["joinlock-onlyadm"] = "Desculpa, só admins do chat."

	g_locale[LANG_US]["joinlock-no-u"] = "Sorry, only chat admins can release you"
	g_locale[LANG_BR]["joinlock-no-u"] = "Desculpa, só admins do chat podem te liberar"

	g_locale[LANG_US]["joinlock-message"] = "Hello %s! You need permissions of a chat admin to use this chat. Dont worry, eventually some admin will come to rescue you and release you.\n\nAttention admins %s this user needs to be released."
	g_locale[LANG_BR]["joinlock-message"] = "Olá %s. Você precisa da autorização de um administrador do chat para poder enviar mensagens aqui. Não se preocupe, assim que um admin aparecer  para te resgatar e liberar você.\n\nAtenção admins %s, esse user precisa ser liberado."

end





function joinlock.save()

end

function joinlock.loadCommands()
	addCommand( "joinlock"					, MODE_CHATADMS, getModulePath().."/joinlock-command.lua", 2, "joinlock-command-helper" )
end


return joinlock