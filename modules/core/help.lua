function OnCommand(msg, text, args)
	if not args[2] then 
    	reply(tr("core-help-how"))
      return
    end
    args[2] = args[2]:lower()
    local comm = nil
    for i,b in pairs(g_commands) do 
		if type(b.words) == "table" then 
			for a,c in pairs(b.words) do 
				if c == args[2] then
					comm = b
					break
				end
			end
		else 
			if b.words == args[2] then
				comm = b
				break
			end
		end
	end
	if not comm then 
		reply(tr("core-hel-nocmd",args[2]))
		return 
	end
	bot.sendMessage(msg.chat.id,tr("core-help-command", args[2], comm.cooldown, tr(comm.desc and comm.desc or "(sem descrição)") ), "HTML")
end

