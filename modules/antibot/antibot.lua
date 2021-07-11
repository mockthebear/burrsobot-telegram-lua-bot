local antibot = {
	priority = DEFAULT_PRIORITY - 1000100,
	channel = "@burrbanbot"
}
local JSON = require("JSON")
--[ONCE] runs when the load is finished
function antibot.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "botProtection", {type="boolean"}, true, "Bot protection", "Anti-bot")
		pubsub.registerExternalVariable("chat", "botEnforced", {type="boolean"}, true, "Enforce bot protection (force the check on any users)", "Anti-bot")
		pubsub.registerExternalVariable("chat", "ignoreInviteLink", {type="boolean"}, true, "Captcha ignoring invite link", "Anti-bot")
		pubsub.registerExternalVariable("chat", "no_nudes", {type="boolean"}, true, "Lock user for 5 minuts to start posting photos", "Anti-bot")
		pubsub.registerExternalVariable("chat", "easyBot", {type="boolean"}, true, "Easy check (single click). This is unsafe", "Anti-bot")
	end
	if core then  
		core.addStartOption("Anti bot protection", "OwO", "nobot", function() return tr("antibot-start-desc") end )
	end
end

--[ONCE] runs when eveything is ready
function antibot.ready()

end

--Runs at the begin of the frame
function antibot.frame()

end


-- this happens on private, so the targetChat is the id of the chat to be release~
function antibot.sendCapthaCommand(targetChat, msg, chatid)
    if chats[targetChat] then 
        if chats[targetChat]._tmp.checking[msg.from.id] then
            --say.admin("")
            local capteched, status, captchaid = captcha.startCaptchaProcedure(chatid, msg.from.id, "To prove you're not a bot, type the number on the image here. You can try 3 times.\nIf you cannot guess, type /recaptcha", 
            function(msg)
                antibot.releaseBot({id=targetChat, title="?"}, msg.from) --todo fix chat title
            end,  
            function(msg)
                reply(tr("you failed"))
            end, true)
            if capteched and status == "check" then 
            	chats[targetChat]._tmp.checking[msg.from.id] = captchaid
            end
            if not capteched then 
				antibot.releaseBot({id=targetChat, title="?"}, msg.from)
            	return
            end
            if users[msg.from.id].bot_procedure_check then 
            	setEventDuration(users[msg.from.id].bot_procedure_check, 120)
            	if users[msg.from.id].todelete then 

            	end
            end
        else 
            reply("You are not a bot.")
        end            
    end
end



function antibot.onTextReceive( msg )
	if msg.isChat and chats[msg.chat.id].data.botProtection then

		if chats[msg.chat.id]._tmp.checking[msg.from.id] then
			deploy_deleteMessage(msg.chat.id, msg.message_id)	
			return
		end

		if chats[msg.chat.id]._tmp.newUser[msg.from.id] then
			chats[msg.chat.id]._tmp.newUser[msg.from.id] = false
			if hasLink(msg.text) then
				antibot.forceBotCheck(msg, tr("antibot-first-link"))
				deploy_deleteMessage(msg.chat.id, msg.message_id)
				return
			else 
				SaveUser(msg.from.username)
			end	
		end


		if chats[msg.chat.id].data.no_nudes then  
			local opUser = users[msg.from.id]
			local dur = os.time() - opUser.joinDate[msg.chat.id] or os.time() - 300
			if opUser.joinDate[msg.chat.id] and dur <= 300 then
				if hasLink(msg.text) then
					bot.sendMessage(msg.chat.id, tr("antibot-nolinks" ,selectUsername(msg, true),(300-dur)), "HTML")
					deploy_deleteMessage(msg.chat.id, msg.message_id)
					return
				end
			end
		end
	end


end 

function antibot.onDocumentReceive( msg )
	
	if msg.isChat and chats[msg.chat.id].data.botProtection then
		
		if users[msg.from.id] and (chats[msg.chat.id]._tmp.checking[msg.from.id]) then 
			deploy_deleteMessage(msg.chat.id, msg.message_id)
			return
		end

		if chats[msg.chat.id]._tmp.newUser[msg.from.id] then
			chats[msg.chat.id]._tmp.newUser[msg.from.id] = false
			antibot.forceBotCheck(msg, tr("antibot-first-document"))
			deploy_deleteMessage(msg.chat.id, msg.message_id)
			return
		end		
	end
