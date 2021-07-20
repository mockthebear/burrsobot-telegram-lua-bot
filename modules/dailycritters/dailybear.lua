function OnCommand(msg, aa, strArr, targetChat)
	if dailycritters.owners[msg.from.username:lower()] then 
		if not msg.reply_to_message then 
			reply("Send this command replying to a message!")
			return
		end
		
		local alt = msg.reply_to_message
		local ret, err = dailycritters.scheduler(msg.reply_to_message, 1)
		if not ret then 
			say("Fail to schedule: "..(err == 1 and "Must be a photo" or (err == 2 and "No caption" or "deu ruim")) )
		else 
			deploy_deleteMessage(msg.chat.id, msg.reply_to_message.message_id)
			deploy_deleteMessage(msg.chat.id, msg.message_id)
		end
	else
		reply("you cant use this.")
	end
end