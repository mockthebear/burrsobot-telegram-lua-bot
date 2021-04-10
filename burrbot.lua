#!/usr/bin/resty
print("Starting bot")
setmetatable(_G,{})
g_chatid = 0
g_fromid = 0
g_msg = nil


bannedchat = {}
chats = {}
configs = {}
admins = {}
ignored = {}
users = {}
schedule = {}

g_startup = os.time()


g_sayMode =  nil
g_chatFunc = nil

g_startup = os.time()
g_minute =tonumber( os.date("%M"))
g_hour =tonumber( os.date("%H"))
g_day = tonumber(os.date("%d"))

math.randomseed(os.time()) 

print("Loading static libs")

package.path = package.path .. ";static/?.lua"

encode = require("multipart.multipart-post").encode
cjson = require("cjson")
utf8 = require("utf8")
redis = require "resty.redis"
g_redis = redis:new()

print("Loading config")
dofile("config.lua")

print("Loading bot libs")


dofile("lib/locale.lua")
dofile("lib/users.lua")
dofile("lib/chats.lua")
dofile("lib/botlib.lua")
dofile("lib/saying.lua")
dofile("lib/modulemanager.lua")
dofile("lib/parallel.lua")
dofile("lib/dblib.lua")
dofile("lib/compat.lua")
dofile("lib/commands.lua")


local ok, err = g_redis:connect(REDIS_ADDR, REDIS_PORT)
if not ok then
    error("Failed to connect on redis: "..err)
    return
end




print("Checking token")


g_start = {}


bot, extension = require("lua-bot-api").configure(BOT_TOKEN) --config


g_botname = bot.username:lower()
g_botnick = bot.first_name:lower()
g_id = bot.id

print("Loading configs")

do
	local counter = 0
	ret = db.getResult("SELECT * FROM `config`;")
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