end

function antibot.onCallbackQueryReceive(msg)
	if msg.message then
		if msg.data:match("nbcp:([%-%d]+)") then
			local chat, id = msg.data:match("nbcp:([%-%d]+)")
			deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
			deploy_answerCallbackQuery(msg.id, "Please solve the captcha :D", "true")
				
			chat = tonumber(chat)
			antibot.sendCapthaCommand(chat, msg, msg.from.id)
			return KILL_EXECUTION
		elseif msg.data:match("nbae:([%-%d]+)") then
			local chat = msg.data:match("nbae:([%-%d]+)")
			antibot.releaseBot(msg.message.chat, msg.from)
            deploy_answerCallbackQuery(msg.id, "Done~", "true")
			return KILL_EXECUTION
		elseif msg.data:match("admbn:([%-%d]+):(%d+)") then
			local chat, id = msg.data:match("admbn:([%-%d]+):(%d+)")
			chat = tonumber(chat)
			id = tonumber(id)
			if isUserChatAdmin(chat, msg.from.id) or isUserBotAdmin(msg.from.id)  then
				for iid,b in pairs(chats[chat]._tmp.checking) do 
					if tonumber(iid) == id then 
						if  users[id].bot_procedure_check then
							triggerEvent(users[id].bot_procedure_check)
							users[id].bot_procedure_check = nil

							if users[id].todelete then 
			            		bot.deleteMessage(chat, users[id].todelete)
			            	end
							bot.answerCallbackQuery(msg.id, "Banned "..id, "true")
							SaveUser(id)
						else 
							bot.answerCallbackQuery(msg.id, "big bug "..id, "true")
						end
						return KILL_EXECUTION
					end 
				end
				bot.answerCallbackQuery(msg.id, "No user "..id, "true")
				return KILL_EXECUTION
			else 
				deploy_answerCallbackQuery(msg.id, "Only chat admins", "true")
			end
		elseif msg.data:match("admrls:([%-%d]+):(%d+)") then
			local chat, id = msg.data:match("admrls:([%-%d]+):(%d+)")
			chat = tonumber(chat)
			id = tonumber(id)
			if chats[chat] then
				if isUserChatAdmin(chat, msg.from.id) or isUserBotAdmin(msg.from.id)  then
					local mem = bot.getChatMember(chat, id)
					if mem and mem.ok then
						antibot.releaseBot(chats[chat], mem.result.user, "chat admin")
						deploy_answerCallbackQuery(msg.id, "Done~", "true")
						if users[id].todelete then 
			            	bot.deleteMessage(chat, users[id].todelete)
			            end
					else
						deploy_answerCallbackQuery(msg.id, mem.description, "true")
					end
				else 
					deploy_answerCallbackQuery(msg.id, "Only chat admins", "true")
				end
			else
				deploy_answerCallbackQuery(msg.id, "chat?", "true")
           	end
			return KILL_EXECUTION
		elseif msg.data:match("rls:([%-%d]+):(%d+)") then
			local chat, id = msg.data:match("rls:([%-%d]+):(%d+)")
			chat = tonumber(chat)
			id = tonumber(id)
			local b = getUserById(id)
			if b and chats[chat] then 
				users[id].bot_banned =  0
				users[id].deleted = 0
				chats[chat]._tmp.checking[id] = false
				bot.restrictChatMember(chat , id, -1, false, false, false, false) 
				bot.unbanChatMember(chat, id)
				SaveUser(id) 
				deploy_answerCallbackQuery(msg.id, "Released user.", "true")
				g_lang = b.lang or LANG_BR
				bot.sendMessage(chat, tr("antibot-unban", formatUserHtml(users[id]) ), "HTML") 
				return
			else 
				deploy_answerCallbackQuery(msg.id, "no user user.", "true")
			end
			
		end
	end 
end

