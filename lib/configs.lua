function loadConfigs()
	local counter = 0
	local ret = db.getResult("SELECT * FROM `config`;")
	if ret:getID() ~= -1 and ret:getID() ~= nil then
		repeat 
			local dat = ret:getDataString('value')
			counter = counter +1
			configs[ret:getDataString('name')] = unserialize(dat)
		until not ret:next()
		ret:free()
	end	
	if counter == 0 then 
		print("Setting up some configs")
		configs["stats"] = {}
		saveConfig("stats")
		counter = 1
	end	
	print("Loaded "..(counter).." config")
end


function SaveConfigs()
	for name, val in pairs(configs) do 
		SaveConfig(name)
	end
end 

function SaveConfig(name)
	if configs[name] and not configs[name].delete then
		local data = serialize(configs[name])
		local ret = db.getResult("SELECT * FROM `config` WHERE `name` = '"..db.escapeString(name).."';")
		if ret:getID() ~= -1 and ret:getID() ~= nil then
			ret:free()
			db.executeQuery("UPDATE `config` SET `value` = '"..db.escapeString(data).."' WHERE `name` = '"..db.escapeString(name).."';");
		else 
			db.executeQuery("INSERT INTO `config` (`name`, `value`) VALUES ('"..db.escapeString(name).."', '"..db.escapeString(data).."')");
		end
	else 
		configs[name] = nil
		db.executeQuery("DELETE FROM `config` WHERE `name` = '"..db.escapeString(name).."';")
	end
end
