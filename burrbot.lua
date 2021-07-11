#!/usr/bin/resty
print("Starting bot")
setmetatable(_G,{})


g_chatid = 0
g_fromid = 0
g_msg = nil
chats = {}
configs = {}
admins = {}
users = {}
schedule = {}
g_startup = os.time()

g_sayMode =  nil
g_chatFunc = nil


g_minute =tonumber( os.date("%M"))
g_hour =tonumber( os.date("%H"))
g_day = tonumber(os.date("%d"))

package.path = package.path .. ";static/?.lua"


print("Loading static libs")



encode = require("multipart.multipart-post").encode
cjson = require("cjson")
utf8 = require("utf8")
redis = require "resty.redis"
g_redis = redis:new()


math.randomseed(os.time()) 

print("Loading config")
dofile("config.lua")
print("Loading bot libs")
dofile("lib/configs.lua")
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


print("Connecting on redis~")
local ok, err = g_redis:connect(REDIS_ADDR, REDIS_PORT)
if not ok then
    error("Failed to connect on redis: "..err)
    return
end
print("Checking token")

bot, extension = require("lua-bot-api").configure(BOT_TOKEN) --config

g_botname = bot.username:lower()
g_botnick = bot.first_name:lower()
g_id = bot.id

print("Loading configs")
loadConfigs()
print("Loading chats")
loadChats()
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
	if not runModulesMethod(msg, "onNewChatTitle") then 
		return
	end

	logMessage(msg, "onNewChatTitle")

	chats[msg.chat.id].data.title = msg.new_chat_title
	SaveChat(msg.chat.id)
	
end


extension.onInlineQueryReceive = function(msg)
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
end

extension.onGroupChatCreated = function(msg)
	CheckChat(msg)
	if not runModulesMethod(msg, "onGroupChatCreated") then 
		return
	end
end

extension.onSupergroupChatCreated = function(msg)
	CheckChat(msg)
	if not runModulesMethod(msg, "onSupergroupChatCreated") then 
		return
	end
end

extension.onChannelChatCreated = function(msg)
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
	
	if not runModulesMethod(msg, "onUpdateChatMember") then 
		return
	end

	logMessage(msg, "onUpdateChatMember")


	if msg.new_chat_member.user.id == g_id then 
		--Means stuff for me!
		if msg.new_chat_member.status == "left" or  msg.new_chat_member.status == "kicked" then 
			if msg.chat.type == "private" then
				if users[msg.from.id] then
					users[msg.from.id].private = nil 
					SaveUser(msg.from.id)
				end
			else 
				say.admin("Bot removed from: "..(msg.chat.title).." from "..(msg.from and formatUserHtml(msg) or "?").." = "..msg.new_chat_member.status, "HTML")
				deleteChat(msg.chat.id)
			end
		elseif msg.new_chat_member.status == "member" then 
			CheckChat(msg)
		end
	end
end

extension.onVideoReceive = function(msg)
	if not formatMessage(msg) then 
		return
	end

	logMessage(msg, "onVideoReceive")

	if not runModulesMethod(msg, "onVideoReceive") then 
		return
	end
	
end

extension.onVoiceReceive = function(msg)
	if not formatMessage(msg) then 
		return
	end

	if not runModulesMethod(msg, "onVoiceReceive") then 
		return
	end
end

extension.onContactReceive = function(msg)
	if not formatMessage(msg) then 
		return
	end
	if not runModulesMethod(msg, "onContactReceive") then 
		return
	end
end

extension.onLocationReceive = function(msg)
	if not formatMessage(msg) then 
		return
	end
	if not runModulesMethod(msg, "onLocationReceive") then 
		return
	end
end

extension.onStickerReceive = function(msg)
	if not formatMessage(msg) then 
		return
	end

	logMessage(msg, "onStickerReceive")

	if not runModulesMethod(msg, "onStickerReceive") then 
		return
	end
end


extension.onScheduleWarning = function (msgs)
	local types = ""
	local amount = 0
	for i,b in pairs(msgs) do 
		types = types .. tostring(b[1])..", "
		amount = amount +1
	end
	say.admin("We have a total of "..amount.." scheduled messages <code>["..types.."]</code>")
end

extension.onTextReceive = function (msg)
	if msg.chat.type == "private" then 
		print(msg.from.id.." "..msg.from.first_name..": "..msg.text)
	end

	if not formatMessage(msg) then 
		return
	end

	if msg.text:sub(1,1) == "/" then
		print("[COMMAND] {"..msg.chat.type ..  (msg.chat.type ~= "private" and (" : "..msg.chat.title)   or "") .." : "..msg.chat.id.."} "..(msg.from.username and ("@"..msg.from.username) or msg.from.first_name)..": "..msg.text)
    	logText("commands", os.date("%d/%m/%y %H:%M:%S",os.time()).." command=\""..msg.text.."\" by="..msg.chat.id.." name=\""..msg.from.first_name.."\" username=\""..(msg.from.username or "-").."\" at=\"".. (msg.chat.type ~= "private" and (msg.chat.title)   or msg.chat.type).."\" chatid="..msg.chat.id.."\n")
	end

	logMessage(msg, "onTextReceive")

	if not runModulesMethod(msg, "onTextReceive") then 
		return
	end

	local success, ranCommand, err = findCommand(msg)
	if not success and err then 
		reply("Error: "..tostring(err))
		say.admin("Error:"..err.." as: "..msg.text.." on "..(msg.chat.type == "private" and "private" or msg.chat.title))
		return
	end

	if msg.isChat then
		SaveChat(msg.chat.id)
	end
	
end

function onMinute(min, hour, day)
	if not runModulesMethod(nil, "onMinute", min, hour, day) then 
		return
	end

	if min%5 == 0 then 
		runModulesMethod(nil, "save")
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
			triggerEvent(i)
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

function protectedCallBot()
	extension.run(100,nil,onRunner)
end

local f,err = xpcall(protectedCallBot, debug.traceback)
if not f and err then 
	err = err .. "and: "..debug.traceback()
	local ff = io.open("crashlog.txt", "a+")
	print(err)
	ff:write(err.."\r\n")
	ff:close()
	say.admin("Crash:"..err)
	say.admin(Dump(g_msg or {}))
	for i,b in pairs(chats) do
		SaveChat( i )
	end
end