--Runs some times
function antibot.onPhotoReceive(msg)
	if msg.isChat and chats[msg.chat.id].data.botProtection then
		--Delete the message if the user is still beeing checked as a bot~
		if users[msg.from.id] and (chats[msg.chat.id]._tmp.checking[msg.from.id]) then 
			deploy_deleteMessage(msg.chat.id, msg.message_id)
			return KILL_EXECUTION
		end

		if chats[msg.chat.id]._tmp.newUser[msg.from.id] then
			chats[msg.chat.id]._tmp.newUser[msg.from.id] = false
			antibot.forceBotCheck(msg,  tr("antibot-first-photo"))
			deploy_deleteMessage(msg.chat.id, msg.message_id)
			return KILL_EXECUTION
		end

		if chats[msg.chat.id].data.no_nudes then  
			local opUser = users[msg.from.id]
			local dur = os.time() - opUser.joinDate[msg.chat.id]
			if opUser.joinDate[msg.chat.id] and dur <= 300 then

				bot.sendMessage(g_chatid, "User "..selectUsername(msg, true).." you dont have the right to send photos here YET. Im deleting and restricting you for "..(300-dur).." seconds.", "HTML")

				deploy_deleteMessage(msg.chat.id, msg.message_id)
				bot.restrictChatMember(msg.chat.id , msg.from.id, msg.date + (300-dur), false, false, false, true) 
				return KILL_EXECUTION
			end
		end
		
	end
end 


function antibot.checkBotStillInChat(res)
    if users[res.id] then
        local xx = bot.getChatMember(res.chat, res.id)
        if xx and xx.ok then 
            return true
        end

        local msg = nil
        while not msg do 
             msg = bot.sendMessage(res.chat,'User <a href="tg://user?id='..(res.id or users[res.id].telegramid or 0)..'">'..res.name..' ('..(res.id or users[res.id].telegramid or 0)..')</a> left the chat.', "HTML")
        end
        if res.msg then 
            bot.deleteMessage(res.chat, res.msg)
        end
        if res.event then
            schedule[res.event] = nil
        end
        if type(chats[res.chat]._tmp.checking[res.id]) == "number" then
        	local capid = chats[res.chat]._tmp.checking[res.id] 
        	captcha.closeCaptha(capid)
        end

        users[res.id].left = true
        bot.deleteMessage(res.chat, res.msg)
        chats[res.chat]._tmp.newUser[res.id] = nil
        chats[res.chat]._tmp.checking[res.id] = nil

        SaveUser(res.id)
    else 
        bot.sendMessage(res.chat,"error 1338 : "..res.username..": "..res.id)    
    end
end


