function OnCommand(user, msg, args)
	if not args[2] then 
		say("kd")	
		return
	end
	local usr = nil
	args[2] = args[2]:lower()
	if not users[args[2]] then 
		if tonumber(args[2]) then 
			local uid = tonumber(args[2])
			usr = getUserById(uid)
		else 
			args[2] = args[2]:gsub("@", "")	
		end
	end
	if not usr then 
		usr = getUserByUsername(args[2])
	end
	local JSON = require("JSON")
	say(Dump(usr))
	local cs = ""
	if not usr then 
		reply("No user by "..args[2])
		return
	end
	for i,b in pairs(usr.joinDate) do 
		if chats[i] then 
			local chatData = bot.getChatMember(i, usr.telegramid)
			if chatData.result then
				cs = cs .. i..": ".. tostring((chats[i] or {name=i}).title).." -> <b>"..chatData.result.status .."</b>\n"
			else 
				cs = cs .. "Not in to: "..tostring((chats[i] or {name=i}).title).." [["..cjson.encode(chatData).."]\n"
			end
		end
	end
	print(cs)
	say.html("Its on chats: "..cs)
	bot.sendMessage(g_chatid,'<a href="tg://user?id='..usr.telegramid..'">User!</a>.', "HTML")

	SaveUser(args[2])
end
