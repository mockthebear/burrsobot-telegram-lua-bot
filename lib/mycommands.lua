function tryRestore(str) 
	if str:sub(1,1) == "{" then 
		str = str:sub(2, -2)
		local arr = {}
		str = str .. ','
		for ind,val in str:gmatch("(.-):(.-),") do 
			local ok = true
			if val == "true" then 
				val = true
			elseif val == "false" then 
				val = false
			elseif tonumber(val) then 
				val = tonumber(val)
			elseif #val > 0 then 
				if val:sub(1) == "{" then 
					return {}
				end
			else 
				ok = false
			end
			if ok then 
				arr[ind] = val
			end
		end
		return arr
	else 
		return {}
	end
end

function populateCommands(cmdList)
	local allCommands = {}
	for i,b in pairs(cmdList) do 
		for _, word in pairs(b.words) do 
			allCommands[#allCommands+1] = word
		end 
	end
	g_redis:del("list:commands")
	for _, word in pairs(allCommands) do 
		g_redis:sadd("list:commands", word)
	end
end


function hasCommandsChanged(cmdList, storedCmd)
	local allCommands = {}
	for i,b in pairs(cmdList) do 
		for _, word in pairs(b.words) do 
			allCommands[word] = 1
		end 
	end

	local storedCommands = {}
	for i, word in pairs(storedCmd) do 
		storedCommands[word] = 1
		if allCommands[word] then 
			allCommands[word] = 0
			storedCommands[word] = 0
		end
	end

	local extra = 0

	for i,b in pairs(allCommands) do
		if b == 1 then 
			extra = extra +1
		end
	end

	for i,b in pairs(storedCommands) do
		if b == 1 then 
			extra = extra +1
		end
	end

	print("Command difference: "..extra)

	return extra > 0
end

function SetupMyCommands()

	local allCommands = listCommandsData()


	local cmdList = g_redis:smembers("list:commands")

	if not cmdList or #cmdList == 0 or hasCommandsChanged(allCommands, cmdList) then

		populateCommands(allCommands)

		local selCommands = listCommandsData({MODE_FREE})
		bot.deleteMyCommands(cjson.encode({type="all_private_chats"}))  
		bot.deleteMyCommands(cjson.encode({type="all_private_chats"}), "pt")  
		bot.deleteMyCommands(cjson.encode({type="all_private_chats"}), "en")  
		setCommandContextAutoLanguage(selCommands, "all_private_chats")


		selCommands = listCommandsData({MODE_FREE, MODE_CHATONLY})
		setCommandContextAutoLanguage(selCommands, "all_group_chats")
		bot.deleteMyCommands(cjson.encode({type="all_group_chats"}), "pt")  
		bot.deleteMyCommands(cjson.encode({type="all_group_chats"}), "en")  


		selCommands = listCommandsData({MODE_FREE, MODE_CHATONLY, MODE_CHATADMS})
		setCommandContextAutoLanguage(selCommands, "all_chat_administrators")
		bot.deleteMyCommands(cjson.encode({type="all_chat_administrators"}), "pt")  
		bot.deleteMyCommands(cjson.encode({type="all_chat_administrators"}), "en") 


		for chatid,b in pairs(chats) do
			if b.data.disabledc then
				local len = 0
				for _, isDisabled in pairs(chats[chatid].data.disabledc) do 
					len = len+1
				end
				if len > 0 then 
					chats[chatid].data.changedCommand = true
					SaveChat(chatid)
				end
			end
		end
	end
end

function wipeCommandas(chatid, userid)
	local valid = {"chat_member", "chat", "chat_administrators"}
	for _, mode in pairs(valid) do 
		bot.deleteMyCommands(cjson.encode({type=mode, chat_id=chatid, user_id=userid}))  
	end
end

function inspectCommands(chatid, userid)
	local valid = {"chat_member", "chat", "chat_administrators",  "all_chat_administrators", "all_group_chats", "all_private_chats", "default"}
	for _, mode in pairs(valid) do 
		local resp = bot.getMyCommands(cjson.encode({type=mode, chat_id=chatid, user_id=userid}))  
		if resp.ok then 
			local result = resp.result
			local str = ""
			for i,b in pairs(result) do 
				str = str .. "/"..b.command.." "
			end
			reply.html("Comands in <b>"..mode.."</b> with chat: "..tostring(chatid)..":\n<code>"..str.."</code>")
		else 
			reply.html("Invalid:\n<code>"..cjson.encode(resp):htmlFix().."</code>")
		end
	end
end

function updateCommandListInChat(chatid)
	local cmdList = listCommandsData({MODE_FREE, MODE_CHATONLY, MODE_NSFW, chatid})


	wipeCommandas(chatid)

	local validCommands = {}
	for i, cmd in pairs(cmdList) do 
		local ok = not isCommandDisabledInChat(chatid, cmd)
        if cmd.mode == MODE_NSFW and chats[chatid].data.sfw then 
        	ok = false
        end
        if ok then 
        	validCommands[i] = cmd
        end
	end

	setCommandsToContext(validCommands, "chat", chats[chatid].data.lang, chatid)

	validCommands = {}
	cmdList = listCommandsData({MODE_FREE, MODE_CHATONLY, MODE_NSFW, MODE_CHATADMS, chatid})
	for i, cmd in pairs(cmdList) do 
		local ok = not isCommandDisabledInChat(chatid, cmd)
        if cmd.mode == MODE_NSFW and chats[chatid].data.sfw then 
        	ok = false
        end
        if ok then 
        	validCommands[i] = cmd
        end
	end

	setCommandsToContext(validCommands, "chat_administrators", chats[chatid].data.lang, chatid)
end


function setCommandContextAutoLanguage(selCommands, context, chatid, userid)
	for indx, lang in pairs(g_locale.langs) do
		local previousLang = g_lang
		g_lang = indx
		local languageCode = lang
		--bot.deleteMyCommands(cjson.encode({type=mode, chat_id=chatid}), languageCode)

		if languageCode then 
			languageCode = languageCode:sub(1,2)
		end

		setCommandsToContext(selCommands, context, indx, chatid, userid, languageCode)
		g_lang = previousLang
	end
	setCommandsToContext(selCommands, context, 1, chatid, userid)
end


function setCommandsToContext(commands, context, wordIndex, chatid, userid, languageCode)
	local commandList = {}
	
	print("[My Commands] Setting commands for "..context..(chatid and (chats[chatid] and (" for chat "..(chats[chatid].title and chats[chatid].title or chatid) ) or "?") or ""))
	for _,b in pairs(commands) do 
		local word = b.words[wordIndex] or b.words[1]
		local desc = tr(b.desc)
		if not desc or desc == "" then 
			desc = word
		end
		if desc:len() >= 256 then
			desc = desc:sub(1,255)
		end
		commandList[#commandList+1] = {command=word, description=desc}
	end

	local mode = context
	local res = bot.setMyCommands(cjson.encode(commandList), cjson.encode({type=mode, chat_id=chatid, user_id=user_id}))
	if res.ok then 
		print("[My commands] Set "..(#commandList).." commands on language "..tostring(languageCode).." to "..mode)
		return true
	else 
		if res.error_code == 429 then 
			print("[My Commands] Uh oh, iv'e been rate limited: "..cjson.encode(res.parameters))
			--local waitTime = res.parameters.retry_after
			--ngx.sleep(waitTime)
			--print("[My Commands] Ready to retry")
			return false --setCommandsToContext(commands, context, wordIndex, chatid, userid)
		else
			print(cjson.encode(res).." = "..tostring(languageCode))
			return false
		end
	end
end



