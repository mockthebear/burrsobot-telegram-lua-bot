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
	addCommand( {"random", "roll"}		, MODE_FREE,  getModulePath().."/roll.lua", 2 , "random-roll" )
end

function module.loadTranslation()
	g_locale[LANG_US]["random-roll"] = "Roda um dado. Dá para usar assim: /random 1 10 ou /random 1d10"
	g_locale[LANG_BR]["random-roll"] = "Roll a die or a random number. Can be used like this: /random 1 10 or /random 1d10"
end


return module