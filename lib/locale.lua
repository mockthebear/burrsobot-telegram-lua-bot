g_locale = {}

function reloadLocalization()
	g_locale = {}
	StartLocalization()
	loadAuxiliarLibsLocalization()
end

function getLanguageName(id)
	return g_locale.langs[id] or "LANG_??"..id
end


function StartLocalization()
	print("[Locale] Loading localization")

	g_locale.langs = {}

	local langs = {["BR"] = {id=1,name="pt-br"}, ["US"] = {id=2,name="en"} }
	local last = 0
	for lang , data in pairs(langs) do 
		last = math.max(last, data.id )

		g_locale[data.id] = {
			__langname=data.name
		}
		g_locale.langs[data.id] = data.name 
		
		_G["LANG_"..lang] = data.id
	end

	_G["LANG_LAST"] = last

	g_lang = LANG_BR
	print("[Locale] Defaul language is "..g_locale[g_lang].__langname..":"..getLanguageName(g_lang))
	print("[Locale] Loading localized stuff.")
	loadDefaultLanguage()

	
end	

function detectLanguage(msg)
	if msg.from then 
		if msg.from.language_code then 
			for i,b in pairs(g_locale.langs) do 
				if msg.from.language_code == b then 
					return i
				end
			end
		end
	end
	return LANG_BR
end

function loadLanguage(chatid)
	g_lang = getUserLang({chat={id=chatid}, from={id=chatid}})
end 

function getUserLang(msg)
	if chats[msg.chat.id] then 
		return chats[msg.chat.id].lang
	end
	return users[msg.from.id].lang
end

function tr(word, ...)
    word = word or "" 
    local ret = g_locale[g_lang][word] or word
    local arg = {...}
    if arg[1] then 
        function f(...)
            ret = ret:format(...)
        end
        local ok,err = pcall(f,...)
        if not ok and err then 
            ret = ret .. "Error translating: "..err
        end
    end
    return ret
end



function loadDefaultLanguage()



g_locale[LANG_BR] = {
	["default-chat-only"] = "Desculpe, ese comando é apenas para chats.",


	["minute"] = "minuto",
	["minutes"] = "minutos",

	["default-command-chatdmin"] = "Somente admins do chat podem usar esse comando.\n<i>Essa mensagem será apagada em 15 segundos</i>.",
	["default-command-botadmin"] = "Somente admins do bot podem usar esse comando.\n<i>Essa mensagem será apagada em 15 segundos</i>.",
	["default-command-chatonly"] = "Esse comando é exclusivo para ser usado em chats.\n<i>Essa mensagem será apagada em 15 segundos</i>.",
	["default-command-disabled"] = "Esse comando está deshabilitado nesse chat.\n<i>Essa mensagem será apagada em 15 segundos</i>.",
	["default-command-nsfw"] = "Esse comando é classificado como NSFW e não pode ser enviado nesse chat. Mude isso com '/sfw no'\n<i>Essa mensagem será apagada em 15 segundos</i>.",

	["default-command-coldown"] = "Tá no coldown. Sem spammar plz :c\nPrecisa de ajuda com algum comando? Use <code>/help (nome do comando)</code>\nEsse comando tem <b>%s</b> segundos de coldown. Espere por mais <b>%s</b> segundos para usar de novo.",
	["default-start-chat"] = "Esse comando foi feito para ser usado no private comigo. Mas se o que estiver procurando é a lista de comandos use /commands aqui ou vá para o pvt.",

}
g_locale[LANG_US] = {
	["default-command-coldown"] = "Its on coldown. No spam plz :c\nIf you need help with some commands use <code>/help (command name)</code>\nThis command has <b>%s</b> seconds of coldown. Wait for more <b>%s</b> seconds and try again.",

	["default-command-chatdmin"] = "Only chat admins can use this command.\n<i>Message will be deleted in 15 seconds</i>.",
	["default-command-botadmin"] = "Only bot admins can use this command.\n<i>Message will be deleted in 15 seconds</i>.",
	["default-command-chatonly"] = "This command can only be executed in a chat.\n<i>Message will be deleted in 15 seconds</i>.",
	["default-command-disabled"] = "This command is disable on this chat.\n<i>Message will be deleted in 15 seconds</i>.",
	["default-command-nsfw"] = "This command is classified as NSFW and cant be send here. Use '/sfw no' to enable\n<i>Message will be deleted in 15 seconds</i>.",

	["default-chat-only"] = "Sorry, this command is for chats only.",
	["default-start-chat"] = "This command was meant to be used on private with me. But if you are looking for the commands list, just use /commands here or go to pvt.",

}


	
end