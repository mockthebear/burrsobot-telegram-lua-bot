BREAK_EXECUTION = 1
KILL_EXECUTION = 2
CONTINUE_EXECUTION = 3
DEFAULT_PRIORITY = 1000

g_moduleNow = ""
g_auxLibs = {}

local shell = require "resty.shell"



function reloadAuxiliarLibs()
	g_moduleNow = ""
	g_auxLibs = {}
	loadAuxiliarLibs()
end

function hasOsModule(name)
	if name:find("%s") then 
		return false
	end
	local ok = shell.run("command -v "..name, nil, 5000, 4096)
	return ok
end

function loadAuxiliarLibs(reload)
	print("[Burrbot] Now load auxiliar libs")
	local auxLibs = {}

	local reader = io.popen("ls "..getModulePath()) 
	local mods = reader:read("*a").."\n"
	for modName in mods:gmatch("(.-)\n") do 
		if modName:len() > 1 then
			auxLibs[#auxLibs+1] = modName
		end
	end


	local priority = 100
	local objs = {}
	local libObjects = {}
	for cnt, libname in pairs(auxLibs) do 

		io.write("[Burrbot] "..math.floor(cnt/#auxLibs*100).."% Loading: "..libname)
		local load = function()
			g_moduleNow = libname

			local path = getModulePath().."/"..libname..".lua"
			local success, val = pcall(dofile, path)
			if not success then 
				print("\nError loading "..path..": "..val)
				return
			end

			if not val or type(val) ~= "table" then 
				print("\nError loading "..path.." failed to dofile... Maybe missing a return?")
				return
			end
			if not val.load then 
				print("\nError loading "..path..": missing load function")
				return
			end

			if val.require then 
				for rtype, data in pairs(val.require) do 
					if rtype == "os" then 
						for _, mod in pairs(data) do
							if not hasOsModule(mod) then 
								print("\nError loading "..path..": missing OS module: "..mod)
								return 
							end
						end
					elseif rtype == "module" then 
						for _, mod in pairs(data) do
							if not _G[tostring(mod)] then 
								print("\nError loading "..path..": missing BOT module: "..tostring(mod))
								return 
							end
						end
					end 
				end
			end

			io.write(". Loaded as ["..libname.."]\n")
	
			val._libname = libname


			local pri = (val.priority or DEFAULT_PRIORITY) 

			while objs[pri+ priority] do
				priority = priority +1
			end

			objs[pri+ priority] = libname
			g_auxLibs[pri+ priority] = {lib=val,name=libname}
			libObjects[libname]  = val
			_G[libname] = val
			
		end

		load()
	end

	for libname, val in pairs(libObjects) do 
		_G[libname] = val
	end

	local indx = {}
	for i,b in pairs(objs) do 
		indx[#indx+1] = i
	end
	table.sort(indx)
	g_auxLibs.__indexes = indx
	if not reload then
		loadAuxiliarLibsLocalization()
	end
	local str = ""
	for i=1, #g_auxLibs.__indexes do 
		local priorityId = g_auxLibs.__indexes[i]
		local libname = g_auxLibs[priorityId].name
		str = str .. libname .. " -> "
	end
	print("Run priority: "..str.." default")

	runModulesMethod(nil, "load")
end

function loadAuxiliarLibsLocalization()
	runModulesMethod(msg, "loadTranslation")
end



local _print = print 
function module_print(...)
	_print("["..g_moduleNow.."] ", ...)
end

function runModulesMethod(msg, method, ...)
	local count = 0 
	if not g_auxLibs.__indexes then 
		return nil
	end

	

	local isChat = (msg or {isChat=true}).isChat
	local blackList = msg and (isChat and (chats[msg.chat.id].disabledModule) or false) or false

	for i=1, #g_auxLibs.__indexes do 

		local priorityId = g_auxLibs.__indexes[i]
		local currLib = g_auxLibs[priorityId].lib
		local libname = g_auxLibs[priorityId].name
		if not blackList or not blackList[libname] then
			g_moduleNow = libname
			if not (currLib.chatOnly and not isChat) or not currLib.chatOnly then
				local func = currLib[method]
				if func then 
					count = count +1
					print = module_print
					local sucees, ret, val
					if msg then
						sucees, ret, val = xpcall(func, debug.traceback, msg, ...)
					else
						sucees, ret, val = xpcall(func, debug.traceback, ...)
					end
					print = _print
					if sucees then 
						if ret == KILL_EXECUTION or ret == true then 
							print("Killed execution of "..method.." to "..msg.from.first_name.." at "..g_moduleNow)
							g_moduleNow = ""
							return false
						elseif ret == BREAK_EXECUTION then 
							break
							return false
						end
					else 
						say.admin("Error on call ["..method.."] at module ["..libname.."]: "..ret)
						say.admin("Message:<code>"..cjson.encode(msg).."</code>")
					end
				end
			end
		end
	end	
	g_moduleNow = ""
	return true, count
end

function getModulePath()
	return "modules/"..g_moduleNow
end