function antibot.onNewChatParticipant(msg)
	local fromLink = msg.actor.id ~= msg.from.id

	if chats[msg.chat.id].data.ignoreInviteLink then 
		fromLink = false
	end
	local restricted = false

	if users[msg.new_chat_participant.id] then


			
		if (chats[msg.chat.id].data.botProtection) then

			local shouldCheck = true
			if not chats[msg.chat.id].data.botEnforced then 
				if users[msg.new_chat_participant.id].is_human_permanent then 
					shouldCheck = false
				end
			end

			if shouldCheck then
				--print('fromLink = ',fromLink)
				if not fromLink and ((chats[msg.chat.id].data.botProtection and users[msg.new_chat_participant.id] and (users[msg.new_chat_participant.id].unsafe or (users[msg.new_chat_participant.id].bot_banned and  tonumber(users[msg.new_chat_participant.id].bot_banned) or os.time()+9999)  < os.time()) ) or chats[msg.chat.id].data.botEnforced ) then 
					bot.restrictChatMember(msg.chat.id, msg.new_chat_participant.id, -1, false, false, false, false)
					local hasUname = msg.new_chat_participant.username2 == msg.new_chat_participant.username
					local lname = originalUname and ("@"..msg.new_chat_participant.username) or msg.new_chat_participant.first_name
		
					local reason = nil
					if chats[msg.chat.id].data.botEnforced then 
						reason = tr("antibot-reason")
					else 
						reason = users[msg.new_chat_participant.id].unsafe
					end
					local msger,ttt = antibot.formatKickMessage(msg.chat.id,msg.new_chat_participant.id, msg.new_chat_participant.first_name, msg.new_chat_participant.originalUname, reason, g_msg.message_id)
						
					chats[msg.chat.id]._tmp.checking[msg.new_chat_participant.id] = true
					
					local eventId = scheduleEvent(120, antibot.botUserCheck, msg, msger.result.message_id) 
					users[msg.new_chat_participant.id].todelete = msger.result.message_id
					users[msg.new_chat_participant.id].bot_procedure_check = eventId
					print("Proc: "..eventId)
					

					scheduleEvent(110, antibot.checkBotStillInChat, {event=eventId,id = msg.new_chat_participant.id, chat = msg.chat.id, username = msg.new_chat_participant.username, msg = msger.result.message_id, name=msg.new_chat_participant.first_name:htmlFix(), mid=msg.message_id } )

					SaveUser(msg.new_chat_participant.id)

					restricted = true

				end
			end

			if not fromLink and  users[msg.new_chat_participant.id].bot_banned and ( tonumber(users[msg.new_chat_participant.id].bot_banned) or os.time()+9999) > os.time() then 
				assertMsg(bot.sendMessage(g_chatid,tr("<b>Attention!</b> User <a href=\"tg://user?id=%d\">%s</a> has failed before to prove its a bot in another chat. This user might be a bot.%s",
					msg.new_chat_participant.id, 
					msg.new_chat_participant.first_name:htmlFix()..""..(msg.new_chat_participant.originalUname and (" (@"..msg.new_chat_participant.originalUname..")") or "" ),
					chats[msg.chat.id].data.botProtection and "" or "\nMight be a good idea enable /botprotection"
					),"HTML"))
			end
		end

		if not users[msg.new_chat_participant.id].bot_banned and not chats[msg.chat.id]._tmp.checking[msg.new_chat_participant.id] then
			if chats[msg.chat.id].data.no_nudes == 1 or chats[msg.chat.id].data.no_nudes == 2 then
	            bot.restrictChatMember(targetChat, id, os.time()+300, false, false, false, true)
	        end 
   		end

	end

	if restricted then 
		return KILL_EXECUTION
	end

end




function antibot.formatKickMessage(chat,userId, userName, uname, reason, msgid)

    g_lang = chats[chat].data.lang

    local keyb = {}
    keyb[1] = {}
    keyb[2] = {}
    keyb[3] = {}

    if chats[chat].data.easyBot then
        keyb[1][1] = { text = tr("antibot-notabot"), callback_data = "nbae:"..chat} 
    else
        keyb[1][1] = { text = tr("antibot-notabot"), url = "https://telegram.me/burrsobot?start="..chat.."_notabot"} 
    end


    local kb = JSON:encode({inline_keyboard = keyb })
    local isSent = false
    if users[userId] then 
        local keyb2 = {}
        keyb2[1] = {}
        keyb2[1][1] = { text = tr("antibot-notabot"), callback_data = "nbcp:"..chat}
        local kb2 = JSON:encode({inline_keyboard = keyb2 })
        local rer = bot.sendMessage(users[userId].telegramid, tr("antibot-pvt-message", (chats[chat].title or "this chat"):htmlFix() )..(chats[chat].data.easyBot and " \nOnce you pressed, the text box will show `start` press it again!" or ""), "HTML", true, false, nil, kb2)
        if rer and rer.ok then 
            isSent = true
        end

    end
    --if users[userId] then
        keyb[2][1] = { text = tr("antibot-approve"), callback_data = "admrls:"..chat..":"..userId} --   url = "https://telegram.me/burrsobot?start="..chat.."_releasebot_"..(users[userId] and users[userId].telegramid or userId) 
        keyb[3][1] = { text = tr("antibot-notapprove"), callback_data = "admbn:"..chat..":"..userId} --   url = "https://telegram.me/burrsobot?start="..chat.."_releasebot_"..(users[userId] and users[userId].telegramid or userId) 
    --end
    local kb = JSON:encode({inline_keyboard = keyb })
    
    local msg = nil 
    local text = tr('antibot-enter-message', formatUserHtml({from={id=userId, name=(userName):htmlFix(), username = uname}}), ( reason or "auto check"):htmlFix() )
    if isSent then
        text = text .. tr("antibot-pvt-notify")
    end

    msg = bot.sendDocument(chat, "CgADBAAD-AADuxgkUjxM9Uzdf7FDFgQ", text, false, msgid or false , kb, "HTML")
    if msg and not msg.ok then 
    	msg = bot.sendMessage(chat, text, "HTML", false, false, msgid or false , kb)
 	end
       
    return msg,text
