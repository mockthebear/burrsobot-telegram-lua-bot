function OnCommand(user, msg, args)
	local dt = (os.time()-g_startup)
	local h = math.floor(dt/3600)
	dt = dt % 3600
	local sec = dt%60
	local min = math.floor(dt/60)	
	say("Uptime is: "..string.format("%2.2d:%2.2d:%2.2d",h,min,sec))
end