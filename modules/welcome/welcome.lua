local welcome = {
	priority = DEFAULT_PRIORITY + 10000,
}
local JSON = require("JSON")

--[ONCE] runs when the load is finished
function welcome.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "welcome", {type="string", lenght=4024}, true, "Welcome message", "Welcoming")
	end
end

--[ONCE] runs when eveything is ready
function welcome.default_message()
	return "<user> "..tr("welcome-default")
end

--Runs at the begin of the frame
function welcome.frame()

end

--Runs some times
function welcome.save()

end

function welcome.loadCommands()
	--addCommand( {"bolo", "cake"}		, MODE_FREE,  getModulePath().."/bolo.lua", 2 , "Mostra um bolo" )
	--LoadCommand(nil, {"bolo", "cake"}, MODE_FREE, getModulePath().."/bolo.lua", 1, "Mostra um bolo" )
	addCommand( "setwelcome"				, MODE_CHATADMS, getModulePath().."/setwelcome.lua", 2, "welcome-command-helper"  )
	--addCommand( "setgoodbye"				, MODE_CHATADMS, getModulePath().."/setgoodbye.lua", 2, ""  )
	
end

function welcome.loadTranslation()
	g_locale[LANG_BR]["welcome-default"] = "seja bem viado! :3"
	g_locale[LANG_US]["welcome-default"] = "welcome! :3"



	g_locale[LANG_BR]["welcome-chat-rules"] = "Regras do chat"
	g_locale[LANG_US]["welcome-chat-rules"] = "Chat rules"

	g_locale[LANG_BR]["welcome-command-helper"] = "Define uma mensagem de boas vindas. Pode ser uma imagem, um vídeo (ambos com descrição), ou só um texto. Basta escrever uma mensagem linda de boas vindas e responder ela com /setwelcome.\n\nVocê pode incluir na mensagem <user> para que seja subistituido por uma menção a quem entrou, <name> para o nome da pessoa e <username> para o nome de usuário."
	g_locale[LANG_US]["welcome-command-helper"] = "Defines a welcome message to be sent when someone joins. Can be a photo, a video (both with captions), or just a text message. Just write a cute welcome message and reply it with /setwelcome \n\nYou can include in the message the <user> tag to be replaced to for a mention to the new member, <name> to be replaced with his name and <username> with his username."

	g_locale[LANG_BR]["welcome-set-message"] = "Definido nova mensagem de boas vindas:"
	g_locale[LANG_US]["welcome-set-message"] = "New welcome message was set:"

	g_locale[LANG_BR]["welcome-set-image"] = "Definido nova imagem de boas vindas:"
	g_locale[LANG_US]["welcome-set-image"] = "New welcome photo was set:"

	g_locale[LANG_BR]["welcome-set-sticker"] = "Definido novo sticker de boas vindas:"
	g_locale[LANG_US]["welcome-set-sticker"] = "New welcome sticker was set:"

	g_locale[LANG_BR]["welcome-set-document"] = "Definido novo documento de boas vindas:"
	g_locale[LANG_US]["welcome-set-document"] = "New welcome file was set:"

	g_locale[LANG_BR]["welcome-set-error"] = "Erro ao definir mensagem de boas vindas: %s\n\nTalvez você tenha esquecido de fechar um '<>'?"
	g_locale[LANG_US]["welcome-set-error"] = "Error upon setting welcome message: %s\n\nMaybe you forgot to close a '<>'?"


	g_locale[LANG_BR]["welcome-send-again-reply"] = "Envie o comando de novo dando reply à mensagem de boas vindas. Se necessario use `/help setwelcome`"
	g_locale[LANG_US]["welcome-send-again-reply"] = "Send the command again with a replying on the message that would be the welcome. If needed use `/help setwelcome`."


	g_locale[LANG_BR]["welcome-message-thisdefault"] = "---------------Essa é a mensagem de boas vindas atual--------------\n"
	g_locale[LANG_US]["welcome-message-thisdefault"] = "----------------This is the current welcome message----------------\n"

	--[[
	["Nova mensagem de boas vindas definida para: "] = "New welcome message set to: ",
	["Nova mensagem de boas vindas definida para uma imagem%s."] = "New welcome message set to as a image%s.",
	["Nova mensagem de boas vindas definida para um gif ou arquivo%s."] = "New welcome message set to as a file or gif%s.",
	["Nova mensagem de boas vindas definida para um sticker."] = "New welcome message set to a sticker.",
	[" e sua descrição contendo:\n%s\n\n:D\n"] = " and its description as:\n%s\n\n:D\n", 
	["Define um texto de boas vindas ao chat.\nPara setar, redija a mensagem, envie ela, e responda a ela com /setwelcome\n.O bot subistitue na mensagem algumas coisas.\nSe voce escrever <user> ou <username> ele subistitue pelo username.\n<name> ele subistitue pelo nome.\nÉ possivel usar só texto, gif, imagens ou arquivos."] = "Defines a welcome reply text thing to the chat.\nTo set, make the message then send it. Now reply the message with /setwelcome\nThe bot can replace some things.\nIf you type in it <user> or <username> it will be replaced by the new member username.\n<name> will be replaced by new member profile name.\nIts possible to use also images gifs sticker and even files that way. Just make sure to add a caption.",
	["Envie o comando de novo dando reply a mensagem de boas vindas. Se necessario use `/help setwelcome`"] = "",
	--/setgoodbye
	["Define um texto de adeus ao chat.\nPara setar, redija a mensagem, envie ela, e responda a ela com /setwelcome\n.O bot subistitue na mensagem algumas coisas.\nSe voce escrever <user> ou <username> ele subistitue pelo username.\n<name> ele subistitue pelo nome.\nÉ possivel usar só texto, gif, imagens ou arquivos."] = "Defines a goodbye reply text thing to the chat.\nTo set, make the message then send it. Now reply the message with /setwelcome\nThe bot can replace some things.\nIf you type in it <user> or <username> it will be replaced by the new member username.\n<name> will be replaced by new member profile name.\nIts possible to use also images gifs sticker and even files that way. Just make sure to add a caption.",
	["Envie o comando de novo dando reply a mensagem de boas vindas. Se necessario use `/help setgoodbye`"] = "Send the command again with a reply on the message. If needed use `/help setgoodbye`.",
	["Nova mensagem de adeus definida para: "] 				= "New goodbye message set to: ",
	["Nova mensagem de adeus definida para uma imagem%s."] 	= "New goodbye message set to as a image%s.",
	["Nova mensagem de adeus definida para um gif ou arquivo%s."] = "New goodbye message set to as a file or gif%s.",
	["Nova mensagem de adeus definida para um sticker."] 	= "New goodbye message set to a sticker.",
	]]


