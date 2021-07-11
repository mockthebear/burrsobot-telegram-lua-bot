function OnCommand(msg, aaa, args, targetChat)
	if targetChat ~= msg.chat.id then
		antibot.sendCapthaCommand(targetChat, msg, msg.chat.id)
	end
end