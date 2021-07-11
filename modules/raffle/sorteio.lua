

function OnCommand(msg, text, args)
	if msg.chat and msg.chat.id and chats[msg.chat.id] then
		if not raffle.open[msg.chat.id] then
			raffle.open[msg.chat.id] = {}
		end

		text = collapse_command(args)

		if text:len() == 0 then 
			reply(tr("raffle-usage"))
			return
		end

		if not users[msg.from.id].telegramid then 
			reply(tr("raffle-no-permission"))
			return 
		end
		

		local sorteioId = os.time()

		local keyb = {}
		keyb[1] = {}
		keyb[2] = {}
		keyb[3] = {}
				

		keyb[1][1] = {text = tr("raffle-gen-winner"), callback_data = "sorte:"..sorteioId..":"..msg.chat.id..":g" }
		keyb[2][1] = {text =  tr("raffle-gen-sub"), callback_data = "sorte:"..sorteioId..":"..msg.chat.id..":i" }
		keyb[3][1] = {text = tr("raffle-gen-exit"), callback_data = "sorte:"..sorteioId..":"..msg.chat.id..":c" }
		local JSON = require("JSON")
		local kb = JSON:encode({inline_keyboard = keyb})
		local msg_pvt = bot.sendMessage(msg.from.id, tr("raffle-manager")..text, nil, true, false, nil, kb)

		if msg_pvt.ok then

			keyb = {}
			keyb[1] = {}			

			keyb[1][1] = {text = "🎈Participar🎈", callback_data = "sorte:"..sorteioId..":"..msg.chat.id..":j" }
			local JSON = require("JSON")
			local kb = JSON:encode({inline_keyboard = keyb})
			local msg2 = bot.sendMessage(g_chatid, raffle.renderSorteioMsg(text, {}, true), "HTML", true, false, nil, kb)
			if type(raffle.open[msg.chat.id]) == "string" then
				raffle.open[msg.chat.id] = {}
			end
			raffle.open[msg.chat.id][sorteioId] = {
				users = {},
				creator = msg.from.id,
				message_id = msg2.result.message_id,
				msg_pvt = msg_pvt.result,
				chatid = msg.chat.id,
				text = text,
				open=true,
			}
			raffle.save()
		end
	else 
		reply.html(tr("raffle-chat-only", math.random(0,100)))
	end
end

