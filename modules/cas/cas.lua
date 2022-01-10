local cas = {
	priority = DEFAULT_PRIORITY - 1000110,
	channel = "@burrbanbot"
}
local cjson = require("cjson")
--[ONCE] runs when the load is finished
function cas.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "disable_cas", {type="boolean"}, true, "Disable cas", "Anti-bot")
	end
end

--[ONCE] runs when eveything is ready
function cas.ready()

end

--Runs at the begin of the frame
function cas.frame()

end



function cas.onNewChatParticipant(msg)
	print("caspls")
	if (chats[msg.chat.id].data and chats[msg.chat.id].data.botProtection) then
		print("disabled cas: ")
		if not chats[msg.chat.id].data.disable_cas then 
			print("Checking cas: ")
			local res = httpsRequest("https://api.cas.chat/check?user_id="..msg.new_chat_participant.id)
			print("Cas gave us: "..tostring(res))
			if res then 
				local parsed = cjson.encode(res)
				if parsed then
					if parsed.ok then 
						say.admin('Banned '..formatUserHtml(msg)..' for beeing a bot on '..chats[msg.chat.id].title.." due CAS", "HTML", true, true, nil, kb)
            			bot.sendMessage(antibot.channel,'Banned '..formatUserHtml(msg)..' due cas.chat', "HTML")
            			--bot.kickChatMember(msg.chat.id, msg.new_chat_participant.id, os.time()+3600*24)
						--return KILL_EXECUTION
					end
				end
			end
		end
	end

end






function cas.loadTranslation()

	g_locale[LANG_BR]["cas-desc"] = "Quando um user novo entrar:\n- Se ele estiver sem username\n- Sem foto de perfil\n- Na blacklist\n- Sua primeira mensagem for uma midia\n- Sua primeira mensagem for um link\nO bot vai automaticamente apagar a mensagem dele\nO usuario será restrito de postar qualquer coisa no chat e um contador de 2 minutos inicia.\nO usuario terá que apertar um botão para provar que não é um bot de anuncio.\nQuando ele apertar o bloqueio sai e ele não é kickado.\n\nPara ligar isso, coloque o bot como admin ou com permissão de kickar e de restringir e deletar mensagens, use o comando /botprotection e pronto!"
	g_locale[LANG_US]["cas-desc"] = 'When a new user joins:\n- without profile pic\n- without username\n- on the blocklist\n- his first message contain media or link\nThe bot will lock this user and send him a button. If he dont presses it within 2 minutes he will be kicked.'



end





function cas.save()

end



function cas.loadCommands()

end



return cas