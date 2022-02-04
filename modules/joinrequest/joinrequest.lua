local module = {
	priority = DEFAULT_PRIORITY,
}

--[ONCE] runs when the load is finished
function module.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "joinRequest", {type="boolean"}, true, "Warn admin about join requests", "Misc")
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
					
					resMsg = bot.sendMessage(user, "Heys, the request to join chat "..tostring(chats[chat].title):htmlFix().." was approved", "HTML")
					res = bot.approveChatJoinRequest(chat, user)
					deploy_answerCallbackQuery(msg.id, "Accepted", "true")
				elseif mode == "dn" then 
					
					resMsg = bot.sendMessage(user, "Heys, im sorry but the admins have declined your join request on chat "..tostring(chats[chat].title):htmlFix(), "HTML")
					res = bot.declineChatJoinRequest(chat, user)
					deploy_answerCallbackQuery(msg.id, "Denied", "true")
				elseif mode == "dns" then 
					res = bot.declineChatJoinRequest(chat, user)
					deploy_answerCallbackQuery(msg.id, "Denied", "true")
				end

				if not res.ok then 
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
	local message = "User "..tostring(formatUserHtml(msg.from)).." has requested to join "..tostring(msg.chat.title).." trought an invite link "..(msg.invite_link.name and (" via link <b>"..msg.invite_link.name.."</b>" or ""))
	local chatid = msg.chat.id 

	local warn = bot.sendMessage(msg.from.id, "Hello "..formatUserHtml(msg.from).."! I got your request to join chat <b>"..msg.chat.title:htmlFix().."</b> and already notified chat admins. I will send you a message if its approved or not.", "HTML")

	if chats[chatid] and chats[chatid].data.joinRequest then
		local keyb = {}
	    keyb[1] = {}
	    keyb[2] = {}
	    keyb[3] = {}


	    keyb[1][1] = { text = "Accept", callback_data = "jr:acc:"..chatid..":"..msg.from.id} 
	    keyb[2][1] = { text = "Deny", callback_data = "jr:dn:"..chatid..":"..msg.from.id} 
	    keyb[3][1] = { text = "Silently deny", callback_data = "jr:dns:"..chatid..":"..msg.from.id} 

	    
	    local kb = cjson.encode({inline_keyboard = keyb })

		checkCacheChatAdmins(msg)
		for userId, _ in pairs(chats[chatid]._tmp.adms) do 
			userId = tonumber(userId)
			if userId then
				local usr = getUserById(userId)
				if userId ~= bot.id and usr and usr.telegramid then 
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
end


return module