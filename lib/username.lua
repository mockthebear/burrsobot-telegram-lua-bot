function getUsernameKey(username)
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

function setUsernameKey(entity)

	
	if not entity._tmp then 
		say.admin("The missing entity data is: <code>"..cjson.encode(entity).."</code>", "HTML")
	end

	local _type = entity._tmp.type

	g_redis:set("username:"..entity.username ,_type..":"..entity.id)
end



function checkUsername(msg)
	local entity, whichReal = getEntity(msg)
	if entity and entity.username then 
		local id, whichStored = getUsernameKey(entity.username)
		if id == nil then
			print("Entity ["..whichReal.."] "..entity.id.." now has username: "..entity.username) 
			setUsernameKey(entity)
			return true, 0
		elseif id ~= entity.id or whichStored ~= whichReal then 
			print("Mismatched id with username")
			g_redis:del(whichStored..":"..entity.username)
			setUsernameKey(entity)
			return true, 1
		else 
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
    local id, which, key = getUsernameKey(uname:lower())
    if not id or which ~= "user" then 
    	return nil
    end
    return getUser(id)
end
