function OnCommand(msg, aaa, args)
	if msg.chat.type == "private" then
		local keyb = {}
		keyb[1] = {}
		keyb[1][1] = {text = "Portugues 🇧🇷", callback_data = "start:br" }
		keyb[1][2] = {text = "English 🇺🇸", callback_data = "start:us" }
		local JSON = require("JSON")
		local kb = JSON:encode({inline_keyboard = keyb})
		bot.sendMessage(msg.chat.id, "Hello. Before we start... Wich language do you use?\n\n*Oi, antes de começar, qual lingua você usa?*", "Markdown", true, false, nil, kb)
	else 
		local JSON = require("JSON")
		local keyb = {}
		keyb[1] = {}
		keyb[2] = {}
		keyb[1][1] = { text = "Usar no private", url = "https://telegram.me/burrsobot?start=start"} 
		kb = JSON:encode({inline_keyboard = keyb })
		bot.sendMessage(msg.chat.id, tr("default-start-chat"), "Markdown", true, false, nil, kb)
	end
end