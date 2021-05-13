local raffle = {
	open = {}
}

--[ONCE] runs when the load is finished
function raffle.load()
	raffle.open = configs["raffle"] or {}
end

--[ONCE] runs when eveything is ready
function raffle.ready()

end

--Runs at the begin of the frame
function raffle.frame()

end

--Runs some times
function raffle.save()
	configs["raffle"] = raffle.open
	SaveConfig("raffle")
end

function raffle.loadCommands()
	addCommand( {"sorteio", "raffle"}		, MODE_CHATADMS, getModulePath().."/sorteio.lua", 2 , "raffle-usage" )
end

function raffle.loadTranslation()
	g_locale[LANG_US]["raffle-desc"] = "Displaya cake"
	g_locale[LANG_BR]["raffle-desc"] = "Mostra um bolo"


	g_locale[LANG_US]["raffle-gen-winner"] = "⚙️Pull out a winner⚙️"
	g_locale[LANG_BR]["raffle-gen-winner"] = "⚙️Gerar um ganhador⚙️"


	g_locale[LANG_US]["raffle-gen-sub"] = "❗️Toggle entries❗️"
	g_locale[LANG_BR]["raffle-gen-sub"] = "❗️Encerrar/Abrir inscriçoes❗️"



	g_locale[LANG_US]["raffle-gen-exit"] = "❌Close raffle❌"
	g_locale[LANG_BR]["raffle-gen-exit"] = "❌Fechar sorteio❌"



	g_locale[LANG_US]["raffle-manager"] = "Raffle manager.\n\n"
	g_locale[LANG_BR]["raffle-manager"] = "Gerenciador de sorteio.\n\n"


	g_locale[LANG_US]["raffle-gen-chat-only"] = "This command only works on chats... But for you im gonna generate a random number between 0 and 100 and it is: <b>%s</b>!"
	g_locale[LANG_BR]["raffle-gen-chat-only"] = "Esse comando só funciona em chats... Mas não vou te deixar na mão. Sortearei um numero de 0 a 100, e ele é <b>%s</b>!"


	g_locale[LANG_US]["raffle-open"] = "✅Raffle is <b>OPEN</b>✅"
	g_locale[LANG_BR]["raffle-open"] = "✅Inscriçoes <b>ABERTAS</b>✅"


	g_locale[LANG_US]["raffle-closed"] = "❌Raffle is <b>CLOSED</b>❌"
	g_locale[LANG_BR]["raffle-closed"] = "❌Inscriçoes <b>ENCERRADAS</b>❌"


	g_locale[LANG_US]["raffle-message"] = "🎊<b>Raffle!</b>🎊\n%s\n<code>--------------------------------</code>\n%s\n<code>--------------------------------</code>\nWho is in: \n%s\n\n".."~🧸 %s"
	g_locale[LANG_BR]["raffle-message"] = "🎊<b>Sorteio!</b>🎊\n%s\n<code>--------------------------------</code>\n%s\n<code>--------------------------------</code>\nParticipantes: \n%s\n\n".."~🧸 %s"


	g_locale[LANG_US]["raffle-unkown"] = "Unknown raffle."
	g_locale[LANG_BR]["raffle-unkown"] = "Sorteio inexistente."

	g_locale[LANG_US]["raffle-in"] = "🎊You're in🎊"
	g_locale[LANG_BR]["raffle-in"] = "🎊Registrado🎊"

	g_locale[LANG_US]["raffle-left"] = "❌You left the raffle❌"
	g_locale[LANG_BR]["raffle-left"] = "❌Você saiu do sorteio❌"


	g_locale[LANG_US]["raffle-is-closed"] = "Raffle closed."
	g_locale[LANG_BR]["raffle-is-closed"] = "Sorteio encerrado!"

	g_locale[LANG_US]["raffle-already-in"] = "You are already in the raffle"
	g_locale[LANG_BR]["raffle-already-in"] = "Você ja está no sorteio!"

	g_locale[LANG_US]["raffle-now-open"] = "Raffle aberto!"
	g_locale[LANG_BR]["raffle-now-open"] = "Sorteio aberto!"

	g_locale[LANG_US]["raffle-now-closed"] = "Raffle closed"
	g_locale[LANG_BR]["raffle-now-closed"] = "Sorteio fechado"

	g_locale[LANG_US]["raffle-winner"] = "Chosen user: %s"
	g_locale[LANG_BR]["raffle-winner"] = "Usuário sorteado: %s"

	g_locale[LANG_US]["raffle-enter"] = "🎈Enter raffle🎈"
	g_locale[LANG_BR]["raffle-enter"] = "🎈Participar🎈"


	g_locale[LANG_US]["raffle-nousers"] = "There are no users in the raffle."
	g_locale[LANG_BR]["raffle-nousers"] = "Não há ninguem cadastrado no sorteio."


	g_locale[LANG_US]["raffle-no-permission"] = "I dont have permission to send private messages to you. Please send me a private message with /start"
	g_locale[LANG_BR]["raffle-no-permission"] = "Não tenho permissão para mandar mensagens para você. Mande /start no meu private"


	g_locale[LANG_US]["raffle-usage"] = "Use like this:\n/raffle Im raffling a thing. Im gonna announce the winner in 20 mins."
	g_locale[LANG_BR]["raffle-usage"] = "Use assim:\n/sorteio Sorteio valenddo algo! Vou sortear daqui 20 minutos."




	

