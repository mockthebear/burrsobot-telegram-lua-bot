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
	addCommand( {"bolo", "cake"}		, MODE_FREE,  getModulePath().."/bolo.lua", 2 , "example-desc" )
end

function module.loadTranslation()
	g_locale[LANG_US]["example-desc"] = "Displaya cake"
	g_locale[LANG_BR]["example-desc"] = "Mostra um bolo"
end


return module