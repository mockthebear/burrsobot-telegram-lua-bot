function OnCommand(msg, text, args)
	if not args[2] then 
		say("kd")	
		return
	end
	local tgt = getTargetUser(msg, true, true)
	if not tgt or not users[tgt.id] then 
		say("Unknow user.")
		return
	end
	users[tgt.id].noraid_banned = (not users[tgt.id].noraid_banned) and true or false
	say.html("User "..formatUserHtml(tgt).." is banned as "..tostring(users[tgt.id].noraid_banned) )
	noraid.save()

	noraidchat.announce_ban("[2]User "..formatUserHtml(tgt).." is banned = <b>"..tostring(users[tgt.id].noraid_banned).."</b> with command /evil by "..formatUserHtml(msg))
	SaveUser(tgt.id)
end
