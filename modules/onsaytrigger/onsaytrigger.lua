local onsaytrigger = {
	priority = DEFAULT_PRIORITY+10000,
}

--[ONCE] runs when the load is finished
function onsaytrigger.load()

end

--[ONCE] runs when eveything is ready
function onsaytrigger.ready()

end

--Runs at the begin of the frame
function onsaytrigger.frame()

end

--Runs some times
function onsaytrigger.save()

end

function onsaytrigger.loadCommands()
	addCommand( "onsay"						, MODE_CHATADMS, getModulePath().."/onsay.lua", 2, "onsay-desc"  )
end

function onsaytrigger.loadTranslation()

	g_locale[LANG_BR]["onsay-desc"] = ""
	g_locale[LANG_US]["onsay-desc"] = ""

	g_locale[LANG_BR]["onsay-chatonly"] = "Esse comando é apenas para chats"
	g_locale[LANG_US]["onsay-chatonly"] = "This command is for chats only"

	g_locale[LANG_BR]["onsay-error"] = "Mensagem não pode ser salva por: %s"
	g_locale[LANG_US]["onsay-error"] = "Message could not be saved because: %s"

	g_locale[LANG_BR]["onsay-done"] = "Resposta salva para quaisquer frases contendo: %s"
	g_locale[LANG_US]["onsay-done"] = "Reply saved to any phrases containing: %s"

	g_locale[LANG_BR]["onsay-keywords"] = "Essas são as keywords definidas:\n%s"
	g_locale[LANG_US]["onsay-keywords"] = "These are your keywords:\n%s"

	g_locale[LANG_BR]["onsay-deleted"] = "Palavra chave '%s' removida"
	g_locale[LANG_US]["onsay-deleted"] = "Keyword '%s' removed"

	g_locale[LANG_BR]["onsay-missing-delete"] = "Faltou dizer qual a keyword você quer deletar"
	g_locale[LANG_US]["onsay-missing-delete"] = "You forgot to say which keyword you want to delete"

	g_locale[LANG_BR]["onsay-unknown-keyword"] = "Palavra chave '%s' não encontrada"
	g_locale[LANG_US]["onsay-unknown-keyword"] = "Keyword '%s' not found"

	
	g_locale[LANG_BR]["onsay-noparams"] = "Falta parâmetros no comando.\n%s"
	g_locale[LANG_US]["onsay-noparams"] = "Missing parameters.\n%s"

	g_locale[LANG_BR]["onsay-usage"] = "A forma de usar é a seguinte: <code>/onsay <i>\"palavra-chave\" \"resposta que o bot deve dar\"</i></code>\n\nAs aspas são essenciais ok?\n\nOutra forma de se usar e manter formatação nas mensagens é você usa o comando assim porém <b>RESPONDENDO A UMA MENSAGEM</b>: <code>/onsay \"palavra-chave\"</code>\n\nDessa forma a mensagem que você respondeu com o comando, vai ser a resposta do bot. Dessa forma a mensagem vai chegar como você mandou, com formatação e tudo."
	g_locale[LANG_US]["onsay-usage"] = "The usa of this command is: <code>/onsay <i>\"keyword\" \"reply to be given\"</i></code>\n\nThe quotes are essential ok?\n\nAnother way to use it and keep the formating in the message is the use the command like this <b>REPLYING ANOTHER MESSAGE</b>: <code>/onsay \"keyword\"</code>\n\nThis way the message you reply will be the bot reply and it will keep any formatting."
	
	g_locale[LANG_BR]["onsay-usage-plus"] = "\nExistem também como alterar algumas coisas:\n<code>/onsay clear</code> Deleta todas as configurações setadas\n<code>/onsay list</code> Exibe todas as configs setadas.\n<code>/onsay delete \"keyword\"</code> Deleta uma keyword setada\n"
	g_locale[LANG_US]["onsay-usage-plus"] = "\nThere is how to alter some stuff:\n<code>/onsay clear</code> Delete everything you set\n<code>/onsay list</code> List all set keywords\n<code>/onsay delete \"keyword\"</code> Delete one keyword\n\n"


	g_locale[LANG_BR]["onsay-desc"] = "Faz o bot responder a uma mensagem com outra. Você cadastra uma palavra cheave e sempre que ela for dita, o bot vai responder com o que você programou.\n"..g_locale[LANG_BR]["onsay-usage"]..g_locale[LANG_BR]["onsay-usage-plus"]
	g_locale[LANG_US]["onsay-desc"] = "Makes the bot reply a message with another. You register a keyword and every time someones says it the bot wil lreply with what you set."..g_locale[LANG_US]["onsay-usage"]..g_locale[LANG_US]["onsay-usage-plus"]
end


function onsaytrigger.onTextReceive(msg)
	if msg.isChat then 
		if type(chats[msg.chat.id].data.onSay) == "table" then 
			for i,b in pairs(chats[msg.chat.id].data.onSay) do 
				if ngx.re.match(msg.text, "(^|\\s)"..i.."($|\\s|,|\\.)") then
					if (i:sub(1,1) == '/' or msg.text:sub(1,1) ~= "/") then
						b = b:gsub("<user>", formatUserHtml(msg))
						reply.html(b)		
					end
				end		
			end
		end
	end
end

return onsaytrigger