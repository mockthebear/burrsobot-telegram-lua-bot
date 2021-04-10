function OnCommand(user, msg, args)
	local str = ""
	local n = 0
	for i,b in pairs(chats) do 
		str = str..n.." - " .. (b.title or b.name or "???") .. " - " .. i .. "\n"
		n = n +1
	end
	say.big(str)
end