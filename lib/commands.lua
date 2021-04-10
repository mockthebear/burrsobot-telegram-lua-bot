

function LoadCommands()
    print("[Commands] Loading commands")
    g_commands = {}
    g_commandUid = 0
    

     

    SetupCommands()

    runModulesMethod(nil, "loadCommands")

    print("[Commands] Loaded "..(g_commandUid).." commands")   

    print("[Commands] Done")
end
  
function SetupCommands()
	-- Admin only
	addCommand( "start"					, MODE_FREE, "commands/start.lua", 0, "Start bot"  )

	addCommand( "ip"					, MODE_ONLY_ADM, "commands/admin/myip.lua", 2  )
	addCommand( "close"					, MODE_ONLY_ADM, "commands/admin/close.lua", 2  )
	addCommand( "uptime"				, MODE_ONLY_ADM, "commands/admin/uptime.lua", 2  )
	addCommand( "lua"					, MODE_ONLY_ADM, "commands/admin/lua.lua", 2  )
	addCommand( "user"					, MODE_ONLY_ADM, "commands/admin/user.lua", 2  )
	addCommand( "chat"					, MODE_ONLY_ADM, "commands/admin/chat.lua", 2  )
	addCommand( "bash"					, MODE_ONLY_ADM, "commands/admin/batch.lua", 2 )
	addCommand( "delete"				, MODE_ONLY_ADM, "commands/admin/forcedelete.lua", 2 ) 
	addCommand( "listchats"				, MODE_ONLY_ADM, "commands/admin/listchats.lua", 2 )
	addCommand( "mem"					, MODE_ONLY_ADM, "commands/admin/memmory.lua", 2 )
	addCommand( "redis"					, MODE_ONLY_ADM, "commands/admin/redis.lua", 2 )
end