--[[
ret = db.getResult("SELECT * FROM `admins`;")
if ret:getID() ~= -1 and ret:getID() ~= nil then
	repeat 
		admins[#admins+1] = ret:getDataString('name')
		admins[ret:getDataString('name')] = #admins
	until not ret:next()
	ret:free()
end		
print("Loaded bot "..(#admins).." admins")']]


admins[81891406] = 81891406 --todo
admins[24752600] = 24752600 --todo






print("Loading chats")

loadChats()

print("Loading muted users")
do
	local cnt = 0
	ret = db.getResult("SELECT * FROM `blocked`;")
	if ret:getID() ~= -1 and ret:getID() ~= nil then
		repeat 
			cnt = cnt +1
			local dat = ret:getDataString('name'):lower()
			ignored[dat] = true
			--print("Blocked: ", dat)
		until not ret:next()
		ret:free()
	end		
	print("Loaded "..cnt.." blockeds")
end


ignored['topazioazul'] = true
ignored['erickwithck'] = true
ignored['maysilveryan'] = true
ignored['oliverfeuerr'] = true
ignored['nacaus'] = nil
ignored['foggyshades'] = true

print("Assembling localization")
StartLocalization()
print("Loading modules")
loadAuxiliarLibs()
print("Loading commands")
LoadCommands()




extension.onEditedMessageReceive = function( msg )
	if not formatMessage(msg) then 
		return
	end
	logMessage(msg, "onEditedMessageReceive")
	if not runModulesMethod(msg, "onEditedMessageReceive") then 
		return
	end
end

extension.onDocumentReceive = function( msg )
	
	if not formatMessage(msg) then 
		return
	end
	logMessage(msg, "onDocumentReceive")
	if not runModulesMethod(msg, "onDocumentReceive") then 
		return
	end


end

extension.onLeftChatParticipant = function(msg)
	g_msg = msg
	g_chatid = msg.chat.id
	logMessage(msg, "onLeftChatParticipant")
	if not runModulesMethod(msg, "onLeftChatParticipant") then 
		return
	end
end




extension.onNewChatParticipant = function(msg)

	if (msg.date - os.time()) < -10 then 
        
        return false
    end

    msg.actor = msg.from
    msg.from = msg.new_chat_participant

	if not formatMessage(msg) then 
		return
	end
	logMessage(msg, "onNewChatParticipant ")

	--Store user joins
	chats[msg.chat.id]._tmp.newUser[msg.new_chat_participant.id] = true
	users[msg.new_chat_participant.id].joinDate[msg.chat.id] = tonumber(msg.date) or 0
	SaveUser(msg.new_chat_participant.id)
	

	if not runModulesMethod(msg, "onNewChatParticipant") then 
		return
	end
	

end


extension.onPhotoReceive = function(msg)
	--print("["..(  ( (msg.chat and msg.chat.id and chats[msg.chat.id]) and chats[msg.chat.id].name or "???"  )  or "???" ).."] "..msg.from.first_name..": Photo")
	if not formatMessage(msg) then 
		return
	end

	logMessage(msg, "onPhotoReceive")

	if not runModulesMethod(msg, "onPhotoReceive") then 
		return
	end


end

extension.onNewChatPhoto = function(msg)
	if not formatMessage(msg) then 
		return
	end

	logMessage(msg, "onNewChatPhoto")

	if not runModulesMethod(msg, "onNewChatPhoto") then 
		return
	end
end

extension.onNewChatTitle = function(msg)
	if chats[msg.chat.id] then 
		say_admin("New chat title ["..(chats[msg.chat.id].data.title or "?").."] title: "..msg.new_chat_title)
	end

	logMessage(msg, "onNewChatTitle")

	if not runModulesMethod(msg, "onNewChatTitle") then 
		return
	end

	chats[msg.chat.id].data.title = msg.new_chat_title
	SaveChat(msg.chat.id)
	
end


extension.onInlineQueryReceive = function(msg)
	msg.from.username = (msg.from.username or tostring(msg.from.first_name)..(msg.from.id)):lower()

	if not runModulesMethod(msg, "onInlineQueryReceive") then 
		return
	end
end

extension.onCallbackQueryReceive = function(msg)
	g_msg = msg

	
	CheckUser(msg)
	if msg.message then
		g_chatid = msg.message.chat.id
		
	end


	if not runModulesMethod(msg, "onCallbackQueryReceive") then 
		return
	end

	if msg.message then
		
		if msg.data:match("lve:([%-%d]+)") then
			if admins[msg.from.id] then 
				local cid = tonumber(msg.data:match("lve:([%-%d]+)"))
				bot.sendMessage(cid, "Quantidade máxima de chats atingida.")
				deleteChat(cid)
				say("Left chat: "..cid)
			end
			return
		elseif msg.data:match("ins:([%-%d]+)") then
			if admins[msg.from.id] then 
				local cid = tonumber(msg.data:match("ins:([%-%d]+)"))
				if chats[cid] then
					local usr = ""
					for a,c in pairs(users) do 
						if c.joinDate and c.joinDate[cid] then 
							usr = usr .. '<a href="tg://user?id='..c.telegramid..'">'..a..'</a>\n'
						end
					end
					say.admin(usr)
					chats[cid].marked = {}
					chats[cid].users = {}
					say.admin(Dump(chats[cid]))
					say.admin("Inspect "..cid)
					collectgarbage()
				else 
					say("deu nao")
				end
				deploy_answerCallbackQuery(msg.id, "yey", "true")
			else
				deploy_answerCallbackQuery(msg.id, "NO", "true")
			end
			return
		elseif msg.data:match("bnch:([%-%d]+)") then
			if admins[msg.from.id] then 
				local cid = tonumber(msg.data:match("bnch:([%-%d]+)"))
				if chats[cid] then
					bot.sendMessage(cid, "Chat banned permanently!")
					bot.leaveChat(cid)
					bannedchat[cid] = true
					say_admin("bannedchat["..cid.."] = true")
					db.executeQuery("DELETE FROM `chats` WHERE `id` = '"..cid.."';")
				else 
					say("deu nao")
				end
			end
			return
		elseif msg.data:match("delpls") then
			if chats[msg.message.chat.id] then
				if #chats[msg.message.chat.id]._tmp.adms == 0 then
					cacheAdministrators(msg.message)
				end
				if chats[msg.message.chat.id]._tmp.adms[msg.from.id] then
					deploy_answerCallbackQuery(msg.id, "Deleting")
					deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
				else 	
					deploy_answerCallbackQuery(msg.id, "Only chat admins")
				end
			end
			return
		end
	end	
end


extension.onGroupChatCreated = function(msg)
	CheckChat(msg)
	if not runModulesMethod(msg, "onGroupChatCreated") then 
		return
	end
end
extension.onSupergroupChatCreated = function(msg)
	say_admin('onSupergroupChatCreated'..Dump(msg))
	CheckChat(msg)
	if not runModulesMethod(msg, "onSupergroupChatCreated") then 
		return
	end
end

extension.onChannelChatCreated = function(msg)
	say_admin('onChannelChatCreated'..Dump(msg))

	if not runModulesMethod(msg, "onChannelChatCreated") then 
		return
	end
end
extension.onMigrateToChatId = function(msg)

	if not runModulesMethod(msg, "onMigrateToChatId") then 
		return
	end
end
extension.onMigrateFromChatId = function(msg)


	g_msg = msg
	g_chatid = msg.chat.id

	migrateChat(msg.chat, msg.migrate_from_chat_id)

	if not runModulesMethod(msg, "onMigrateFromChatId") then 
		return
	end
end

extension.onUpdateChatMember = function(msg)
	
	g_msg = msg
	g_chatid = msg.chat.id

	logMessage(msg, "onUpdateChatMember")

	if not runModulesMethod(msg, "onUpdateChatMember") then 
		return
	end

	if msg.new_chat_member.user.id == g_id then 
		--Means stuff for me!
		if msg.new_chat_member.status == "left" or  msg.new_chat_member.status == "kicked" then 
			say.admin("Bot removed from: "..(msg.chat.type == "private" and "PVT" or msg.chat.title).." from "..(msg.from and formatUserHtml(msg) or "?").." = "..msg.new_chat_member.status, "HTML")
			deleteChat(msg.chat.id)
		elseif msg.new_chat_member.status == "administrator" then 
			say("POWEEEER!")
		elseif msg.new_chat_member.status == "member" then 
			CheckChat(msg)
		end
	else
		say.admin("Changed: "..(msg.chat.type == "private" and "PVT" or msg.chat.title).." from "..(msg.from and formatUserHtml(msg) or "?").." = "..msg.new_chat_member.status, "HTML")
	end
end

extension.onAudioReceive = function(msg)

	if not formatMessage(msg) then 
		return
	end

	logMessage(msg, "onAudioReceive")

	if not runModulesMethod(msg, "onAudioReceive") then 
		return
	end

end

extension.onVideoReceive = extension.onAudioReceive
extension.onVoiceReceive = extension.onAudioReceive
extension.onContactReceive = extension.onAudioReceive
extension.onLocationReceive = extension.onAudioReceive


extension.onStickerReceive = function(msg)
	

	if not formatMessage(msg) then 
		return
	end

	logMessage(msg, "onStickerReceive")

	if not runModulesMethod(msg, "onStickerReceive") then 
		return
	end
end


extension.onTextReceive = function (msg)


	if not formatMessage(msg) then 
		return
	end

	logMessage(msg, "onTextReceive")

	if ignored[msg.from.id] then 
		print("ignored "..msg.from.username)
		return
	end

	if msg.chat and msg.chat.id and chats[msg.chat.id] and chats[msg.chat.id].data.ignored and chats[msg.chat.id].data.ignored[msg.from.id] then 
		print("Ignored")
		return
	end

	if not runModulesMethod(msg, "onTextReceive") then 
		return
	end

	

	local success, ranCommand, err = findCommand(msg)
	if not success and err then 
		reply( "Error, please notify the bot admin about it and will be fixed as soon as possible: "..tostring(err))
		say.admin("Error:"..err.." as: "..msg.text.." on "..msg.chat.id .. "("..(msg.chat.title or "private")..")")
		return
	end

	if msg.isChat then
		SaveChat( msg.chat.id)
	end
	
end



function onMinute(min, hour, day)
	if not runModulesMethod(nil, "onMinute", min, hour, day) then 
		return
	end
end

function onHour(min, hour, day)
	if not runModulesMethod(nil, "onHour", min, hour, day) then 
		return
	end
end

function onDay(min, hour, day)
	if not runModulesMethod(nil, "onDay", min, hour, day) then 
		return
	end
end

function onRunner()
	local min = tonumber(os.date("%M"))
	local hour = tonumber(os.date("%H"))
	local day = tonumber(os.date("%d"))

	if g_minute ~= min then 
		g_minute = min
		onMinute(g_minute, g_hour, g_day)
	end

	if g_hour ~= hour then 
		g_hour = hour
		onHour(g_minute, g_hour, g_day)
	end

	if g_day ~= day then 
		g_day = day
		onDay(g_minute, g_hour, g_day)
	end

	
	for i,b in pairs(schedule) do 
		if b.time <= os.time() then 
			local ret, err = xpcall(b.f, debug.traceback, unpack(b.args))
			if not ret then 
				g_chatid = 81891406
				say("Timer err on bot "..Dump(b)..":"..err)
			end
			schedule[i] = nil
			rep = false
			break
		end
	end

	if not runModulesMethod(msg, "frame") then 
		return
	end

end

print("Calling ready")

if not runModulesMethod(msg, "ready") then 
	return
end

print("Ready")

function a()
	extension.run(100,nil,onRunner) 
end 


local f,err = xpcall(a, debug.traceback)
if not f and err then 
	err = err .. "and: "..debug.traceback()
	local ff = io.open("crashlog.txt", "a+")
	print(err)
	ff:write(err.."\r\n")
	ff:close()
	g_chatid =  -1001376833423
	say.big("Crash:"..err)
	say.big(Dump(g_msg or {}))
	for i,b in pairs(chats) do
		SaveChat( i )
	end

end
