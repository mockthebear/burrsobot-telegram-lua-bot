local module = {}

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
	LoadCommand(nil, {"burr", "bear"}, MODE_FREE, getModulePath().."/burr.lua", 1, "Mostra um bolo" )
	LoadCommand(nil, {"legg","leggy", "manned"}, MODE_FREE, getModulePath().."/leggy.lua", 1, "Mostra um bolo" )
	LoadCommand(nil, {"gato", "cat"}, MODE_FREE, getModulePath().."/cat.lua", 1, "Mostra um bolo" )
	LoadCommand(nil, {"poss", "opossum", "possim"}, MODE_FREE, getModulePath().."/poss.lua", 1, "Mostra um bolo" )
	LoadCommand(nil, {"racc", "coon", "raccoon"}, MODE_FREE, getModulePath().."/racc.lua", 1, "Mostra um bolo" )
	LoadCommand(nil, {"birb", "burb"}, MODE_FREE, getModulePath().."/birb.lua", 1, "Mostra um birb")
end

function module.loadTranslation()
	g_locale[LANG_US]["Mostra um bolo"] = "Displaya cake"

end


return module