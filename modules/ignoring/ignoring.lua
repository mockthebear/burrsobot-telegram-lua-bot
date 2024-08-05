local ignoring = {
	priority = DEFAULT_PRIORITY - 5000,
	ignored = {}
}
local cjson = require("cjson")
function ignoring.load()
	ignoring.ignored = configs["ignored"] or {}
end

function ignoring.save()
	configs["ignored"] = ignoring.ignored
	SaveConfig("ignored")
end

function ignoring.setIgnored(chatid, id, ignored)
	if not type(chats[chatid].data.ignored) ~= "table" then 
		chats[chatid].data.ignored = {}
	end
	chats[chatid].data.ignored = ignored and true or nil
	SaveChat(chatid)
end

function ignoring.getIgnored(chatid, id)
	if not type(chats[chatid].data.ignored) ~= "table" then 
		chats[chatid].data.ignored = {}
	end
	return chats[chatid].data.ignored[id] and true or false
end
function ignoring.setIgnoredGlobal(id, ignored)
	ignoring.ignored[id] = ignored and true or nil
	ignoring.save()
end

function ignoring.getIgnoredGlobal(id)
	return ignoring.ignored[id] and true or false
end

function ignoring.isIgnored( msg )
	if ignoring.ignored[msg.from.id] then 
		print("ignored "..msg.from.first_name)
		return  KILL_EXECUTION
	end

	if msg.isChat and chats[msg.chat.id] and type(chats[msg.chat.id].data.ignored) == "table" and chats[msg.chat.id].data.ignored[msg.from.id] then 
		print("Ignored by chat")
		return KILL_EXECUTION
	end
end

function ignoring.onTextReceive( msg )
	return ignoring.isIgnored( msg )	
end 

function ignoring.onStickerReceive( msg )
	return ignoring.isIgnored( msg )	
end 

function ignoring.onAudioReceive( msg )
	return ignoring.isIgnored( msg )	
end 

function ignoring.onDocumentReceive( msg )
	return ignoring.isIgnored( msg )	
end 

function ignoring.onCallbackQueryReceive(msg)
	return ignoring.isIgnored( msg )	
end 

function ignoring.onInlineQueryReceive(msg)
	return ignoring.isIgnored( msg )	
end 

function ignoring.onPhotoReceive(msg)
	return ignoring.isIgnored( msg )	
end 

function ignoring.onEditedMessageReceive(msg)
	return ignoring.isIgnored( msg )	
end 

function ignoring.onNewChatParticipant(msg)
	return ignoring.isIgnored( msg )	
end




function ignoring.loadTranslation()

	g_locale[LANG_BR]["ignoring-user-state"] = "Usuário %s agora está %s! Para reverter use /ignore de novo"
	g_locale[LANG_US]["ignoring-user-state"] = "Now user %s is %s! To toggle use the command /ignore again"	

	g_locale[LANG_BR]["ignoring-global-user-state"] = "Usuário %s agora está %s! Para reverter use /block de novo"
	g_locale[LANG_US]["ignoring-global-user-state"] = "Now user %s is %s! To toggle use the command /block again"

	g_locale[LANG_BR]["ignoring-unknown"] = "Usuário desconhecido. Use assim /ignore @username ou responder com o comando a mensagem"
	g_locale[LANG_US]["ignoring-unknown"] = "Unknown user, use like this: /ignore @username or reply with the command the message of the user."

	g_locale[LANG_US]["ignoring-ignored"] = "<b>ignored</b>"
	g_locale[LANG_BR]["ignoring-ignored"] = "<b>ignorado</b>"

	g_locale[LANG_US]["ignoring-released"] = "<b>released</b>"
	g_locale[LANG_BR]["ignoring-released"] = "<b>liberado</b>"


	g_locale[LANG_US]["ignoring-blocked"] = "<b>ignored</b>"
	g_locale[LANG_BR]["ignoring-blocked"] = "<b>ignorado</b>"


	g_locale[LANG_BR]["ignored-desc"] = "Faz com que o bot (eu), ignore um usuário nesse chat. Basta usar /ignore @username ou responder com o comando a mensagem"
	g_locale[LANG_US]["ignored-desc"] = "Make me ignore a user in this chat. Just use /ignore @username or reply with the command the message of the user."

	g_locale[LANG_BR]["ignored-g-desc"] = "Faz com que o bot (eu), globalmente!. Basta usar /block @username ou responder com o comando a mensagem"
	g_locale[LANG_US]["ignored-g-desc"] = "Make me ignore a user globally. Just use /block @username or reply with the command the message of the user."



end





function ignoring.save()

end



function ignoring.loadCommands()
	
	addCommand( "ignore"					, MODE_CHATADMS, getModulePath().."/ignore-user.lua", 2, "ignored-desc"  )
	addCommand( "block"						, MODE_ONLY_ADM, getModulePath().."/ignore-global.lua", 2, "ignored-g-desc"  )
end



return ignoring