end


function welcome.rulesKeyboard(msg)
	local kb = nil
	g_lang = getUserLang(msg)

	if chats[msg.chat.id].data.rules then
		local keyb = {}
		keyb[1] = {}
		keyb[1][1] = { text = tr("welcome-chat-rules"), url = "https://telegram.me/burrsobot?start="..msg.chat.id.."_rules"} 
		kb = JSON:encode({inline_keyboard = keyb })
	end
	return kb
end


function welcome.format(text, user, chat)
	text = text:gsub("<user>", "<a href=\"tg://user?id="..user.id.."\">".. user.first_name:htmlFix().."</a>")
    text = text:gsub("<name>", user.first_name:htmlFix() )  
    text = text:gsub("<username>", user.originalUname and ("@"..user.originalUname) or formatUserHtml(user))
    text = text:gsub("<chat>", chat.title or "?") 
    return text
end


function welcome.SendWelcomeAndValidate(msg, kb, append)
	local ret = welcome.sendWelcomeMessage(msg, kb, append)
	if ret.ok == false then 
		return false, ret.description
	end
	return true, nil
end

function welcome.sendWelcomeMessage(msg, kb, append)
	if not chats[msg.chat.id] then 
		error("Invalid chat: "..msg.chat.id)
	end

	local usr = msg.new_chat_participant or msg.from 
    kb = kb or welcome.rulesKeyboard(msg)

    local chatWelcome = chats[msg.chat.id].data.welcome

    local text = (append or "")..((chatWelcome and chatWelcome:len() > 0) and chatWelcome or welcome.default_message())
	text = welcome.format(text, usr, msg.chat)

    if text:match("IIMI:(.-):(.+)") then
        local file, txt =  text:match("IIMI:(.-):(.+)")
        return bot.sendPhoto(msg.chat.id, file, txt, false, msg.message_id, kb, "HTML")
    elseif  text:match("IIDI:(.-):(.+)") then 
        local file, txt =  text:match("IIDI:(.-):(.+)")
        bot.sendDocument(msg.chat.id, file, txt, false, msg.message_id, kb, "HTML")
    elseif  text:match("STCKR:(.+)") then 
        local stckrId = text:match("STCKR:(.+)")
        return bot.sendSticker(msg.chat.id, stckrId, false, msg.message_id, kb)
    else
        local ret = bot.sendMessage(msg.chat.id, text, "HTML", true, false, msg.message_id, kb)

        if not chats[msg.chat.id].data.welcome and not kb then
            scheduleEvent(60, function()
                bot.deleteMessage(msg.chat.id, ret.result.message_id)
            end)  
        end

        return ret
    end

end

function welcome.onNewChatParticipant(msg)
	if msg.from.id ~= g_id then
		welcome.sendWelcomeMessage(msg)
	end
end


return welcome