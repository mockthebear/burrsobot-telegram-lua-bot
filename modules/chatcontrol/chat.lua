function OnCommand(user, msg, args)
	if not args[2] then 
		say("kd")	
		return
	end
	args[2] = tonumber(args[2]:lower()) or args[2]:lower()
	local chatsF = {}
	if not chats[args[2]] then 
		local found = false
		for i,b in pairs(chats) do 
			if (b.name or b.title):lower():find(args[2])  then 
				args[2] = i 
				found = true
				chatsF[#chatsF+1] = (b.name or b.title) ..' - '..b.id
			end
		end
		if not found then 
			reply("nothing")
			return
		end	
	end

	if #chatsF > 1 then 
		local fn = ""
		for a,c in pairs(chatsF) do 
			fn = fn .. c .. '\n'
		end

		say.big(fn)
		return
	end

	local cid = args[2]
	local usr = "Users:\n"
	for a,c in pairs(users) do 
		if tonumber(a) and c.joinDate and c.joinDate[cid] then 
			usr = usr .. '<a href="tg://user?id='..c.telegramid..'">'..c.first_name..'</a>\n'
		end	
	end

	say.big(Dump(chats[cid]))


	local keyb2 = {}
    keyb2[1] = {}
    keyb2[2] = {}
    keyb2[1][1] = {text = tr("Sair do chat"), callback_data = "lve:"..cid }
    keyb2[2][1] = {text = tr("Ban chat"), callback_data = "bnch:"..cid }
    local kb3 = cjson.encode({inline_keyboard = keyb2 })

    bot.sendMessage(user.chat.id, "chat: "..chats[cid].title:htmlFix().."\n"..cid, "HTML", true, false, nil, kb3)
    
end 