end


function antibot.checkUserIsInChat(msg)
    local usr = msg.new_chat_participant or msg.from 
    if users[msg.from.id] then
        local data = bot.getChatMember(msg.chat.id, usr.id)
        if data then 
            if data.ok == false or data.ok == "false" or data.result.status == "left" then 
                bot.sendMessage(msg.chat.id,"User "..formatUserHtml(msg).." left the chat. Sad.", "HTML")
                users[msg.from.id].left = true
            end
        end
    end
end




function antibot.releaseBot(chat, user, callbackId)  --, id, fname, cb


    if chats[chat.id] then
        g_lang = chats[chat.id].data.lang
    else 
    	if callbackId then
       		deploy_answerCallbackQuery(callbackId, "Unknow chat. Message @mockthebear!", "true")
        end
        return
    end


    local aux = ""
    local JSON = require("JSON")
    if chats[chat.id]._tmp.checking[user.id] then 

         

        if type(chats[chat.id]._tmp.checking[user.id]) == "number" then
        	local capid = chats[chat.id]._tmp.checking[user.id] 
        	captcha.closeCaptha(capid)
        end

        chats[chat.id]._tmp.checking[user.id] = nil

        chats[chat.id]._tmp.newUser[user.id] = nil 
        users[user.id].bot_banned = nil

        if callbackId then 
            deploy_answerCallbackQuery(callbackId, "Confirmed! Welcome.", "true")
        end
        
        if chats[chat.id].data.no_nudes == 2 or chats[chat.id].data.no_nudes == 1 then
            bot.restrictChatMember(chat.id, user.id, os.time()+300, false, false, false, true)
        else
            bot.restrictChatMember(chat.id, user.id, -1, true, true, true, true)
        end 
       
        bot.sendMessage(user.id, tr("antibot-released"), "HTML",true,false, nil)

		scheduleEvent(60, antibot.checkUserIsInChat, {chat=chat, from=user}) 
		scheduleEvent(120, antibot.checkUserIsInChat, {chat=chat, from=user}) 

		welcome.sendWelcomeMessage({chat=chat, from=user})
    end    

    if users[user.id] and users[user.id].todelete then 
    	if users[user.id].todelete then 
    		stopEvent(users[user.id].bot_procedure_check)
    		users[user.id].bot_procedure_check = nil
    	end

        local del = bot.deleteMessage(chat.id, users[user.id].todelete)
        if del and del.ok then
        	users[user.id].todelete = nil
        	SaveUser(user.id)
    	end
    end
end


