local module = {
	priority = DEFAULT_PRIORITY,
}

--[ONCE] runs when the load is finished
function module.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "joinRequest", {type="boolean"}, true, "Warn admin about join requests (need bot as admin)", "Misc")
	end
end

--[ONCE] runs when eveything is ready
function module.ready()

end

--Runs at the begin of the frame
function module.frame()

end

--Runs some times
function module.save()

end 

function module.loadCommands()
	addCommand( "joinrequest", MODE_CHATADMS,  getModulePath().."/joinrequest_enable.lua", 2 , "joinrequests-desc" )
end


function module.onCallbackQueryReceive(msg)
	if msg.message then
		if msg.data:match("jr:(.-):(.-):(.+)") then
			local mode, chat, user = msg.data:match("jr:(.-):(.-):(.+)")
			user = tonumber(user)
			chat = tonumber(chat)
			if chats[chat] then
				local res 
				local resMsg
				if mode == "acc" then 
					g_lang = getUserById(user).lang or LANG_US
					resMsg = bot.sendMessage(user, tr("joinrequests-approve", tostring(chats[chat].title):htmlFix()), "HTML")
					res = bot.approveChatJoinRequest(chat, user)
					deploy_answerCallbackQuery(msg.id, "Accepted", "true")
					deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
				elseif mode == "query" then 
					if not msg.from.username then 
						deploy_answerCallbackQuery(msg.id, "ERROR. You need an username to do this action", "true")
						return
					end
					g_lang = getUserById(user).lang or LANG_US
					resMsg = bot.sendMessage(user, tr("joinrequests-query", tostring(chats[chat].title):htmlFix(), msg.from.username), "HTML")
					deploy_answerCallbackQuery(msg.id, "Message sent", "true")

				elseif mode == "dn" then 
					g_lang = getUserById(user).lang or LANG_US
					resMsg = bot.sendMessage(user, tr("joinrequests-deny" ,tostring(chats[chat].title):htmlFix()), "HTML")
					res = bot.declineChatJoinRequest(chat, user)
					deploy_answerCallbackQuery(msg.id, "Denied", "true")
					deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
				elseif mode == "dns" then 
					res = bot.declineChatJoinRequest(chat, user)
					deploy_answerCallbackQuery(msg.id, "Denied", "true")
					deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
				end

				if res and not res.ok then 
					bot.sendMessage(msg.from.id, "Error: "..cjson.encode(res))
				end

				if resMsg and not resMsg.ok then 
					bot.sendMessage(msg.from.id, "Error[2]: "..cjson.encode(resMsg))
				end
			end
		end
	end
end

function module.onUpdateChatJoinRequest(msg)


	local linkname = ""
	if msg.invite_link then 
		linkname = msg.invite_link.name and msg.invite_link.name or (msg.invite_link.invite_link or "?")
	end	


	
	local chatid = msg.chat.id 

	local warn = bot.sendMessage(msg.from.id, tr("joinrequests-request", formatUserHtml(msg.from), msg.chat.title:htmlFix()), "HTML")

	if chats[chatid] and chats[chatid].data.joinRequest then
		local keyb = {}
	    keyb[1] = {}
	    keyb[2] = {}
	    keyb[3] = {}
	    keyb[4] = {}


	    keyb[1][1] = { text = "Accept", callback_data = "jr:acc:"..chatid..":"..msg.from.id} 
	    keyb[2][1] = { text = "Deny", callback_data = "jr:dn:"..chatid..":"..msg.from.id} 
	    keyb[3][1] = { text = "Ask to user send dm", callback_data = "jr:query:"..chatid..":"..msg.from.id} 
	    keyb[4][1] = { text = "Silently deny", callback_data = "jr:dns:"..chatid..":"..msg.from.id} 

	    
	    local kb = cjson.encode({inline_keyboard = keyb })

		checkCacheChatAdmins(msg)
		for userId, _ in pairs(chats[chatid]._tmp.adms) do 
			userId = tonumber(userId)
			if userId then
				local usr = getUserById(userId)
				if userId ~= bot.id and usr and usr.telegramid then 

					g_lang = usr.lang or LANG_US
					local message = tr("User <b>%s</b> has requested to join <b>%s</b> trought an invite link <b>%s</b>", tostring(formatUserHtml(msg.from)), tostring(msg.chat.title or '?'), linkname)

					bot.sendMessage(userId, message, "HTML", true, false, nil, kb)
					if not warn.ok then
						bot.sendMessage(userId, Dump(warn))
					end
				end
			end
		end
	end
end

function module.loadTranslation()

	g_locale[LANG_BR]["joinrequests-desc"] = "Avisa aos admins sobre alguem tentando entrar."
	g_locale[LANG_US]["joinrequests-desc"] = "Warn the admins about someone trying to join"


	g_locale[LANG_BR]["joinrequests-active"] = "Pedidos de entrada no chat agora estão: *%s*"
	g_locale[LANG_US]["joinrequests-active"] = "Join requests messages are now: *%s*"

	g_locale[LANG_BR]["joinrequests-approve"] = "Oi, seu pedido para entrar no chat %s foi aprovado"
	g_locale[LANG_US]["joinrequests-approve"] = "Heys, the request to join chat %s was approved"

	g_locale[LANG_BR]["joinrequests-deny"] = "Oi, desculpe, mas seu pedido para entrar no chat %s foi negado pelos administradores."
	g_locale[LANG_US]["joinrequests-deny"] = "Heys, im sorry but the admins have declined your join request on chat %s."


	g_locale[LANG_BR]["joinrequests-query"] = "Olá, um admin verificou o seu pedido para entrar no chat <b>%s</b>. Porém ele precisa falar com você antes, talvez para perguntar alguma coisa ou comprovar idade. \nPor favor, envie uma mensagem para <b>@%s</b>"
	g_locale[LANG_US]["joinrequests-query"] = "Hey there, an chat admin checked your join request on chat <b>%s</b>. But this admin requires you to DM him, probally to ask some questions or make sure about your age.\nPlease, send a DM to <b>@%s</b>"

	g_locale[LANG_BR]["joinrequests-request"] = "Olá %s! Eu recebi seu pedido para entrar no chat <b>%s</b> e ja avisei os admins do chat. Eu te aviso se for aprovado ou negado. É possivel que um admin peça para você mandar mensagem para ele, nesse caso eu te aviso."
	g_locale[LANG_US]["joinrequests-request"] = "Hello %s! I got your request to join chat <b>%s</b> and already notified chat admins. I will send you a message if its approved or not. Its possible that an admin asks you to DM him, in that case i'll send it to you."
end


return module