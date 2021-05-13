local module = {
	require = {
		os = {
			"google_speech"
		}
	}
}

--[ONCE] runs when the load is finished
function module.load()

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

function module.loadCommands()
	addCommand( "revive"				, MODE_FREE, getModulePath().."/revive.lua", 2 , "useless-revive-desc")

	addCommand( "fursona"				, MODE_FREE, getModulePath().."/fursona.lua",2 , "useless-fursona-desc")
	addCommand( "ship"					, MODE_FREE, getModulePath().."/ship.lua",10 , "useless-ship-desc")
	addCommand( "namegen"				, MODE_FREE, getModulePath().."/name.lua", 4 ,  "useless-name-desc")

	addCommand( "complete"				, MODE_FREE,  getModulePath().."/completa.lua", 2, "useless-complete-desc" )
	addCommand( "tts"					, MODE_FREE,  getModulePath().."/tts.lua", 4, "useless-tts-desc" )
	addCommand( {"cruzar", "mix"}		, MODE_FREE,  getModulePath().."/cruzar.lua", 4, "useless-mix-desc" )
	addCommand( {"treta","drama"}		, MODE_FREE,  getModulePath().."/treta.lua", 4, "useless-drama-desc" )
end

function module.loadTranslation()
	g_locale[LANG_US]["useless-revive-desc"] = "Revive an old message... Basically it grabes a random message and reply~"
	g_locale[LANG_BR]["useless-revive-desc"] = "Revive uma conversa... Basicamente pega alguma mensagem aleatoria do chat e responde ela."

	g_locale[LANG_US]["useless-fursona-desc"] = "Proceduarally generates a fursona"
	g_locale[LANG_BR]["useless-fursona-desc"] = "Cria proceduralmente um fursona."

	g_locale[LANG_US]["useless-ship-desc"] = "Ship you with a random person"
	g_locale[LANG_BR]["useless-ship-desc"] = "Shippa você com alguem aleatório"

	g_locale[LANG_US]["useless-name-desc"] = "Generate 10 names."
	g_locale[LANG_BR]["useless-name-desc"] = "Gera proceduralmente 10 nomes."

	g_locale[LANG_US]["useless-complete-desc"] = "Uses GPT-3 IA to complete a message"
	g_locale[LANG_BR]["useless-complete-desc"] = "Usa IA GPT-3 para completar uma mensagem. (Somente em inglês)"

	g_locale[LANG_US]["useless-tts-desc"] = "Text to speech. Can select language using: /tts lang=ja <message here>"
	g_locale[LANG_BR]["useless-tts-desc"] = "Texto para fala. Dá para selecionar linguagem usando: /tts lang=ja <message here>"

	g_locale[LANG_US]["useless-tts-lang"] = "Invalid language, use one of these: <code>%s</code>"
	g_locale[LANG_BR]["useless-tts-lang"] = "Lingua inválida, use uma dessas: <code>%s</code>" 

	g_locale[LANG_US]["useless-mix-desc"] = "Command to mix two persons.\nUse like this: /cruzar james matthew"
	g_locale[LANG_BR]["useless-mix-desc"] = "Comando para misturar 2 nomes.\nUse assim: /cruzar batata bolo"

	g_locale[LANG_US]["useless-mix-outcome"] = "*%s* mixed with *%s* and become: *%s%s*"
	g_locale[LANG_BR]["useless-mix-outcome"] = "*%s* casou com *%s* e nasceu: *%s%s*"

 
	g_locale[LANG_US]["Gerando proceduralmente um fursona"] = "Generating a fursona"
	g_locale[LANG_US][" para o @"] = " to @"
	g_locale[LANG_US][" usando a seed "] = " using the seed "
	g_locale[LANG_US]["O fursona se chama "] = "The fursona name is "
	g_locale[LANG_US]["ele"] = "he"
	g_locale[LANG_US]["ela"] = "she"
	g_locale[LANG_US][" é "] = " is a "
	g_locale[LANG_US]["um misto de "] = "a mix of "
	g_locale[LANG_US][" de cor "] = " and its color is "
	g_locale[LANG_US][" de cores "] = " and its colors are "
	g_locale[LANG_US][" gosta de "] = " likes "
	g_locale[LANG_US][" e o seu sonho é "] = " and its biggest dream is to "
	g_locale[LANG_US][" e "] = " and "


end


return module