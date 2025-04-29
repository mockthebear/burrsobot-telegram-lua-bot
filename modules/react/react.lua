
local react = {
	priority = DEFAULT_PRIORITY - 1000100,
	channel = "@burrbanbot"
}


--[ONCE] runs when the load is finished
function react.load()

end

--[ONCE] runs when eveything is ready
function react.ready()

end

--Runs at the begin of the frame
function react.frame()

end

function react.checkMessage(msg)
	if msg.chat.id == -1001455345919 and msg.from.id == 1425693179 then 
		local last = users[msg.from.id].last_bottom
		last = tonumber(last) or 0 
		if os.time() - last > 3600 then 
			reply("Oi bottom.")
		end
		users[msg.from.id].last_bottom = os.time()
		
	end

	if msg.chat.id == -1001455345919 and msg.from.id == 479962645 then 
		local last = users[msg.from.id].last_bottom
		last = tonumber(last) or 0 
		if os.time() - last > 3600 then 
			reply("Oi baby.")
		end
		users[msg.from.id].last_bottom = os.time()
		
	end

	if msg.isChat then
		chats[msg.chat.id].data.bother = chats[msg.chat.id].data.bother or {}

		if chats[msg.chat.id].data.bother[msg.from.id] then  
			deploy_setMessageReaction(msg.chat.id, msg.message_id, {{type="emoji",  emoji=chats[msg.chat.id].data.bother[msg.from.id]}}, true)
    	
		end

		local cooldown = chats[msg.chat.id].data.reply_cooldown or 3600
		chats[msg.chat.id].data.reply = chats[msg.chat.id].data.reply or {}
		if chats[msg.chat.id].data.reply[msg.from.id] then  
			local last = users[msg.from.id].last_reply
			last = tonumber(last) or 0 
			if os.time() - last >= cooldown then 
				reply(chats[msg.chat.id].data.reply[msg.from.id])
			end
			users[msg.from.id].last_reply = os.time()
		end
	end

end


function react.onTextReceive( msg )
	react.checkMessage(msg)
	
end 

function react.onStickerReceive( msg )
	react.checkMessage(msg)
end

function react.onAudioReceive( msg )
	react.checkMessage(msg)
end  

function react.onDocumentReceive( msg )
	react.checkMessage(msg)
end

function react.onVideoReceive( msg )
	react.checkMessage(msg)
end



--Runs some times
function react.onPhotoReceive(msg)
	react.checkMessage(msg)
end 


function react.loadTranslation()
	g_locale[LANG_BR]["Now every hour when %s say something I'll reply with:\n<code>%s</code>\nTo stop use /reply @user stop"] = "Agora toda vez que %s falar algo com intervalo de uma hora, eu vou responder com:\n<code>%s</code>\nPara parar use /reply @user stop"
	g_locale[LANG_BR]["Emoji not valid.\nAvaliable: "] = "Emoji inválido\nDisponivel apenas: "

	g_locale[LANG_BR]["Now every msg from %s will be reacted with %s.\nTo stop use <code>/bother @username stop</code>"] = "Agora cada mensagem de %s será reagida com %s\nPara parar use  <code>/bother @username stop</code>"
	g_locale[LANG_BR]["Cant find this user"] = "Não encontrei esse usuário"
	g_locale[LANG_BR]["Use like:\n<code>/bother @username 🥰</code>\nOr use <code>/bother @username stop</code> to remove the reaction"] = "Use assim:\n<code>/bother @username 🥰</code>\nOu use <code>/bother @username stop</code> para remover as reações."
	g_locale[LANG_BR]["Command used to bother someone by making the bot react to every message of they by making the bot react with an emoji"] = "Comando usado para encher o saco de alguem fazendo o bot reagir com um emoji a todas as mensagens dela no chat."
	
	g_locale[LANG_US]["reply-usage"] = "Use like: /reply @username Look, the gayest person is here!\nThis will make the bot reply one message of that user every hour with the text you set.\nPara parar use: /reply @username stop"
	g_locale[LANG_BR]["reply-usage"] = "Use assim: /reply @username Olha que viadão!\nIsso vai me fazer responder uma mensagem da pessoa em um intervalo de uma hora com a mensagem que você colocar.\nPara parar use: /reply @username stop"

end





function react.save()

end



function react.loadCommands()
	addCommand( "bother" 					, MODE_CHATADMS, getModulePath().."/bother.lua", 2 , "Command used to bother someone by making the bot react to every message of they by making the bot react with an emoji" )
	addCommand( "reply" 					, MODE_CHATADMS, getModulePath().."/reply.lua", 2 , "reply-usage" )
end



return react