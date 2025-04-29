

local rules = {}

--[ONCE] runs when the load is finished
function rules.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "rules", {type="string", length=4024, fancy=true}, true, {"As regras do seu chat", "The rules of your chat"}, "Rules")
		pubsub.registerExternalVariable("chat", "rulesPvt", {type="boolean"}, true, {"Mostrar regras em privado ao usar /rules", "Show rules on private when using /rules"}, "Rules")
	end
end

--[ONCE] runs when eveything is ready
function rules.ready()

end

--Runs at the begin of the frame
function rules.frame()

end

--Runs some times
function rules.save()

end

function rules.loadCommands()
	addCommand( {"regras", "rules"}					, MODE_FREE, getModulePath().."/view-rules.lua", 2 , "rules-show-desc" )
	addCommand( {"setarregras", "setrules"}			, MODE_CHATADMS, getModulePath().."/set-rules.lua", 2, "rules-set-desc" )
end

function rules.loadTranslation()
	g_locale[LANG_BR]["rules-no-rules-set"] = "Nenhuma regra setada. Use /setrules para definir"
	g_locale[LANG_US]["rules-no-rules-set"] = "No rules set. Use /setrules to set"


	g_locale[LANG_US]["rules-show-desc"] = "Show chat rules. If your intention is to set rules, use /setrules"
	g_locale[LANG_BR]["rules-show-desc"] = "Exibe as regras do chat. Se o que você quer é definir regras, use /setrules"


	g_locale[LANG_BR]["rules-set-desc"] = "Define as regras do chat. Responda a mensagem que contem as regras usando esse comando, ou escreva as regras logo depois do comando."
	g_locale[LANG_US]["rules-set-desc"] = "Define the chat rules. Reply the rules message with this command or write the rules right next to the command."
	
	g_locale[LANG_BR]["rules-error-setting"] = "Erro definindo regras: %s"
	g_locale[LANG_US]["rules-error-setting"] = "Error setting rules: %s"


	g_locale[LANG_BR]["rules-use-again"] = "Responda a mensagem que contem as regras usando esse comando, ou escreva as regras logo depois do comando."
	g_locale[LANG_US]["rules-use-again"] = "Reply the rules message with this command or write the rules right next to the command."

	g_locale[LANG_BR]["rules-clear"] = "Regras removidas"
	g_locale[LANG_US]["rules-clear"] = "Rules removed."

	g_locale[LANG_BR]["rules-set"] = "<b>Regras definidas para:</b> \n<code>----------------</code>\n%s\n<code>--------------------</code>\nPara remover, use <code>/setrules clear</code>"
	g_locale[LANG_US]["rules-set"] = "<b>Rules set to:</b> \n<code>----------------</code>\n%s\n<code>--------------------</code>\nTo clear, use <code>/setrules clear</code>"


	g_locale[LANG_BR]["rules-rules-button"] = "Regras do chat"
	g_locale[LANG_US]["rules-rules-button"] = "Chat rules"

	g_locale[LANG_BR]["rules-click"] = "Clique para ver as regras."
	g_locale[LANG_US]["rules-click"] = "Clique para ver as regras."

	g_locale[LANG_BR]["rules-norules"] = "Nenhuma regra setada"
	g_locale[LANG_US]["rules-norules"] = "No rules set"



end


return rules