end

function raffle.renderSorteioMsg(text, participantes, open)
	local par = ""
	local cnt = 0
	for i,b in pairs(participantes) do 
		par = par .. formatUserHtml({from=b})..", "
		cnt = cnt +1
		if cnt > 5 then 
			cnt = 0
			par = par.."\n"
		end
	end
	local insc = ""
	if open then 
		insc = tr("raffle-open")
	else
		insc = tr("raffle-closed")
	end
	return tr("raffle-message", insc, text, par, os.time())
end


function raffle.onCallbackQueryReceive(msg)
	if msg.message then

		local userid = msg.from.id
		local username = msg.from.name
		local sorteioId, chat, data = msg.data:match("sorte:(%d+):([%-%d]+):(.+)")

		if sorteioId then
			sorteioId = tonumber(sorteioId)
			local chatid = tonumber(chat)
			
			if not data or not chats[chatid] or not raffle.open[chatid] or not raffle.open[chatid][sorteioId] then 
				deploy_answerCallbackQuery(msg.id, tr("raffle-unkown"))
				--deploy_deleteMessage(obj.chatid, obj.message_id)
				deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
				raffle.save()
				return true
			end 
			loadLanguage(chatid)
			local obj = raffle.open[chatid][sorteioId]
			local keyb = {}
			keyb[1] = {}				

			keyb[1][1] = {text = tr("raffle-enter"), callback_data = "sorte:"..sorteioId..":"..chatid..":j" }
			local JSON = require("JSON")
			local kb = JSON:encode({inline_keyboard = keyb})

			if data == "c" then 
				deploy_answerCallbackQuery(msg.id, "Ok.")
				bot.sendMessage(obj.chatid, tr("raffle-is-closed"))
				

				deploy_deleteMessage(obj.chatid, obj.message_id)
				deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)

				raffle.open[chatid][sorteioId] = nil
			elseif data == "j" then 
				if obj.open then
					if type(obj.users) == "string" then 
						obj.users = {}
					end
					if not obj.users[userid] then
						obj.users[userid] = msg.from
						obj.users[userid].amount = 1
						deploy_answerCallbackQuery(msg.id, tr("raffle-in"))

						bot.editMessageText(obj.chatid, obj.message_id, nil, raffle.renderSorteioMsg(obj.text, obj.users, obj.open), "HTML", nil, kb)
						raffle.save()
					else 
						obj.users[userid].amount = obj.users[userid].amount +1

						if obj.users[userid].amount >= 3 then 
							obj.users[userid] = nil
							deploy_answerCallbackQuery(msg.id, tr("raffle-left"))
							bot.editMessageText(obj.chatid, obj.message_id, nil, raffle.renderSorteioMsg(obj.text, obj.users, obj.open), "HTML", nil, kb)
							raffle.save()
						else
							deploy_answerCallbackQuery(msg.id, tr("raffle-already-in"))
						end
					end
				else 
					deploy_answerCallbackQuery(msg.id, tr("raffle-is-closed"))
				end
			elseif data == "i" then 
				if obj.open then 
					bot.answerCallbackQuery(msg.id, tr("raffle-now-closed"))
					obj.open = false
					bot.editMessageText(obj.chatid, obj.message_id, nil, raffle.renderSorteioMsg(obj.text, obj.users, obj.open), "HTML", nil)
				else 
					bot.answerCallbackQuery(msg.id, tr("raffle-now-open"))
					obj.open = true
					bot.editMessageText(obj.chatid, obj.message_id, nil, raffle.renderSorteioMsg(obj.text, obj.users, obj.open), "HTML", nil, kb)
				end
			elseif data == "g" then 
				local us = {}
				for i,b in pairs(obj.users) do 
					us[#us+1] = i
				end
				if #us == 0 then 
					bot.answerCallbackQuery(msg.id, tr("raffle-nousers"))
					return true
				end

				local sort = us[math.random(1, #us)]
				local who = obj.users[sort]
				obj.users[sort] = nil

				deploy_answerCallbackQuery(msg.id, tr("raffle-winner", who.first_name ))
				

				bot.editMessageText(obj.chatid, obj.message_id, nil, raffle.renderSorteioMsg(obj.text, obj.users, obj.open), "HTML", nil, kb)

				bot.sendMessage(obj.chatid , tr("raffle-winner", formatUserHtml({from=who})) , "HTML",true,false, obj.message_id)
				raffle.save()
			
			end
			return true
		end
		return false
	end
	return false	
end


return raffle