function antibot.botUserCheck(msg, msg_delete)
	--Check chat because the bot can leave the chat in between the timer
    if users[msg.from.id] and chats[msg.chat.id] then
        if msg_delete then
         	bot.deleteMessage(msg.chat.id, msg_delete)
        end
        if chats[msg.chat.id]._tmp.checking[msg.from.id] then 
            g_lang = getUserLang(msg)

            if type(chats[msg.chat.id]._tmp.checking[msg.from.id]) == "number" then
	        	local capid = chats[msg.chat.id]._tmp.checking[msg.from.id] 
	        	captcha.closeCaptha(capid)
	        end

            local ret = bot.kickChatMember(msg.chat.id, msg.from.id  or users[msg.from.id].telegramid, os.time()+3600*24)
            if not ret or not ret.ok then 
                bot.sendMessage(msg.chat.id,"Failed to kick, reason:"..tostring(ret.description))
                chats[msg.chat.id]._tmp.checking[msg.from.id] = false
                return
            end

            local restMsg = nil
            while not restMsg do 
                restMsg = bot.sendMessage(msg.chat.id, tr("antibot-ban", formatUserHtml(msg)), "HTML")
            end
            
            g_chatid = msg.chat.id 

            chats[msg.chat.id]._tmp.newUser[msg.from.id] = nil
            chats[msg.chat.id]._tmp.checking[msg.from.id] = nil

            users[msg.from.id].bot_banned = os.time() + 12 * 3600
            users[msg.from.id].left = true
            SaveUser(msg.from.id)


            local keyb = {}
            keyb[1] = {}

            
            keyb[1][1] = { text = tr("Release (unban)"), callback_data = "rls:"..msg.chat.id..":".. msg.from.id } 
            
            local kb = JSON:encode({inline_keyboard = keyb })

        

            say.admin('Banned '..formatUserHtml(msg)..' for beeing a bot on '..chats[msg.chat.id].title, "HTML", true, false, nil, kb)
            bot.sendMessage(antibot.channel,'Banned '..formatUserHtml(msg)..' for failing to prove its not a bot.', "HTML")
           
        else 
            --bot.sendMessage(msg.chat.id,"User confirmed.")
            chats[msg.chat.id]._tmp.newUser[msg.from.id] = nil
            users[msg.from.id].unsafe = nil
            SaveUser(msg.from.id)
        end
    end
end


function antibot.forceBotCheck(msg, reason)
    if not chats[msg.chat.id]._tmp.checking[msg.from.id] then
        bot.restrictChatMember(msg.chat.id , msg.from.id, -1, false, false, false, false) 
        local todeleteMessage = antibot.formatKickMessage(msg.chat.id, msg.from.id, msg.from.first_name, msg.from.originalUname, reason, msg.message_id)
        chats[msg.chat.id]._tmp.checking[msg.from.id] = true
        if not msg.new_chat_participant then 
        	msg.new_chat_participant = msg.from
        end
        users[msg.new_chat_participant.id].todelete = todeleteMessage.result.message_id
        users[msg.from.id].bot_procedure_check =  scheduleEvent(120, antibot.botUserCheck, msg, todeleteMessage.result.message_id) 
        print("Proc: "..users[msg.from.id].bot_procedure_check)
    end  
end


