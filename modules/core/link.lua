function OnCommand(msg, txt, args)
	local link = bot.createChatInviteLink(msg.chat.id, os.time()+120, 4)
	if link.ok then 
		reply("Here is the invite link:\n"..link.result.invite_link.."\nThis link will last for two minutes.")
	else 
		reply(link.description)
	end
end