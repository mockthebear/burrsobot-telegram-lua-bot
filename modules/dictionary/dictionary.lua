local module = {
	priority = DEFAULT_PRIORITY,
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
	addCommand( {"define"}		, MODE_FREE,  getModulePath().."/define.lua", 2 , "dictionary-define" )
end

function module.loadTranslation()
	g_locale[LANG_US]["dictionary-define"] = "Definição de uma palavra"
	g_locale[LANG_BR]["dictionary-define"] = "Portuguese defition of a word"
end


return module