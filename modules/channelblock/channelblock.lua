local module = {
	priority = DEFAULT_PRIORITY,
}

--[ONCE] runs when the load is finished
function module.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "channel_block", {type="boolean"}, true, "Block channel messagens", "Misc")
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

function module.check_channel_message(msg) 
	if msg.chat and msg.chat.type ~= "private" and chats[msg.chat.id].data.channel_block then
		if msg.sender_chat then
			local enty, which = getEntity(msg)
			if which ~= "user" then 
				if not isEntityChatAdmin(msg) then
					deploy_deleteMessage(msg.chat.id, msg.message_id)
					local aux = bot.banChatSenderChat(msg.chat.id, msg.sender_chat.id)
					if aux.ok then 
						say.delete(tr("channelblock-banned", msg.sender_chat.title),  120, "HTML")
					else 
						say.delete(tr("channelblock-failed", msg.sender_chat.title, aux.description:htmlFix()),  120, "HTML")
					end
					return false
				end
			end
		end
	end	
	return true
end




function module.onDocumentReceive(msg)
	if not module.check_channel_message(msg) then 
		return KILL_EXECUTION
	end
end

function module.onPhotoReceive(msg)
	if not module.check_channel_message(msg) then 
		return KILL_EXECUTION
	end
end

function module.onAudioReceive(msg)
	if not module.check_channel_message(msg) then 
		return KILL_EXECUTION
	end
end

function module.onStickerReceive(msg)
	if not module.check_channel_message(msg) then 
		return KILL_EXECUTION
	end
end

function module.onTextReceive(msg)
	if not module.check_channel_message(msg) then 
		return KILL_EXECUTION
	end
end


function module.loadCommands()
	addCommand( "channelblock", MODE_CHATADMS,  defaultToggleChatCommand("channel_block", "channelblock-toggle"), 2 , "channelblock-desc" )
end


function module.loadTranslation()
	g_locale[LANG_US]["channelblock-desc"] = "Ban channels that post here. Only when someone send a message as a channel. Ignores if it forward from it"
	g_locale[LANG_BR]["channelblock-desc"] = "Bane mensagens que foram enviadas como canais. Somente postagens que foram feitas usando o canal, se for encaminhado elas são ignoradas."

	g_locale[LANG_US]["channelblock-toggle"] = "Channel block is"
	g_locale[LANG_BR]["channelblock-toggle"] = "Channel block agora"

	g_locale[LANG_US]["channelblock-banned"] = "Banned channel <b>%s</b>. No channels are allowed here, post using yor own account instead."
	g_locale[LANG_BR]["channelblock-banned"] = "Canal <b>%s</b> banido. Postagens usando o seu canal não são permitidas aqui, por favor poste usando sua conta normal."

	g_locale[LANG_US]["channelblock-failed"] = "Failed to banned channel <b>%s</b>.\nReason:<code>%s</code>"
	g_locale[LANG_BR]["channelblock-failed"] = "Falha ao banir canal <b>%s</b>.\nMotivo:<code>%s</code>"
end


return module