local module = {
	priority = DEFAULT_PRIORITY,
}

--[ONCE] runs when the load is finished
function module.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "channel_block", {type="boolean"}, true, "Block messagens sent as channels instead of users", "Misc")
		pubsub.registerExternalVariable("chat", "forward_block", {type="boolean"}, true, "Delete forwarded messages from channels", "Misc")
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
	if msg.chat and msg.chat.type ~= "private" then
		if chats[msg.chat.id].data.channel_block then
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
		if chats[msg.chat.id].data.forward_block then
			if msg.forward_from_chat and msg.forward_from_chat.type == "channel" then 
				if not isEntityChatAdmin(msg) then
					deploy_deleteMessage(msg.chat.id, msg.message_id)
					if not chats[msg.chat.id]._tmp.channelBlockWarn or chats[msg.chat.id]._tmp.channelBlockWarn <= os.time() then
						chats[msg.chat.id]._tmp.channelBlockWarn = os.time() + 60
						say.delete(tr("channelblock-channel", formatUserHtml(msg)), 120, "HTML")
					end
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
	addCommand( "forwardblock", MODE_CHATADMS,  defaultToggleChatCommand("forward_block", "channelblock-channel-toggle"), 2 , "channelblock-channel-desc" )
end


function module.loadTranslation()
	g_locale[LANG_US]["channelblock-desc"] = "Ban channels that post here. Only when someone send a message as a channel. Ignores if it forward from it"
	g_locale[LANG_BR]["channelblock-desc"] = "Bane mensagens que foram enviadas como canais. Somente postagens que foram feitas usando o canal, se for encaminhado elas são ignoradas."

	g_locale[LANG_US]["channelblock-toggle"] = "Channel block is"
	g_locale[LANG_BR]["channelblock-toggle"] = "Channel block agora"

	g_locale[LANG_US]["channelblock-channel-desc"] = "Delete messagens forwarded here that came from channels."
	g_locale[LANG_BR]["channelblock-channel-desc"] = "Deleta mensagens encaminhadas aqui que vieram de canais."

	g_locale[LANG_US]["channelblock-channel-toggle"] = "Channel forward block is"
	g_locale[LANG_BR]["channelblock-channel-toggle"] = "Channel forward block agora"

	g_locale[LANG_US]["channelblock-banned"] = "Banned channel <b>%s</b>. No channels are allowed here, post using yor own account instead."
	g_locale[LANG_BR]["channelblock-banned"] = "Canal <b>%s</b> banido. Postagens usando o seu canal não são permitidas aqui, por favor poste usando sua conta normal."

	g_locale[LANG_US]["channelblock-failed"] = "Failed to banned channel <b>%s</b>.\nReason:<code>%s</code>"
	g_locale[LANG_BR]["channelblock-failed"] = "Falha ao banir canal <b>%s</b>.\nMotivo:<code>%s</code>"

	g_locale[LANG_US]["channelblock-channel"] = "Attention %s, its forbidden to forward messages from channels here."
	g_locale[LANG_BR]["channelblock-channel"] = "Atenção %s, é proibido encaminhar mensagens de canais aqui."
end


return module