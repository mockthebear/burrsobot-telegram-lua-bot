function OnCommand(msg, text, args)
	if birthday.revertbd(msg.chat.id) then 
		reply(tr("bd-reverted"))
	end
end

