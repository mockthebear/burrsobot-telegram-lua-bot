local redis = require "resty.redis"
local cjson = require("cjson")
local resty_sha1 = require "resty.sha1"
local restystring = require "resty.string"

local pubsub = {
	redisSubscribe = false,
	allowed = {
		chat = {
		},
	},
	callback = {
	},
	imagedir="/var/www/boto/images",

	priority = DEFAULT_PRIORITY,
}

function pubsub.registerExternalVariable(location, varname, allowed, allowWrite, description, moduleName, aliases, callback)
	if pubsub.allowed[location] then 
		moduleName = moduleName or g_moduleNow
		if not pubsub.allowed[location][moduleName] then 
			pubsub.allowed[location][moduleName] = {}
		end

		if type(allowed) ~= "table" then 
		--	error("Type of allowed is wrong: "..type(allowed).." expected a table")
		end
		pubsub.allowed[location][moduleName][varname] = {
			accept = allowed,
			write=allowWrite,
			description=description,
			alias = aliases,
		}
		pubsub.callback[varname] = callback

	end
end


function pubsub.adjustValue(val)
    if type(val) == "table" then 
        return val
    end
    if val == "true" or val == true then 
        return true
    end
    if val == "false" or val == false then 
        return false
    end
    return tonumber(val or "") or tostring(val)
end

--[ONCE] runs when the load is finished
function pubsub.load()
	pubsub.redisSubscribe = redis:new()
	pubsub.sha1 = resty_sha1:new()
	local ok, err = pubsub.redisSubscribe:connect(REDIS_ADDR, REDIS_PORT)
	if not ok then
	    error("Failed to connect on redis: "..err)
	    return
	end
	pubsub.redisSubscribe:set_timeouts(25, 25, 25)

	local res, err = pubsub.redisSubscribe:subscribe("bot")
	if not res then
	    error("Failed to subscribe: "..err)
	    return
	end

	
end

--[ONCE] runs when eveything is ready
function pubsub.ready()
	local valid = listCommandsData({MODE_FREE, MODE_CHATONLY})
	local values = {}
	local cdvalues = {}
	for i,b in pairs(valid) do 
		values[thisOrFirst(b.words)] = "boolean"
		cdvalues[thisOrFirst(b.words)] = b.cooldown
	end

	--pubsub.registerExternalVariable("chat", "memes", {type="tuple", valid={ head="*", tail={"Ban", "Kick", "Delete", "Mute 60s", "Mute 10 min", "Mute 1h"} }}, true, "Sussy baka", "SUS")


	pubsub.registerExternalVariable("chat", "disabledc", {type="list_boolean_not", valid=values}, true, "Enabled commands", "Commands", {["ON"]= "Disabled", ["OFF"] = "Enabled", [".head"] = "/"}, function(chatid)
		if chats[chatid] then
			chats[chatid].data.changedCommand = true
			return true
		end
		return false
	end)
	pubsub.registerExternalVariable("chat", "custom_cooldown", {type="list_number", fields=cdvalues}, true, "Command Cooldown", "Cooldown", {[".head"] = "/"})
	pubsub.registerExternalVariable("chat", "global_cooldown", {type="number",  default=1}, true, "Global command cooldown", "Cooldown")
	pubsub.registerExternalVariable("chat", "cooldown_ignore_admins", {type="boolean",  default=false}, true, "Admins have no cooldown", "Cooldown")
	g_redis:del("default:accepted")
	g_redis:set("default:accepted", cjson.encode(pubsub.allowed))
end

function pubsub.loadCommands()
	addCommand( {"painel", "panel"}					, MODE_CHATADMS, getModulePath().."/token.lua", 10, "Chat panel"  )
end

function pubsub.loadTranslation()
end


--Runs at the begin of the frame
function pubsub.onCallbackQueryReceive(msg)
	if msg.message and msg.data == "panel:token" then
		if isUserChatAdmin(msg.message.chat.id, msg.from.id) then
			local tok = pubsub.generateChatToken(msg.message.chat.id, msg.from.id, msg.from.first_name)
			if users[msg.from.id] and users[msg.from.id].private then 
				bot.answerCallbackQuery(msg.id, "Access link was sent on your private", "true")

			    local tok = pubsub.generateChatToken(msg.message.chat.id, msg.from.id, msg.from.first_name)

			    local keyb = {}	
				local JSON = require("JSON")
				keyb[1] = {}
				keyb[2] = {}
				keyb[1][1] = { text = "Open panel", selective=true, web_app = {url=tok}} 
				keyb[2][1] = { text = "Open in browser", url=tok} 

				local kb2 = JSON:encode({inline_keyboard = keyb })

				local res = bot.sendMessage(msg.from.id, "Panel to chat "..msg.message.chat.title, "HTML", true, false, msg.message_id, kb2)
				if not res.ok then 
				  reply(Dump(res))
				end

				--bot.sendMessage(msg.from.id, "Access link: "..tok, "HTML")
				--say.admin("Painel open for: "..msg.message.chat.title)
			else 
				deploy_answerCallbackQuery(msg.id, "I cant send private messages to you, please send me a /start on private", "true")
			end
		else 
			deploy_answerCallbackQuery(msg.id, "Access denied", "true")
		end
	end
