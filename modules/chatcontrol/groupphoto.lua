function OnCommand(user, msg, args)
    
    user.from.username = user.from.username:lower()


	if not user.reply_to_message then 
		reply("Reply a message with this command please.")
		return
	end
	if not user.reply_to_message.photo then 
		reply("Reply in a message with a photo.")
		return
	end
	local dat = user.reply_to_message.photo[3]
	if not dat then 
		dat = user.reply_to_message.photo[2]
		if not dat then 
			dat = user.reply_to_message.photo[1]
			if not dat then 
				say("Photo too small to set as a group photo.") 
				return
			end
		end
	end	
	local fid = dat.file_id
	bot.sendChatAction(g_chatid, "upload_photo")
	local ret = bot.downloadFile(fid, "../cache/bg.jpg")
	if ret.success then 
	   local ret = bot.setChatPhoto(g_chatid, "../cache/bg.jpg")
	   if not ret.ok then 
	   		say(ret.description)
	   end
	   DumpTable(ret)
	else 
		reply("File not found.")
	end
	return true
end