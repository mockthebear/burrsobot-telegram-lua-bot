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
	addCommand( "joinrequest", MODE_FREE,  getModulePath().."/joinrequest_enable.lua", 2 , "joinrequests-desc" )
end


function module.onUpdateChatJoinRequest(msg)
	local message = "User "..tostring(formatUserHtml(msg.from)).." has requested to join "..tostring(msg.chat.title).." trought an invite link "..(msg.invite_link.name and (" via link <b>"..msg.invite_link.name.."</b>" or ""))
	local chatid = msg.chat.id 

	if chats[chatid] and chats[chatid].data.joinRequest then
		checkCacheChatAdmins(msg)
		for userId, _ in pairs(chats[chatid]._tmp.adms) do 
			userId = tonumber(userId)
			if userId then
				local usr = getUserById(userId)
				if userId ~= bot.id and usr and usr.telegramid then 
					bot.sendMessage(userId, message, "HTML")
				end
			end
		end
	end
end

function module.loadTranslation()

	g_locale[LANG_US]["joinrequests-desc"] = "Avisa aos admins sobre alguem tentando entrar."
	g_locale[LANG_BR]["joinrequests-desc"] = "Warn the admins about someone trying to join"


	g_locale[LANG_US]["joinrequests-active"] = "Pedidos de entrada no chat agora estão: *%s*"
	g_locale[LANG_BR]["joinrequests-active"] = "Join requests messages are now: *%s*"
end


return module