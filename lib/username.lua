function getUsernameKey(username)
	if not username then 
		return nil
	end
	local key = g_redis:get("username:"..username)
	if key == ngx.null then 
		return nil
	end
	local which, id = key:match("(.-):([%-%d]+)")
	id = tonumber(id)
	if not id then 
		error("Invalid redis key: "..key)
	end
	
	return id, which, key
end

function setUsernameKey(entity, forcedType)
	local usrType = forcedType
	if not usrType then
		if not entity._tmp then 
			say.admin("The missing entity data is: <code>"..cjson.encode(entity).."</code>", "HTML")
		end
		usrType = entity._tmp.type

	end
	if not entity.username then 
		g_redis:del("username:"..entity.username)
	else	
		g_redis:set("username:"..entity.username ,usrType..":"..entity.id)
	end
end



function checkEntityUsername(msg)
	local entity, entityType, msgEntity = getEntity(msg)
	return checkUsername(entity, msgEntity.username)
end

function checkUsername(entity, whichReal, observedUsername)
	if entity then 
		local id, whichStored = getUsernameKey(entity.username)
		if id == nil and (entity.username or observedUsername) then
			entity.username = entity.username or observedUsername
			print("[Username] Entity ["..whichReal.."] "..entity.id.." now has username: "..entity.username) 
			setUsernameKey(entity, whichReal)
			return true, 0
		elseif id ~= nil and entity.username and (id ~= entity.id or whichStored ~= whichReal) then 
			print("[Username] Mismatched id with type > "..cjson.encode({id, entity.id}).." -- "..cjson.encode({whichStored, whichReal}))
			g_redis:del(whichStored..":"..entity.username)
			setUsernameKey(entity)
			SaveUser(id)
			return true, 1
		elseif observedUsername and observedUsername ~= entity.username then 
			print("[Username] Changed username > "..cjson.encode({entity.username, observedUsername}))
			if entity.username then
				g_redis:del(whichReal..":"..entity.username)
				g_redis:del(whichStored..":"..entity.username)
			end
			entity.username = observedUsername
			setUsernameKey(entity)
			SaveUser(id)
			return true, 1
		else 
			--print('Username: '..entity.username.." is fine because stored is "..whichStored)
			--Username is fine
			return true, nil
		end
	end 
	return false, nil
end

function getEntityByUsername(username)
	local id, which, key = getUsernameKey(username:lower())
	if which == "user" then 
		return getUser(id), which
	elseif which == "channel" then 
		local chanObj = getChannel(id)
		return chanObj, which
	else 
		return chats[id], which
	end
end

function getUserByUsername(uname)
	if not uname then 
		return nil
	end
	if uname:sub(1,1) == "@" then 
		print("sube")
		uname = uname:sub(2, -1)
		print(uname)
	end
    local id, which, key = getUsernameKey(uname:lower())
    if not id or which ~= "user" then 
    	return nil
    end
    return getUser(id)
end
