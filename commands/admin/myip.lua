function OnCommand(user, msg, args)
	local ip = httpsRequest("http://ip4.me/")
	if ip then 
		ip = ip:match(">([%d.]+)</font>")
		say("My ip is "..tostring(ip))
	else 
		say("Failed")
	end	
end