end
function pubsub.frame()
	res, err = pubsub.redisSubscribe:read_reply()
    if not res then
        if err ~= "timeout" then 
        	--errr
        end
        return
    end
    
    if res[1] == "message" and res[2] == "bot" then 
    	local data = res[3]
    	--say.admin("1: receive: "..data)
    	print("Message: "..data)
    	local message = cjson.decode(data)
    	local messageid = message.id

    	if type(message.fromname) ~= "string" then 
	    	message.fromname = "?"
	    end
    	if message.type == "chat" then 
    		local chatid = tonumber(message.chat or 0)
    		local key = message.key
    		local val = message.value
    		local index = message.index
    		local notify = message.notify
    		if chats[chatid] then 
    			local allowed, restriction = pubsub.isSettingAllowed("chat", key)
    			if allowed then 
    				val = pubsub.adjustValue(val)
    				local accepted, validString = pubsub.isWithinRestriction(restriction, val, index)
    				if not accepted then 
    					pubsub.replyMessageId(messageid, "Value="..tostring(val).." is not allowed ["..validString.."]")
    				else 
    					local valid = true
	    				if pubsub.callback[key] then 
	    					local res, proceed = pcall(pubsub.callback[key], chatid, key, index, val)
	    					if not res or not proceed then 
	    						print("Error: "..tostring(proceed))
	    						pubsub.replyMessageId(messageid, "Not ok")
	    						return
	    					end
	    				end
    					if restriction.accept and (restriction.accept.type == "list_boolean" or  restriction.accept.type == "list_boolean_not") then 
    						if not chats[chatid].data[key] then 
    							chats[chatid].data[key] = {}
    						end
    						local oldVal = chats[chatid].data[key][index]
	    					chats[chatid].data[key][index] = val

	    					if notify == "on" or notify == "true" then

		    					local stat = bot.sendMessage(chatid, "Altered <b>"..restriction.description.."</b> by "..formatUserHtml({id=message.fromid, first_name=message.fromname}).." to:\n\n"
		    						..pubsub.formatAlias( ".head", restriction, true )..index.." -> "..pubsub.formatOutput(val, restriction), "HTML")
		    					if stat.ok then
		    						pubsub.replyMessageId(messageid, "OK")
		    					else 
		    						chats[chatid].data[key][index] = oldVal
		    						pubsub.replyMessageId(messageid, stat.description)
		    					end
		    				else 
		    					pubsub.replyMessageId(messageid, "OK")
		    				end
	    				elseif restriction.accept and restriction.accept.type == "list_number" then 
    						local oldVal = chats[chatid].data[key][index]
    						if not chats[chatid].data[key] then 
    							chats[chatid].data[key] = {}
    						end
	    					chats[chatid].data[key][index] = val

	    					if notify == "on" or notify == "true" then
		    					local stat = bot.sendMessage(chatid, "Altered <b>"..restriction.description.."</b> by "..formatUserHtml({id=message.fromid, first_name=message.fromname}).." to:\n\n"
		    						..pubsub.formatAlias( ".head", restriction, true )..index.." -> "..pubsub.formatOutput(val, restriction), "HTML")
		    					if stat.ok then
		    						pubsub.replyMessageId(messageid, "OK")
		    					else 
		    						chats[chatid].data[key][index] = oldVal
		    						pubsub.replyMessageId(messageid, stat.description)
		    					end
		    				else 
		    					pubsub.replyMessageId(messageid, "OK")
		    				end
    					else
	    					local oldVal = chats[chatid].data[key]
	    					chats[chatid].data[key] = val
	    					if notify == "on" or notify == "true" then
	    						local stat = bot.sendMessage(chatid, "Altered <b>"..restriction.description.."</b> by "..formatUserHtml({id=message.fromid, first_name=message.fromname}).." to:\n\n"..pubsub.formatAlias( ".head", restriction, true )..pubsub.formatOutput(val, restriction), "HTML")
		    					if stat.ok then
		    						pubsub.replyMessageId(messageid, "OK")
		    					else 
		    						chats[chatid].data[key] = oldVal
		    						pubsub.replyMessageId(messageid, stat.description)
		    					end
		    				else 
		    					pubsub.replyMessageId(messageid, "OK")
		    				end
	    				end
    					SaveChat(chatid)
    				end
    			else 
    				pubsub.replyMessageId(messageid, "Method "..key.." unauthorized")
    			end
    		end
    	end
    end