function antibot.loadTranslation()
	g_locale[LANG_BR]["antibot-enter-message"] = 'Olá %s. Por conta de %s eu preciso que você prove que você não é um bot.\n\n<b>Você tem 2 minutos para apertar o botão se não será banido automaticamente.</b>\nBasta apertar no botão que vai encaminhar para o bot, e dar start.'
	g_locale[LANG_US]["antibot-enter-message"] = 'Hello %s. Due %s i need you to prove that you\'re not a bot.\n\n<b>You have two minutes to prove, otherwise you will be banned.</b>\nJust press the button bellow and start the bot.'


	g_locale[LANG_BR]["antibot-notabot"] = "Não sou um bot"
	g_locale[LANG_US]["antibot-notabot"] = "Im not a bot"


	g_locale[LANG_BR]["antibot-reason"] = "Regras do chat"
	g_locale[LANG_US]["antibot-reason"] = "Chat rules"


	g_locale[LANG_BR]["antibot-approve"] = "(Admin only) Aprovar"
	g_locale[LANG_US]["antibot-approve"] = "(Admin only) Approve"

	g_locale[LANG_BR]["antibot-notapprove"] = "(Admin only) Banir"
	g_locale[LANG_US]["antibot-notapprove"] = "(Admin only) Ban"

	g_locale[LANG_BR]["antibot-start-desc"] = "You know that bots that joins and dont say a word? Users without profile picture and two letter names that sometimes just announce some shit? So, i can help handle that problem. Activating the bot protection using /panel or /botprotection and igving permissions i can check if they are real users or bots and get rid of them!"
	g_locale[LANG_US]["antibot-start-desc"] = "Sabe aqueles bot que entram e não falam nada? Usuários com nomes de duas letras sem fotos, ou que só entram e anunciam alguma coisa? Pois é, eu consigo amenizar esse problema. Ativando a proteção de bots pelo /painel ou pelo /botprotection, e me dando admin do chat, eu verifico se são bots mesmo, e se forem, eu os kicko!"


	g_locale[LANG_BR]["antibot-pvt-notify"] = "\n\n✅Usuário avisado pelo privado✅"
	g_locale[LANG_US]["antibot-pvt-notify"] = "\n\n✅User were notified by private message✅"

	g_locale[LANG_BR]["antibot-pvt-message"] = "Você acabou de entrar no chat <b>%s</b>, e a proteção anti bot está ativa. Você tem 2 minutos para provar que não é um bot, se não será removido do chat automaticamente.\n\nAperte o botão abaixo"
	g_locale[LANG_US]["antibot-pvt-message"] = "You just joined the <b>%s</b>, and the bot protection were triggered. You have two minutes to check there or otherwise will be banned.\n\nPress this button and do an start command."

	g_locale[LANG_BR]["antibot-released"] = "Obrigado, você se confirmou como não bot, e suas restrições foram removidas."
	g_locale[LANG_US]["antibot-released"] = "Thanks! You confirmed as not a bot, your restrictions were removed."


	g_locale[LANG_BR]["antibot-ban"] = 'Usuário %s foi kickado por falhar em provar que não é um bot.'
	g_locale[LANG_US]["antibot-ban"] = 'User %s banned for failing to prove its not a bot.\n<b>BEGONE BOT</b>'


	g_locale[LANG_BR]["antibot-first-document"] = "primeira mensagem no chat ser um arquivo"
	g_locale[LANG_US]["antibot-first-document"] = "first message contains a file"

	g_locale[LANG_BR]["antibot-first-photo"] = "primeira mensagem no chat ser uma foto"
	g_locale[LANG_US]["antibot-first-photo"] = "first message contains a photo"

	g_locale[LANG_BR]["antibot-first-link"] = "primeira mensagem no chat conter link"
	g_locale[LANG_US]["antibot-first-link"] = "first message contains a link"	


	g_locale[LANG_BR]["antibot-nolinks"] = "Usuário %s não tem permissão para enviar links aqui ainda. Eu vou deletar todos os links até a limitação de %s segundos."
	g_locale[LANG_US]["antibot-nolinks"] = "User %s you dont have the right to send links here yet. Im deleting every link until the limitation of %s seconds."

	g_locale[LANG_BR]["antibot-unban"] = 'Usuário %s foi desbanido e desmarcado como bot.'
	g_locale[LANG_US]["antibot-unban"] = 'User %s was unbanned and unmarked as a bot. He is allowed to join again.'

	g_locale[LANG_BR]["antibot-desc"] = "Quando um user novo entrar:\n- Se ele estiver sem username\n- Sem foto de perfil\n- Na blacklist\n- Sua primeira mensagem for uma midia\n- Sua primeira mensagem for um link\nO bot vai automaticamente apagar a mensagem dele\nO usuario será restrito de postar qualquer coisa no chat e um contador de 2 minutos inicia.\nO usuario terá que apertar um botão para provar que não é um bot de anuncio.\nQuando ele apertar o bloqueio sai e ele não é kickado.\n\nPara ligar isso, coloque o bot como admin ou com permissão de kickar e de restringir e deletar mensagens, use o comando /botprotection e pronto!"
	g_locale[LANG_US]["antibot-desc"] = 'When a new user joins:\n- without profile pic\n- without username\n- on the blocklist\n- his first message contain media or link\nThe bot will lock this user and send him a button. If he dont presses it within 2 minutes he will be kicked.'



end





function antibot.save()

end



function antibot.loadCommands()
	addCommand( "notabot" 					, MODE_UNLISTED, getModulePath().."/rlsbot.lua", 2 , "-" )
	addCommand( "human" 					, MODE_ONLY_ADM, getModulePath().."/human.lua", 2 , "-" )
	addCommand( "botprotection"				, MODE_CHATADMS, getModulePath().."/botprotecc.lua", 2, "antibot-desc"  )
	addCommand( "botcheck"					, MODE_CHATADMS, getModulePath().."/checkbot.lua", 2, "Força a verificação de bot em um usuario."  )
	addCommand( "nomedia"					, MODE_CHATADMS, getModulePath().."/nophoto.lua", 2, "Liga/Desliga proteção contra midia direta."  )
end



return antibot