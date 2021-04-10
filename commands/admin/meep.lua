function OnCommand(user, msg, args)
	if not args[2] then 
		say("kd")	
		return
	end
	args[2] = args[2]:lower()
	if not users[args[2]] then 
		if tonumber(args[2]) then 
			local uid = tonumber(args[2])
			for un, b in pairs(users) do 
				if uid == b.telegramid then 
					say(Dump(users[un] or {"Unknow"}))
					return
				end
			end
		end
	end
	say(Dump(users[args[2]] or {"Unknow"}))
end