end

function pubsub.formatOutput_internal(val)
	if val == true then 
		return "ON"
	elseif val == false then 
		return "OFF"
	end

	if type(val) == "string" then 
		val = val:gsub("<user>", ("<user>"):htmlFix())
		val = val:gsub("<username>", ("<username>"):htmlFix())
		val = val:gsub("<name>", ("<name>"):htmlFix())
		val = val:gsub("<chat>", ("<chat>"):htmlFix())
	end

	return tostring(val)
end

function pubsub.formatAlias( val, restriction, ignoreDef )
	if restriction and restriction.alias then 
		return restriction.alias[val] or val
	end
	return ignoreDef and "" or val
end

function pubsub.formatOutput(val, restriction)
	local res = pubsub.formatOutput_internal(val)
	
	return pubsub.formatAlias(res, restriction)
	
end

function pubsub.isWithinRestriction(restriction, value, index)
	restriction = restriction.accept
	if (restriction.type == "boolean" ) then 
		return type(value) == "boolean", "expected boolean got "..type(value)
	end
	if (restriction.type == "number") then 
		return type(tonumber(value)) == "number", "expected number got "..type(value)
	end

	if (restriction.type == "string") then 
		local sameType = type(value) == "string"
		if sameType and value:len() > (restriction.lenght or math.huge) then 
			return false, "max lenght"
		end
		return sameType, "expected string got "..type(value)
	end

	if type(restriction) == "table" then 
		local found = false
    	local valid = ""
    	restriction.valid = restriction.valid or {}
    	local elemCount = 0
    	for a,c in pairs(restriction.valid) do 
    		elemCount = elemCount +1
    	end
    	
		if elemCount == 0 then
    		found = true
    	end

    	for i,b in pairs(restriction.valid) do 
    		if restriction.type:match("^list_(.+)") then
    			if index == i and type(value) == b or value == b then 
	    			found = true
	    			break
	    		end
	    		valid = valid .. tostring(i).."=".. tostring(b) .. ", "
	       	else 
	       		
	    		if value == b then 
	    			found = true
	    			break
	    		end
	    		valid = valid .. tostring(b) .. ", "
	    	end
    		
    	end 
    	if found then 
    		return true
    	end
    	return false, valid
	end   				
    return false, restriction					   				
end


function pubsub.isSettingAllowed(location, setting)
	if pubsub.allowed[location] then 
		local mmdat = pubsub.allowed[location]
		for modName, dat in pairs(mmdat) do
			for i,b in pairs(dat) do
				if i == setting then
					return true, b
				end
			end
		end
	end
end

function pubsub.storePhoto(id)
	local dat = bot.getChat(id)
	if dat and dat.ok then 
		if dat.result.photo then
			local fl = dat.result.photo.small_file_id
			local ret = bot.downloadFile(fl, pubsub.imagedir.."/chat"..id.."-pfp.jpg") 
			if not ret or not ret.success then
				say.admin("failed due: "..tostring(dat.description))
			end
		else 
			say.admin("Chat id "..id.." has no photo obj")
		end
	else
		say.admin("Chat id "..id.." is not allowed: "..dat.description) 
	end
end

function pubsub.onNewChatPhoto(msg)
	--[[local fid = msg.new_chat_photo[3].file_id
	local ret = bot.downloadFile(fid, pubsub.imagedir.."/chat"..msg.chat.id..".jpg")
	if not ret or not ret.success then
		say.admin("Failed to save pfp from: "..msg.chat.title.." due: "..tostring(ret.description))
	end]]
end

function pubsub.generateChatToken(chatid, fromId, fromName)

	pubsub.sha1:update("kek:"..os.time())

	local digest = pubsub.sha1:final()
	local token = restystring.to_hex(digest)

	
	pubsub.sha1:reset()



	local key = "token:"..token


	g_redis:hset(key, "chatid", chatid)
	g_redis:hset(key, "fromid", fromId)
	g_redis:hset(key, "fromname", fromName)
	g_redis:expire(key, 600)

	SaveChat(chatid)

	return "https://burrbot.xyz/chat.php?token="..token
end

function pubsub.replyMessageId(id, msg)
	local key = "tmp:msg:"..id
	print("Reply message id as: "..msg) 
	g_redis:set(key, msg)
	g_redis:expire(key, 60)
end

return pubsub