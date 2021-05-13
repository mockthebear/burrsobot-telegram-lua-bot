
function OnCommand(msg, text, args)
	if msg.chat and msg.chat.id and chats[msg.chat.id] then

		local target = nil
		
		local target, tgt = getTargetUser(msg)
	    if not target then 
	        return tgt and reply(tr("Quem é @%s?", tgt)) or reply("Use respondendo a uma mensagem de alguem ou /votekick @username") 
	    end 
	   
		local kicked = target.id

		local voteId = os.time()

		local keyb = {}


		local keyb = {}
		keyb[1] = {}				
		keyb[1][1] = {text = "✅Sim✅", callback_data = "kick:"..voteId..":"..kicked..":y" }
		keyb[1][2] = {text = "❌Não❌", callback_data = "kick:"..voteId..":"..kicked..":n" }
		local JSON = require("JSON")
		local kb = JSON:encode({inline_keyboard = keyb})
		local msg2 = bot.sendMessage(g_chatid, votekick.renderKickMsg({}, target), "HTML", true, false, nil, kb)

		votekick.kicks[voteId] = {
			users = {},
			target = target,
			creator = msg.from.id,
			msg = msg2.result,
			chatid = msg.chat.id,
		}
				--bot.pinChatMessage(msg.chat.id, msg2.result.message_id)
	else 
		reply("Esse comando só funciona em chats... Mas não vou te deixar na mão. Sortearei um numero de 0 a 100, e ele é *"..math.random(0,1000).."*!")
	end
end

