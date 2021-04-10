function OnCommand(user, msg, args)
	say("Saving")
	local t = os.clock()
	for i,b in pairs(chats) do 
		SaveChat(i)
	end
	local ret = (os.clock()-t)

	say("Saved on "..ret..",\n closing.")

	os.exit(0)	
end