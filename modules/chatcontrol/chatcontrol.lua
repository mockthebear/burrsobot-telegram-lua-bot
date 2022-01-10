local chatcontrol = {
	priority = DEFAULT_PRIORITY-10010,
	bannedchat = {}
}




function chatcontrol.load()
	chatcontrol.bannedchat = configs["chatcontrol"] or {}
end

function chatcontrol.save()
	configs["chatcontrol"] = chatcontrol.bannedchat
	SaveConfig("chatcontrol")
end


function chatcontrol.onCallbackQueryReceive(msg, id)
	if msg.data:match("lve:([%-%d]+)") then
		if isUserBotAdmin(msg.from.id) then 
			local cid = tonumber(msg.data:match("lve:([%-%d]+)"))
			bot.sendMessage(cid, "Quantidade máxima de chats atingida.")
			deleteChat(cid)
			say("Left chat: "..cid)
		end
		return KILL_EXECUTION
	elseif msg.data:match("ins:([%-%d]+)") then
		if isUserBotAdmin(msg.from.id) then  
			local cid = tonumber(msg.data:match("ins:([%-%d]+)"))
			if chats[cid] then
				local usr = ""
				for a,c in pairs(users) do 
					if c.joinDate and c.joinDate[cid] then 
						usr = usr .. '<a href="tg://user?id='..c.telegramid..'">'..a..'</a>\n'
					end
				end
				say.admin(usr, "HTML")
				say.admin(Dump(chats[cid]), "HTML")
				say("Inspect "..cid)
			else 
				say("deu nao")
			end
			deploy_answerCallbackQuery(msg.id, "yey", "true")
		else
			deploy_answerCallbackQuery(msg.id, "NO", "true")
		end
		return KILL_EXECUTION
	elseif msg.data:match("bnch:([%-%d]+)") then
		if isUserBotAdmin(msg.from.id) then 
			local cid = tonumber(msg.data:match("bnch:([%-%d]+)"))
			if chats[cid] then
				bot.sendMessage(cid, "Chat banned permanently!")
				deleteChat(cid)
				chatcontrol.bannedchat[cid] = true
				say.admin("bannedchat["..cid.."] = true")
			else 
				say("Unknown chat")
			end
		end
		return KILL_EXECUTION
	end
end

function chatcontrol.onNewChat(msg, id)
	local mc = {}
    if not chatcontrol.bannedchat[id] then
        mc = bot.getChatMembersCount(id)
        if not mc or not mc.result then 
            bot.leaveChat(id)
            return KILL_EXECUTION
        end
    end
    local memberCount = mc.result or 0

    local adms = bot.getChatAdministrators(id)

    local adms = "No admins"
    if adms and adms.ok then
        local str = ""
        for i,b in pairs(adms.result) do
            str = str .. ('<a href="tg://user?id='..b.user.id..'">'..(b.user.username and ("@"..b.user.username) or b.user.first_name)..'</a>')
        end 
        adms = str
    end

    if chatcontrol.bannedchat[id] then 
        say.admin("The chat is banned.: "..chats[id].name:htmlFix().."\n\nLEFT CHAT "..id.."!\n\n"..adms, "HTML")
        say.admin(Dump(msg), "HTML")
        bot.sendMessage(id, "This chat dont have authorization to use this bot (403).\n\n<b>Please do not add this bot on this specific chat as i am going to leave again as many times needed.</b>", "HTML")
        bot.leaveChat(id)
        return KILL_EXECUTION
    end

    local uname = ""
    local chat = bot.getChat(id)
    if not chat.ok then 
        return KILL_EXECUTION
    end

    say.admin(Dump(msg), "HTML")
    say.admin(Dump(chat), "HTML")
    
    local keyb2 = {}
    keyb2[1] = {}
    keyb2[2] = {}
    keyb2[3] = {}
    keyb2[1][1] = {text = tr("Sair do chat"), callback_data = "lve:"..id }
    keyb2[2][1] = {text = tr("Inspect chat"), callback_data = "ins:"..id }
    keyb2[3][1] = {text = tr("Ban chat"), callback_data = "bnch:"..id }

    local kb3 = cjson.encode({inline_keyboard = keyb2 })
    say.admin("Novo chat: "..chats[id].name:htmlFix().."\n"..adms..uname.."\nMembers: "..memberCount, "HTML", true, false, nil, kb3)

    return CONTINUE_EXECUTION
end


function chatcontrol.loadCommands()
	addCommand( {"chat"}		, MODE_FREE,  getModulePath().."/chat.lua", 2 , "chatcontrol-desc" )
	addCommand( {"groupphoto"}		, MODE_FREE,  getModulePath().."/groupphoto.lua", 2 , "chatcontrol-groupphoto" )
end

function chatcontrol.loadTranslation()
	g_locale[LANG_US]["chatcontrol-desc"] = "Search for a chat and display some info"
	g_locale[LANG_BR]["chatcontrol-desc"] = "Busca um chat e mostra suas informaçoes"

	g_locale[LANG_BR]["chatcontrol-groupphoto"] = "Define foto do chat"
	g_locale[LANG_BR]["chatcontrol-groupphoto"] = "Define the chat photo"
end


return chatcontrol