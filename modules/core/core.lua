local core = {
	priority = DEFAULT_PRIORITY,
	start_options = {
		{button="core-start-manage-button", reply="*growl*", tag="cg", callback = function(msg)
			return "core-helper-chatmanage"
		end },

		{button="core-start-command-button", reply="*rawr*", tag="cmd", callback = function(msg)
			return core.listCommandsFancy(msg)
		end }
	}
}


function core.addStartOption(buttonName, callbackReplyText, tag, callbackFunction)
	core.start_options[#core.start_options+1] = {button=buttonName, reply=callbackReplyText, tag=tag, callback = callbackFunction}
end

function core.load()
	if pubsub then 
		pubsub.registerExternalVariable("chat", "sfw", {type="boolean"}, true, "SFW", "General")
		--pubsub.registerExternalVariable("chat", "lang", {type="string", valid={"1", "2"}, default="1" }, true, "Action spam", "Nospam")
	end
end

--[ONCE] runs when eveything is ready
function core.ready()

end

--Runs at the begin of the frame
function core.frame()

end

--Runs some times
function core.save()

end

function core.loadCommands()
	addCommand( "privacy"						, MODE_FREE, getModulePath().."/chat/privacity.lua", 2, "core-privacity-desc" )
	addCommand( "disable"						, MODE_CHATADMS, getModulePath().."/chat/disable-command.lua", 2, "core-disable-desc" )
	addCommand( "enable"						, MODE_CHATADMS, getModulePath().."/chat/enable-command.lua", 2, "core-enable-desc" )
	addCommand( "disableall"					, MODE_CHATADMS, getModulePath().."/chat/disable-all.lua", 2 , "core-disableall-desc"  )
	addCommand( "security"						, MODE_CHATADMS, getModulePath().."/chat/security.lua", 2, "core-security-desc"  )
	addCommand( {"permissions", "permitions"}	, MODE_CHATADMS, getModulePath().."/chat/permitions.lua",7 , "Check permitions")	

	addCommand( {"sfw", "nsfw"}					, MODE_CHATADMS,  defaultToggleChatCommand("sfw", "core-sfw-desc-short"), 2 , "core-sfw-desc" )

	addCommand( "logger"						, MODE_CHATADMS, getModulePath().."/chat/logger.lua", 2, "core-logger-desc" )

	addCommand( "commands"					, MODE_FREE, getModulePath().."/list-commands.lua", 1 ,"core-commands-desc" )
	--addCommand( "donate"					, MODE_FREE, getModulePath().."/donate.lua",0 , "core-donate-desc")
	addCommand( "stats"						, MODE_FREE, getModulePath().."/stats.lua", 2 , "core-stats-desc")
	addCommand( {"ajuda", "help", "faq"}	, MODE_FREE, getModulePath().."/help.lua", 2 , "core-help-desc")	
	addCommand( "lang"						, MODE_FREE,  getModulePath().."/lang.lua", 2, "core-lang-desc" )
	addCommand( "invitelink"				, MODE_CHATADMS,  getModulePath().."/chat/link.lua", 2, "core-link-desc" )

	addCommand( "inspect"				, MODE_FREE,  getModulePath().."/chat/inspectadm.lua", 2, "core-inspect-desc" )
	addCommand( "backup"				, MODE_ONLY_ADM,  getModulePath().."/backup.lua", 2, "core-backup-desc" )
end



function core.loadTranslation()
	g_locale[LANG_US]["core-commands-desc"] = "Show all commands that can be used right now. The list might be different if you use in a chat because there are commands that only appear in chats."
	g_locale[LANG_BR]["core-commands-desc"] = "Mostra todos os comandos que podem ser usados agora. A lista pode ser diferente dependendo de onde você usar, alguns comandos só podem ser usados em chats."

	g_locale[LANG_US]["core-commands-onlychatadm"] = "(Only chat admins)"
	g_locale[LANG_BR]["core-commands-onlychatadm"] = "(Somente admins do chat)"

	g_locale[LANG_US]["core-commands-adms"] = "(Only bot owners)"
	g_locale[LANG_BR]["core-commands-adms"] = "(Apenas donos do bot)"

	g_locale[LANG_US]["core-commands-free"] = "(Free to use commands)"
	g_locale[LANG_BR]["core-commands-free"] = "(Comandos livres)"

	g_locale[LANG_US]["core-commands-nsfw"] = "(NSFW)"
	g_locale[LANG_BR]["core-commands-nsfw"] = "(NSFW)"

	g_locale[LANG_US]["core-commands-justhere"] = "(Just here)"
	g_locale[LANG_BR]["core-commands-justhere"] = "(Apenas aqui)"

	g_locale[LANG_US]["core-commands-commands"] = "Entãaaao, aqui estão os comandos:\n%s"
	g_locale[LANG_BR]["core-commands-commands"] = "SOOOO, here are my commands:\n%s"

	g_locale[LANG_US]["core-commands-big"] = "Hey, the command list might be too big... To avoid spam i can send it on your privae.... Or you can use */commands force* and i just send it here anyways."
	g_locale[LANG_BR]["core-commands-big"] = "Hey, a lista de comandos aqui é muito grande... Para evitar spam eu posso enviar-la no private para você... Ou simplesmente use */commands force* que eu mando aqui."

	g_locale[LANG_US]["core-botmenu"] = "Bot menu"
	g_locale[LANG_BR]["core-botmenu"] = "Bot menu"

	g_locale[LANG_US]["core-donate"] = "Maintain this bot costs me time and money, and im using my own to do it :D\nYou liked the bot? It helped you, made you laught?\nWhy not keep it improving by donating <3?"
	g_locale[LANG_BR]["core-donate"] = "Manter esse bot custa tempo e dinheiro, e eu to tirando do meu bolso pra manter ele up :D\nGostou do bot? Ele te fez rir? Ou te ajudou alguma vez?\nQuer ajudar ele a continuar melhorando? Doa ae <3"

	g_locale[LANG_US]["core-stats-desc"] = "Show bot stats"
	g_locale[LANG_BR]["core-stats-desc"] = "Mostra stats do bot"

	g_locale[LANG_US]["core-donate-desc"] = "Command to help donate"
	g_locale[LANG_BR]["core-donate-desc"] = "Comando para ajudar a doar"

	g_locale[LANG_US]["core-help-desc"] = "Help with something?"
	g_locale[LANG_BR]["core-help-desc"] = "Ajuda com algo?"

	g_locale[LANG_US]["core-help-how"] = "To get help, use the command like this: \n/help (command name)\n/help random\n/help disable\n/help setwelcome\n\nTo check the commands, use /commands"
	g_locale[LANG_BR]["core-help-how"] = "Para receber ajuda favor usar o comando assim:\n/ajuda (nome do comando)\n/ajuda random\n/ajuda addmeme\n\nPara checar os comando existentes use /commands"

	g_locale[LANG_US]["core-help-nocmd"] = "Sorry there is no command called %s or /%s.\nTo check commans use /commands"
	g_locale[LANG_BR]["core-help-nocmd"] = "Desculpe, nem um comando chamado %s ou /%s foi encontrado.\nPara checar os comando existentes use /commands"

	g_locale[LANG_US]["core-help-command"] = "The command <b>/%s</b> have <b>%d</b> seconds of cooldown\n\n<code>%s</code>"
	g_locale[LANG_BR]["core-help-command"] = "O comando <b>/%s</b> possuí <b>%d</b> segundos de cooldown.\n\n<code>%s</code>"

	g_locale[LANG_US]["core-lang-desc"] = "Define chat language. Use just '/lang' to see all avaliable laguages and /lang (name) to set"
	g_locale[LANG_BR]["core-lang-desc"] = "Define a linguagem do chat. Use apenas '/lang' para ver as linguagens disponiveis. E use /lang (nome) para definir uma"

	g_locale[LANG_US]["core-lang-nosuch"] = "Sorry this language is not supported.\nSupported languages: %s"
	g_locale[LANG_BR]["core-lang-nosuch"] = "Desculpe, essa lingua não é suportada.\nLinguagens suportadas: %s"

	g_locale[LANG_US]["core-lang-avaliable"] = "Supported languages: %s"
	g_locale[LANG_BR]["core-lang-avaliable"] = "Linguagens suportadas: %s"

	g_locale[LANG_US]["core-lang-private"] = "Your language is set to <b>%s</b>. (Private chats only)\nSupported languages: %s"
	g_locale[LANG_BR]["core-lang-private"] = "Sua linguagem foi alterada para <b>%s</b>. (Mensagem privada apenas)\nLinguagens suportadas: %s"

	g_locale[LANG_US]["core-lang-chat"] = "Chat language is set to <b>%s</b>\nSupported languages: %s"
	g_locale[LANG_BR]["core-lang-chat"] = "Linguagem do chat foi definida para <b>%s</b>\nLinguagens suportadas: %s"

	g_locale[LANG_US]["core-disable-show"] = "Disabled commands on this chat:\n%s"
	g_locale[LANG_BR]["core-disable-show"] = "Comandos desabilitados nesse chat:\n%s"

	g_locale[LANG_US]["core-disable-unknown"] = "Unknown /%s command"
	g_locale[LANG_BR]["core-disable-unknown"] = "Comando /%s desconhecido"

	g_locale[LANG_US]["core-disable-noadm"] = "You cant disable an admin only command."
	g_locale[LANG_BR]["core-disable-noadm"] = "Você não pode desligar um comando que é só para admin."

	g_locale[LANG_US]["core-disable-disabled"] = "Commando /%s disabled.\n\nDisabled commands on this chat:\n%s\n\nTo revert this use /enable"
	g_locale[LANG_BR]["core-disable-disabled"] = "Comando /%s desabilitado.\n\nComandos desabilitados nesse chat:\n%s\n\nPara reverter use /enable"

	g_locale[LANG_US]["core-disable-nodisabled"] = "This command is already disabled.\n\nTo revert this use /enable"
	g_locale[LANG_BR]["core-disable-nodisabled"] = "Esse comando já está habilitado.\n\nPara reverter use /enable"

	g_locale[LANG_US]["core-disable-noenabled"] = "This command is already disabled."
	g_locale[LANG_BR]["core-disable-noenabled"] = "Esse comando já está desabilitado."

	g_locale[LANG_US]["core-disable-clear"] = "All non admin commands were enabled again."
	g_locale[LANG_BR]["core-disable-clear"] = "Todos os comandos que não são de admin foram habilitados."

	g_locale[LANG_US]["core-disable-all"] = "A total of %s commands were disabled.\nAll non admin commands were enabled disabled.\nTo revert this you can either use <code>/disableall clear</code> or use <code>/enable (commando)</code> to a single command."
	g_locale[LANG_BR]["core-disable-all"] = "Um total de %s comandos foram desabilitados.\nTodos os comandos que não são de admin foram desabilitados.\nPara reverter você pode user <code>/disableall clear</code> ou usar <code>/enable (commando)</code> para liberar um comando especifico."

	g_locale[LANG_US]["core-disable-desc"] = "Disable a single command. Use like: /disable (command)"
	g_locale[LANG_BR]["core-disable-desc"] = "Desabilita um unico comando. Use assim: /disable comando"

	g_locale[LANG_US]["core-enable-desc"] = "Enable a single command. Use like: /enable (command)"
	g_locale[LANG_BR]["core-enable-desc"] = "Habilita um unico comando. Use assim: /enable comando"

	g_locale[LANG_US]["core-disableall-desc"] = "Disable all non admin commands. Use like: /disableall\nIf you want to clear all disabled commands use '/disableall clear'"
	g_locale[LANG_BR]["core-disableall-desc"] = "Desliga todos os comandos que não são de admins. Use assim: /disableall\nSe você quiser liberar todos os comandos, use '/disableall clear'"

	g_locale[LANG_US]["core-start-bot"] = "Hi im burrbot and im gay."
	g_locale[LANG_BR]["core-start-bot"] = "Oi eu sou burrbot e sou gay."

	g_locale[LANG_US]["core-start-botreply"] = "Language set. "
	g_locale[LANG_BR]["core-start-botreply"] = "Linguagem definita. "

	g_locale[LANG_US]["core-start-welcome-header"] = "<b>Burrbot V4.0</b>\n"
	g_locale[LANG_BR]["core-start-welcome-header"] = "<b>Burrbot V4.0</b>\n"

	g_locale[LANG_US]["core-start-addbot-button"] = "🧾Add me on your chat🧾"
	g_locale[LANG_BR]["core-start-addbot-button"] = "🧾Adicionar bot no seu chat🧾"
	
	g_locale[LANG_US]["core-start-home"] = "What do you want to know or do?"
	g_locale[LANG_BR]["core-start-home"] = "O que você quer saber ou fazer?"
	
	g_locale[LANG_US]["core-start-awnser-home"] = "UwU"
	g_locale[LANG_BR]["core-start-awnser-home"] = "UwU"
	
	g_locale[LANG_US]["core-start-manage-button"] = "Chat management stuff"
	g_locale[LANG_BR]["core-start-manage-button"] = "Gerenciamento de chats"
	
	g_locale[LANG_US]["core-helper-chatmanage"] = "I can help manage your chat, send welcome messages to who joins (/setwelcome), or manage rules using /rules. I also can protect from bots (/botprotection). If you want, just add me to the chat and use /painel so you can change all those juicy settings in a web page."
	g_locale[LANG_BR]["core-helper-chatmanage"] = "Esse bot pode ajudar a gerenciar o seu chat, dando mensagem de boas vindas para quem entra com o comando /setwelcome, pode exibir regras usando /rules. Também há proteção de bot com /botprotection. Se quiser configurar tudo é só usar /painel dentro do chat que eu vou mandar um link para um site onde você pode fazer tudo com calma :3"
	
	g_locale[LANG_US]["core-start-home-button"] = "↩️Back↩️"
	g_locale[LANG_BR]["core-start-home-button"] = "↩️Voltar↩️"
	
	g_locale[LANG_US]["core-start-command-button"] = "Bot Commands"
	g_locale[LANG_BR]["core-start-command-button"] = "Comandos do bot"
	
	g_locale[LANG_US]["core-security-active"] = "✅active✅"
	g_locale[LANG_BR]["core-security-active"] = "✅ativo✅"
	
	g_locale[LANG_US]["core-security-inactive"] = "❌inactive❌"
	g_locale[LANG_BR]["core-security-inactive"] = "❌inactivo❌"
	
	g_locale[LANG_US]["core-security-permissions"] = "Bot permissions:"
	g_locale[LANG_BR]["core-security-permissions"] = "Permissões do bot:"
	
	g_locale[LANG_US]["core-security-candel"] = "Can <b>delete messages: %s</b>\n"
	g_locale[LANG_BR]["core-security-candel"] = "Pode <b>Deletar mensagens: %s</b>\n"
	
	g_locale[LANG_US]["core-security-cankick"] = "Can <b>restrict members: %s</b>\n"
	g_locale[LANG_BR]["core-security-cankick"] = "Pode <b>restringir membros: %s</b>\n"
	
	g_locale[LANG_US]["core-security-fail"] = "\n❌❌Cannot perform any actions because i dont have the permissions to :/❌❌"
	g_locale[LANG_BR]["core-security-fail"] = "\n❌❌Cannot perform any actions because i dont have the permissions to :/❌❌"
	
	g_locale[LANG_US]["core-security-coms"] = "Security commands:\n"
	g_locale[LANG_BR]["core-security-coms"] = "Comandos de segurança de chat:\n"
	
	g_locale[LANG_US]["core-logger-desc"] = "Used to log chat messages. Comes disabled by default\nUse like this:\n/logger on|off  - to turn on off\n/logger get  - to send the log file in the chat\n/logger erase - to erase the log\n/logger pget - to send the file on your private"
	g_locale[LANG_BR]["core-logger-desc"] = "Usado para salvar as mensagens do chat. Vem desligado por padrão.\nUse assim:\n/logger on|off  - para ligar desligar logging\n/logger get  - para enviar o arquivo de log no chat\n/logger erase - para apagar arquivo de log\n/logger pget - para enviar o arquivo via private"
	
	g_locale[LANG_US]["core-sfw-desc"] = "Toggles the SFW/NSFW commands and other modes"
	g_locale[LANG_BR]["core-sfw-desc"] = "Habilita desabilita os comandos e modos NSFW"	

	g_locale[LANG_US]["core-sfw-desc-short"] = "SFW mode"
	g_locale[LANG_BR]["core-sfw-desc-short"] = "Modo sfw"
	
	g_locale[LANG_US]["core-privacity"] = [[Information about you:

Burrbot will store the following data: 
* Basic user information thats avaliable to the bots (userid, name, username, no profile pictures)
* Command cached data. Command like /today command or /comer, need to know when they need to change the results... Other commands need to store some information, so you can have more information stored related to those commands that need to 'remember' something.   
* If you join a chat with the bot it will store the date you joined the chat for the antibot feature dont detect something backwards
* Any command sent to the bot private will be logged for debugging and anti abuse reasons.
* When using the command /panel, the panel itself is a webpage outside telegram, therefore your IP address might be visible to the hosting provider. 
* Any text message sent to the bot private MIGHT be visible to the bot owner while debugging. 
* Banlist information. If you endup in a 'raid ban list' for beeing a pedo/zoo/nazi/raider, a flag will be stored saying you're in the list. 

Information about chats:

* This bot do not log the chat messages UNLESS one administrator use the command '/logger on'. This option comes as default as disabled. 
* The metrics option store on which date a message appear on the chat, to generate graphs and stuff. It does not store messages.  This option comes as default as disabled. 
* Any command used with burrbot in a chat will be logged for debugging and anti abuse reasons. 
* Any chat the bot is added, it will be visible to the bot administrators and can be stored: Name, Id, Description, Profile picture, Member count and administrators. Other than that and commands, nothing else is stored. 
]]
	g_locale[LANG_BR]["core-privacity"] = [[O Burrbot armazenará os seguintes dados:

* Informações básicas do usuário disponíveis para os bots (ID do usuário, nome, nome de usuário, sem fotos de perfil).
* Dados em cache dos comandos. Comandos como /today ou /comer precisam saber quando mudar os resultados... Outros comandos precisam armazenar algumas informações para que você possa ter mais informações relacionadas a esses comandos que precisam "lembrar" de algo.
* Se você entrar em um chat com o bot, ele armazenará a data de entrada no chat para que o recurso antibot não detecte algo incorretamente.
* Qualquer comando enviado ao bot em privado será registrado para fins de depuração e prevenção de abuso.
* Ao usar o comando /panel, o painel em si é uma página da web fora do Telegram, portanto, seu endereço IP pode ser visível para o provedor de hospedagem.
* Qualquer mensagem de texto enviada ao bot em privado PODE ser visível para o proprietário do bot durante a depuração.
* Informações da lista de banimentos. Se você acabar em uma "lista de banimento de invasão" por ser pedo/zoo/nazi/raider, será armazenada uma marcação indicando que você está na lista.

Informações sobre chats:

* Este bot não registra as mensagens do chat, A MENOS que um administrador use o comando '/logger on'. Esta opção vem desativada por padrão.
* A opção de métricas armazena a data em que uma mensagem aparece no chat, para gerar gráficos e outras estatísticas. Não armazena mensagens. Esta opção vem desativada por padrão.
* Qualquer comando usado com o Burrbot em um chat será registrado para fins de depuração e prevenção de abuso.
* Qualquer chat ao qual o bot seja adicionado será visível para os administradores do bot e pode ser armazenado: Nome, ID, Descrição, Foto de perfil, Contagem de membros e administradores. Além disso e dos comandos, nada mais é armazenado.]]
	



	local texta = [[
🇧🇷 

<code>---------------------------------------</code>


<code>---------------------------------------</code>

•  Default language set to %s 🇧🇷 use /lang to change


Support: https://t.me/P7OiXemr_Ts5YTBh

🐻 Burrbot V4.0 by @Mockthewah~
]]
	


	g_locale[LANG_US]["core-bot-added"] = [[🇺🇸 <b>Thanks for adding me on this chat!</b>

To alter any config mine or about the chat you can do it using commands or trought the panel using <b>/panel</b>
• <i>Any command i have or feature can be individually disabled</i> if you feel there are too much spam or useless. Commands can be disabled using /disable or /disableall
• If you are after protection features you can check them trought /painel or /security
• Now if you are after the utilities you can use /commands to check all commands. If you have any questions you use /help (commands)

<b>Reccomended configure bot trought /panel command</b>

Updates: https://t.me/burrso
Support group: https://t.me/P7OiXemr_Ts5YTBh
🐻 Burrbot V4.1 by @Mockthewah~
]]
	g_locale[LANG_BR]["core-bot-added"] = [[<b>Obrigado por me adicionar nesse chat!</b>

Para alterar quaisquer configs minhas ou do chat você pode faze-lo por comandos ou pelo painel usando <b>/painel</b>
•  <i>Todos os comandos e features que eu tenho podem ser desligadas individualmente</i> se você achar que é muito spam ou desnecessários. Comandos por exemplo podem ser desabilitados usando /disable ou /disableall.
•  Se estiver procurando proteção, você pode visualizar pelo /painel ou usando /security
• Agora se o que você quer é as utilidades basta usar /commands que eu mando a lista completa de comandos. E se tiver alguma duvida, basta usar /help (comando)


<b>Recomendado configurar o bot pelo comando /painel</b>

Updates: https://t.me/burrso
Grupo de suporte: https://t.me/P7OiXemr_Ts5YTBh
🐻 Burrbot V4.1 by @Mockthewah~
]]
	
	g_locale[LANG_US]["core-open-panel"] = "🎛Open control panel🎛"
	g_locale[LANG_BR]["core-open-panel"] = "🎛Abrir painel de controle🎛"
	
	g_locale[LANG_US][""] = ""
	g_locale[LANG_BR][""] = ""
	
	g_locale[LANG_US][""] = ""
	g_locale[LANG_BR][""] = ""
	
	g_locale[LANG_US][""] = ""
	g_locale[LANG_BR][""] = ""
	
	g_locale[LANG_US][""] = ""
	g_locale[LANG_BR][""] = ""
	
	g_locale[LANG_US][""] = ""
	g_locale[LANG_BR][""] = ""
	
	g_locale[LANG_US][""] = ""
	g_locale[LANG_BR][""] = ""
	
	g_locale[LANG_US][""] = ""
	g_locale[LANG_BR][""] = ""
	


end


function core.listCommandsFancy(msg)
	local nameMap = {
		[MODE_CHATADMS] = tr("core-commands-onlychatadm"),
		[MODE_ONLY_ADM] = tr("core-commands-adms"), 
		[MODE_FREE] = tr("core-commands-free"), 
		[MODE_NSFW] = tr("core-commands-nsfw"), 
		[msg.chat.id] = tr("core-commands-justhere"),
	}

	local groups = {MODE_CHATADMS, MODE_ONLY_ADM, MODE_FREE, msg.chat.id}
	local coms = listCommandsContext(msg, groups)
	
	local commandText = ""
	for i=1, #groups do
		local cmdType = groups[i]
		if #coms[cmdType] > 0 then
			commandText = commandText .."<code>-----"..nameMap[cmdType].."-----</code>\n"
		end
		local perLine = 1
		for _, words in pairs(coms[cmdType]) do
			commandText = commandText .. "  /"..thisOrFirst(words, LANG_US) .. (perLine%4 == 0 and "\n" or "")
			perLine = perLine +1
		end
		if #coms[cmdType] > 0 then
			commandText = commandText .. "\n"
		end
		
	end
	return commandText
end
function core.plsDonate()
    bot.sendSticker(g_chatid, "CAADBQAD1hYAAp7UXgMal_LjVGO6_QI")

    local keyb2 = {}
    keyb2[1] = {}
    keyb2[2] = {}
    keyb2[3] = {}

    keyb2[1][1] = {text = tr("Paypal"), callback_data = "dnt:paypal" } 
    keyb2[2][1] = {text = tr("Pix"), callback_data = "dnt:pix" } 
    keyb2[3][1] = {text = tr("PicPay"), url = "http://picpay.me/mockthebear" } 


    local kb2 = cjson.encode({inline_keyboard = keyb2})
    local ret = bot.sendMessage(g_chatid, tr("core-donate"), "", true, false, nil, kb2)
end



function core.renderStartMessage(justHome, hideHome, custom)
	local txt = tr("core-start-welcome-header")

	local keyb = {}

	if not justHome then
		for i, option in pairs(core.start_options) do 
			keyb[#keyb+1] = {}
			keyb[#keyb][1] = {text = tr(option.button), callback_data = "start:"..option.tag }
		end
				
		keyb[#keyb+1] = {}
		keyb[#keyb][1] = {text = tr("core-start-addbot-button"), url = "http://t.me/"..g_botname.."?startgroup=start" }
	end

	if custom then 
		keyb[#keyb+1] = {}
		keyb[#keyb][1] = {text = tr(custom.button), callback_data = "start:"..custom.tag }
	end
	if not hideHome then
		keyb[#keyb+1] = {}
		keyb[#keyb][1] = {text = tr("core-start-home-button"), callback_data ="start:home" }
	end

	local kb = cjson.encode({inline_keyboard = keyb})

	return txt, kb
end

function core.findActionByTag(tag)
	for i,b in pairs(core.start_options) do 
		if b.tag == tag then 
			return b
		end
	end
end

function core.onCallbackQueryReceive(msg)
	local mode = msg.data:match("start:(.+)")

	--print("EEEEE", cjson.encode(msg))

	if mode and msg.message then
		
		if not users[msg.from.id] then 
			deploy_answerCallbackQuery(msg.id, "Internal error: "..tostring(msg.from.id), true)
			return
		end

		g_lang = getUserLang(msg)

		if mode == "br" or mode == "us" then
			
			users[msg.from.id].lang = mode == "br" and LANG_BR or LANG_US
			g_lang = users[msg.from.id].lang

			deploy_answerCallbackQuery(msg.id, tr("core-start-botreply"), "true")
			SaveUser(msg.from.id)

			local txt, kb = core.renderStartMessage()
			local k = bot.editMessageText(msg.message.chat.id, msg.message.message_id, nil, txt..tr("core-start-bot"), "HTML", nil, kb)
		elseif core.findActionByTag(mode) then 
			local action = core.findActionByTag(mode)
			deploy_answerCallbackQuery(msg.id, tr(actionreply))
			local text = (action.callback and action.callback({
				chat = msg.message.chat,
				from = msg.from,
				message_id=  msg.message.message_id
			}) or "") or ""

			local txt, kb = core.renderStartMessage(true, false, action.customButton)
			bot.editMessageText(msg.message.chat.id, msg.message.message_id, nil, txt..tr(text), "HTML", nil, kb)
		else
			deploy_answerCallbackQuery(msg.id, tr("core-start-awnser-home"))
			local text = tr("core-start-bot")

			local txt, kb = core.renderStartMessage(false, true)
			bot.editMessageText(msg.message.chat.id, msg.message.message_id, nil, txt..text, "HTML", nil, kb)
		end
		return KILL_EXECUTION
	elseif msg.data:match("chatlang:(.+)") then
		local lang = msg.data:match("chatlang:(.+)")
		local chatid = msg.message.chat.id  
		deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
		deploy_answerCallbackQuery(msg.id, "Ok: "..lang)
		if chats[chatid] then
			if lang == 'pt-br' then  
				chats[chatid].data.lang = LANG_BR
			else 
				chats[chatid].data.lang = LANG_US
			end
			g_lang = chats[chatid].data.lang
			
			local keyb = {}
			keyb[1] = {}
			keyb[2] = {}
			keyb[3] = {}

			keyb[1][1] = {text = tr("core-open-panel"), callback_data = "panel:token" }
		    keyb[2][1] = {text ="Commands/Comandos", url = "https://telegram.me/burrsobot?start="..chatid.."_commands" }
		    keyb[3][1] = {text =tr("core-start-addbot-button"), url = "http://t.me/"..g_botname.."?startgroup=start" }


			local kb = cjson.encode({inline_keyboard = keyb})
			bot.sendMessage(chatid, tr("core-bot-added"), "HTML", true, false, nil, kb)
		end
		return KILL_EXECUTION
	elseif msg.data:match("dnt:(.+)") then
		local kd = msg.data:match("dnt:(.+)")
		local wat = {
			['paypal'] = 'matheus_diodo@hotmail.com',
			['pix'] = 'aa5970f8-eac5-4e01-ba9b-c3cf250ac72f',
		}
		if wat[kd] then
			deploy_answerCallbackQuery(msg.id, wat[kd], "true")
		else 
			deploy_answerCallbackQuery(msg.id, "?ué")
		end
		return		 
	end
end



function core.onNewChat(msg)


	local text = [[Obrigado por adicionar o burrbot 🐻🤖!
<b>Primeiro, defina a linguagem 👀</b>

Thanks for addind burrbot 🐻🤖!
<b>First define the language 👀</b>

OwO]]
	
	local keyb = {}
	keyb[1] = {}
	keyb[2] = {}

	keyb[1][1] = {text = tr("PT-BR 🇧🇷"), callback_data = "chatlang:pt-br" }
    keyb[2][1] = {text = tr("English 🇺🇸"), callback_data = "chatlang:en" }

	--keyb[1][1] = {text = "Bot/chat panel", url = "https://telegram.me/burrsobot?start="..msg.chat.id.."_painel" }
	--keyb[2][1] = {text ="Commands/Comandos", url = "https://telegram.me/burrsobot?start="..msg.chat.id.."_commands" }
	local kb = cjson.encode({inline_keyboard = keyb})
	
	bot.sendMessage(msg.chat.id, text:format(g_locale.langs[chats[msg.chat.id].lang]), "HTML", true, false, nil, kb)


end




	
	

return core