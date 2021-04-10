
function OnCommand(msg, aaa, args, targetChat)

	local chatId = msg.chat.id
	msg.chat.id = targetChat
	local commandText = core.listCommandsFancy(msg)
	
	if msg.chat.type == "private" then
		local keyb = {}
		say("bingas")

		keyb[1] = {}
		keyb[1][1] = {text = tr("core-botmenu"), callback_data = "start:" .. (users[msg.from.id].lang == LANG_BR and "br" or "us") }

		local kb = cjson.encode({inline_keyboard = keyb})
		local ret = bot.sendMessage(chatId, tr("core-commands-commands", commandText), "HTML", true, false, nil, kb)
	else 
		if commandText:len() > 512 and (args[2] ~= "force") then 
			local keyb = {}
			keyb[1] = {}
			keyb[1][1] = {text = tr("Commands"), url = "https://telegram.me/burrsobot?start="..msg.chat.id.."_commands" }
			kb = cjson.encode({inline_keyboard = keyb })
			local ret = bot.sendMessage(msg.chat.id, tr("core-commands-big"), "HTML", true, false, nil, kb)
		else 
			say.html(tr("core-commands-commands", commandText))
		end
	end
end