function listCommandsData(groups)
	local cmd = {}
	for index ,b in pairs(g_commands) do 
        for i, mode in pairs(groups) do 
        	if b.mode == mode then 
        		cmd[#cmd+1] = b
        		break
        	end
        end
    end 
    return cmd
end

function listCommands(groups)
	local cmd = {}
	for index ,b in pairs(g_commands) do 
        for i, mode in pairs(groups) do 
        	if b.mode == mode then 
        		cmd[#cmd+1] = thisOrFirst(b.words)
        		break
        	end
        end
    end 
    return cmd
end


function listCommandsContext(msg, groups)
	groups = {MODE_CHATADMS, MODE_ONLY_ADM, MODE_FREE, MODE_NSFW, msg.chat.id}
	local cmd = {}

	local isChatAdmin = isUserChatAdmin(msg.chat.id, msg.from.id)
	local isBotAdmin = isUserBotAdmin(msg.from.id)
	
	local lang = g_lang
	local isChat = not(msg.chat.type == "private")
	if isChat then 
		lang = chats[msg.chat.id].lang
	end

	for index ,b in pairs(g_commands) do 
        for i, mode in pairs(groups) do 
        	if not cmd[mode] then 
        		cmd[mode] = {}
        	end
        	if b.mode == mode then 
        		local ok = true
        		if mode == MODE_CHATADMS and not isChatAdmin then
        			ok = false
        		elseif mode == MODE_ONLY_ADM and not isBotAdmin then
        			ok = false
        		end
        		if isChat then
        			ok = not isCommandDisabledInChat(msg.chat.id, b)
        			if mode == MODE_NSFW and chats[msg.chat.id].sfw == "yes" then 
        				ok = false
        			end
        		end
        		if ok then
        			cmd[mode][#cmd[mode]+1] = thisOrFirst(b.words, lang)
        		end
        		break
        	end
        end
    end 
    return cmd
end


function LoadCommand(uid, wordSet, mode, path, cooldown, desc )
    if not path then 
        return false
    end
    local data = {}

    if type(wordSet) == "string" then 
        wordSet = {wordSet}
    end
    data.words = wordSet


    data.uid = uid or g_commandUid

    g_commandUid = g_commandUid +1


    data.path = path
    data.mode = mode
    data.desc = desc
    data.cooldown = cooldown or 0
    data.lastUse = {}
    data.id = #g_commands+1

    g_commands[data.id] = data

    if g_moduleNow and g_moduleNow ~= "" and _G[g_moduleNow]  then
        data.module = g_moduleNow
        if not _G[g_moduleNow].commands then 
            _G[g_moduleNow].commands = {}
        end
        _G[g_moduleNow].commands[data.id] = thisOrFirst(data.words)
        
    end
end

function addCommand( word, mode, fnc, cooldown, desc )
	LoadCommand(nil, word, mode, fnc, cooldown, desc )
end

function getCommandByWord(word)
	word = word:lower()
	for i,command in pairs(g_commands) do 
		for _, cword in pairs(command.words) do 
			if word == cword then 
				return command
			end
		end
	end
	return nil
end

function isCommandDisabledInChat(chatId, command)
	--If the command mode is to chat admins or only admins, it cannot be disabled!
    if command.mode == MODE_CHATADMS or command.mode == MODE_ONLY_ADM then 
        return false
    end

    if chats[chatId] then

        if chats[chatId].data.disabledc then

            if (chats[chatId].data.disabledc[thisOrFirst(command.words)]) then
            	return true
            end
        	
        end

        if command.module and chats[chatId].data.disabledModule and chats[chatId].data.disabledc[command.module] then
            return true
        end

    end
    return false
end

function getCommandCooldown(msg, cmd)
	if msg.isChat then 
		if type(chats[msg.chat.id].data.custom_cooldown) ~= "table" then 
			chats[msg.chat.id].data.custom_cooldown = {}
		end
		local cmdIdentifier = thisOrFirst(cmd.words)
		return chats[msg.chat.id].data.custom_cooldown[cmdIdentifier] or cmd.cooldown or 0
	end
	return cmd.cooldown
end


function isCommandOnCooldown(msg, cmd)
	local cooldown = getCommandCooldown(msg, cmd)
    if not cmd.lastUse[msg.chat.id] then 
        cmd.lastUse[msg.chat.id] = 0
    	return false, 0, cooldown
    end
    local cooldownLeft = (cmd.lastUse[msg.chat.id] - os.time() + cooldown)
    cooldownLeft = math.max(0, cooldownLeft)
    if cooldownLeft > 0 then 
    	return true, cooldownLeft+1, cooldown
    end
    return false, cooldownLeft, cooldown
end

function findCommand(msg)
    local text = msg.text
    if text:sub(1,1) == "/" then
    	print("[COMMAND] {"..msg.chat.type ..  (msg.chat.type ~= "private" and (" : "..msg.chat.title)   or "") .." : "..msg.chat.id.."} "..(msg.from.username and ("@"..msg.from.username) or msg.from.first_name)..": "..msg.text)
    	logText("commands", "command=\""..msg.text.."\" by="..msg.chat.id.." name=\""..msg.from.first_name.."\" username=\""..(msg.from.username or "-").."\" at=\"".. (msg.chat.type ~= "private" and (msg.chat.title)   or msg.chat.type).."\" chatid="..msg.chat.id.."\n")
        local strArr = text:exploder(" ")
        local vaarg = nil
        strArr[1] = strArr[1]:gsub("/",""):lower()
        local targetChat = msg.chat.id
        if strArr[1] == "start" and msg.chat.type == "private" and strArr[2] then 
            if strArr[2]:match("([-%d]+)_(.-)_(.+)") then 
                local chatid, newCommand, args = strArr[2]:match("([-%d]+)_(.-)_(.+)")
                strArr[1] = newCommand
                vaarg = args
                targetChat = tonumber(chatid)
            elseif strArr[2]:match("([-%d]+)_(.+)") then 
                local chatid, newCommand = strArr[2]:match("([-%d]+)_(.+)")
                strArr[1] = newCommand
                targetChat = tonumber(chatid)
            end
        end

        local isBotAdmin = false
        for a,c in pairs(admins) do 
            if msg.from.id == tonumber(c) then 
                isBotAdmin = true
                break
            end
        end


        for index ,b in pairs(g_commands) do 
            local usedWord = ""
            for __, word in pairs( b.words) do
                if strArr[1]:lower() == word or (strArr[1]:lower() == word.."@"..g_botname) then 
                    local canRun = true
                    if b.mode == MODE_ONLY_ADM then 
                        canRun = isBotAdmin
                        if not canRun then 
                            if not users[msg.from.id]._tmp.warndc or users[msg.from.id]._tmp.warndc <= os.time() then 
                                users[msg.from.id]._tmp.warndc = os.time()+120
                                reply.delete(tr("default-command-botadmin"), 15, "HTML" )
                            end
                        end
                    elseif b.mode == MODE_CHATADMS then 
                        if msg.chat then
                            if not msg.isChat and not (targetChat ~= msg.chat.id and chats[targetChat]) then
                                reply.delete(tr("default-command-chatonly"), 15, "HTML" )
                                return false
                            end
                            local chatAdminCheck = targetChat == msg.chat.id and msg.chat.id or targetChat
                            if  not isUserChatAdmin(targetChat, msg.from.id) then                    
         
                                local chatid = targetChat ~= msg.chat.id and targetChat or msg.chat.id 
                                if not chats[chatid]._tmp.warndc or chats[chatid]._tmp.warndc <= os.time() then 
                                    chats[chatid]._tmp.warndc = os.time()+120
                                    reply.delete(tr("default-command-nsfw"), 15, "HTML" )
                                end
                                canRun = false
                            end
                        end
                    elseif b.mode == MODE_NSFW then
                    	local chatid = targetChat ~= msg.chat.id and targetChat or msg.chat.id 
                        if msg.chat and chats[chatid] and chats[chatid].sfw == "yes" then 
                        	
                            if not chats[chatid]._tmp.warndc or chats[chatid]._tmp.warndc <= os.time() then 
                                chats[chatid]._tmp.warndc = os.time()+120
                                reply.delete(tr("default-command-chatdmin"), 15, "HTML" )
                            end
                            canRun = false
                        end
                    elseif b.mode ~= MODE_FREE and b.mode ~= MODE_UNLISTED then 
                        if tonumber(msg.chat.id) ~= b.mode then 
                            canRun = false
                        end
                    end

	                if isCommandDisabledInChat(msg.chat.id, b) then 
	                    if msg.chat and chats[msg.chat.id] then
	                        canRun = false
	                        if not chats[msg.chat.id]._tmp.warndc or chats[msg.chat.id]._tmp.warndc <= os.time() then 
	                            chats[msg.chat.id]._tmp.warndc = os.time()+120
	                            reply.delete(tr("default-command-disabled"), 15, "HTML" )
	                        end
	                    end
	                end
                    
	                if canRun then 
	                   	local isCooldown, cooldownLeft, commandCooldown = isCommandOnCooldown(msg, b)
	                    if not isBotAdmin and isCooldown  then 
	                      	if not b.rcold then 
	                            reply.delete(tr("default-command-cooldown" ,commandCooldown, cooldownLeft  ))
	                            b.rcold = true
	                        end
	                        canRun = false
	                    end 
	    
	                    if canRun then

	                        g_moduleNow = b.module
	                        if b.mode ~= MODE_UNLISTED then
	                            if not configs["stats"] then  
	                                configs["stats"] = {}
	                            end
	                        	if not configs["stats"][word] then 
	                                configs["stats"][word] = 0
	                            end
	                            configs["stats"][word] = configs["stats"][word] + 1
	                        end

	                        b.lastUse[msg.chat.id] = os.time()

	                        if type(b.path) == 'function' then
	                            --local ret,err = pcall(b.path, user, text, strArr)
	                            local success,err = pcall(b.path, msg, text, strArr)
	                            
	                            b.rcold = false
	                            return success,true,err, ret
	                        else
	                            local Loader = function( name )
	                                dofile(name)
	                            end
	                            local ret, err = pcall(Loader, b.path)
	                            if not ret then
	                                return false, true, err or "invalid file"
	                            end
	                            if not OnCommand then 
	                                return false, true, "No OnCommand(msg, text, args) found in file ".. b.path
	                            end
	                            msg.isCommand = true
	                            ret,err = pcall(OnCommand, msg, text, strArr, targetChat,vaarg)
	                            if not ret then 
	                                return false, true, err, ret
	                            end
	                            OnCommand = nil
	                            return true, true,err, ret
	                        end
	                    end
	                end
	            end
	        end
        end
    end
    return true, false
end