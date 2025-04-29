function OnCommand(msg, text, args)
	if not args[2] then 
		say("kd")	
		return
	end
	local tgt = getTargetUser(msg, true, true)
	if not tgt or not users[tgt.id] then 
		say("Unknow user... but its username is banned")
		noraid.staticRaiders[args[2]:lower()] = (noraid.staticRaiders[args[2]:lower()] == true) and nil or true
	else
		users[tgt.id].noraid_banned = (not users[tgt.id].noraid_banned) and true or false
		say.html("User "..formatUserHtml(tgt).." is banned as "..tostring(users[tgt.id].noraid_banned) )

		noraidchat.announce_ban("[2]User "..formatUserHtml(tgt).." is banned = <b>"..tostring(users[tgt.id].noraid_banned).."</b> with command /evil by "..formatUserHtml(msg))
		SaveUser(tgt.id)
	end
end
