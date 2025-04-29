local module = {
	priority = DEFAULT_PRIORITY - 10001000,
}

--[ONCE] runs when the load is finished
function module.load()

end

--[ONCE] runs when eveything is ready
function module.ready()

end

--Runs at the begin of the frame
function module.frame()

end

--Runs some times
function module.save()

end

module.tatujapachannels = {
	[-1001540221046] = 'raimundo',
	[-1002080621037] = 'tatu',
}

function module.onTextReceive(msg) 
	if module.tatujapachannels[msg.chat.id] and not msg.message_thread_id then
		
		local usr = bot.getChatMember(msg.chat.id, msg.from.id)
		if usr.ok and usr.result.status == "member" then 
			bot.restrictChatMember(msg.chat.id, msg.from.id, -1, false, false, false, false)
			deploy_deleteMessage(msg.chat.id, msg.message_id)
			local sent = bot.sendMessage(msg.chat.id, "Hey there "..formatUserHtml(msg)..". This chat is only for comments. Please leave and don't join again. You will be kicked in one minute", "HTML", false, false)
			--say(cjson.encode(sent))
			scheduleEvent(60, function()
				bot.kickChatMember(msg.chat.id, msg.from.id, os.time()+60) 
				bot.deleteMessage(msg.chat.id, sent.result.message_id)
			end)
		end
	end

	
end 


function module.onNewChatParticipant(msg) 
	if module.tatujapachannels[msg.chat.id] then
		local res = bot.restrictChatMember(msg.chat.id, msg.new_chat_participant.id, os.time()+120, false, false, false, false)
		local sent = bot.sendMessage(msg.chat.id, "Hey there "..formatUserHtml({from=msg.new_chat_participant})..". This chat is only for comments. Please leave and don't join again. You will be kicked in one minute", "HTML", false, false, msg.message_id)
		scheduleEvent(60, function()
			local usr = bot.getChatMember(msg.chat.id, msg.new_chat_participant.id)
			if usr.ok and usr.result.status ~= "left" then 
				bot.kickChatMember(msg.chat.id, msg.new_chat_participant.id, os.time()+60) 
			end
			deploy_deleteMessage(msg.chat.id, sent.result.message_id)
			deploy_deleteMessage(msg.chat.id, msg.message_id)
		end)
		return KILL_EXECUTION
	end
end

function module.loadCommands()
	--addCommand( {"bolo", "cake"}		, MODE_FREE,  getModulePath().."/bolo.lua", 2 , "example-desc" )

	addCommand( "yuki", -1001069476581, function(msg, text, attrs) --No chat pra tudo.
	    bot.sendPhoto(g_chatid, "../media/yuki.jpg")
	end)



	addCommand( "elliot", MODE_UNLISTED, function(msg, text, attrs) --No chat pra tudo.
	    bot.sendDocument(g_chatid, "CgADAQADUAAD1zhhRm7HUuui-zKVFgQ") 

	    if isUserChatAdmin(msg.chat.id, msg.from.id) then
	    	if msg.reply_to_message and msg.reply_to_message.from.username == "snowdeer" then
				bot.restrictChatMember(msg.chat.id, msg.reply_to_message.from.id, os.time() +60, false, false, false, false)
				say("queta ae elliot.")
			end
		end
	    --users["snowdeer"].deleted = os.time() + 60
	   end)
	addCommand( "snowdeer", MODE_UNLISTED, function(msg, text, attrs) --No chat pra tudo.
	    bot.sendPhoto(g_chatid, "../media/durrr.png")
	end)


	addCommand( {"mocc","mock"}					, MODE_UNLISTED, getModulePath().."/mocc.lua",3 , "Mostra ummock. Basta chamar /mocc")

	addCommand( "cancelawage"				, MODE_UNLISTED, getModulePath().."/cancelawage.lua",2 	, "cancela")

 
	addCommand( "lt"	, MODE_UNLISTED, function(msg, text, attrs)
		reply("que.")
	end, 1)


	addCommand( "🍆"	, MODE_UNLISTED, function(msg, text, attrs) --paws an pamps
		if not users[msg.from.id].pinto then 
			users[msg.from.id].pinto = math.random(2,25)
		end
		users[msg.from.id].pinto = users[msg.from.id].pinto + math.random(0, 1)
		local pintoLen = users[msg.from.id].pinto 
		reply.html(tr("%s tem um total de ", formatUserHtml(msg))..string.rep("🍆", pintoLen)..".")
		SaveUser(msg.from.username)
	end, 5)

	addCommand( {"maluco", "twitter"}	, MODE_UNLISTED, function(msg, text, attrs) --paws an pamps
		bot.sendVideo(msg.chat.id,  "mlk.mp4")
	end, 5)

	addCommand( {"sexta", "sextafeira"}	, MODE_UNLISTED, function(msg, text, attrs) --paws an pamps
		local rand = math.random(0, 1000)
		if rand <= 250 then
			bot.sendVideo(msg.chat.id, "BAACAgEAAxkBAAEnIKFk6LmoeAvO4d4CTvkuAkgaYE0jlQACIAMAApq94UZaV_QUAkDf8jAE")
		elseif rand <= 500 then
			bot.sendVideo(msg.chat.id, "BAACAgEAAxkBAAEnIKJk6LmoJH6lPMzKHbTKqWGHlVr5QQACJAADOfuxRLKc2qq-udwoMAQ")
		elseif rand <= 750 then
			bot.sendPhoto(msg.chat.id, "AgACAgEAAxkBAAEnvWJlMoiYEJPdjWuK9MuEb7JdCvs5CAACoKoxG-DsWEevkvRnc5FeRQEAAwIAA3MAAzAE")
		else 
			bot.sendDocument(msg.chat.id, "CQACAgEAAxkBAAEnvWhlMojOoUUV1TIE8b7opYYoWmQQgwACHwMAApq94Ub5hd9Y3CflYDAE")
		end
	end, 5)


	addCommand( "filledmypants"	, MODE_UNLISTED, function(msg, text, attrs) 
		if not msg.reply_to_message then  
			reply("Hey, first send the video, then reply the video you want to convert with this command")
			return
		end
		local otherMsg = msg.reply_to_message

		local objType = ""
		if otherMsg.animation  then 
			objType = 'animation'
		elseif otherMsg.document then
			objType = 'document'
		else 
			objType = 'video'
		end
		if not otherMsg.animation and not otherMsg.video and not otherMsg.document  then 
			reply("Hey, a video plis...")
			return
		end

		if otherMsg[objType].mime_type ~= "video/mp4" and otherMsg[objType].mime_type ~= "video/webm" then 
			reply("Hey, a valid video plis...")
			return
		end

		reply("Downloading...")
		local suc = bot.downloadFile(otherMsg[objType].file_id, "Animation_0.mp4")
		if not suc.success then 
			reply("Oh shit. error downloading :/"..Dump(suc))
			return
		end

		local shell = require "resty.shell"
		local text = [[
input_file="Animation_0.mp4"
output_file="output.webm"
rm $output_file
# Get the original duration in seconds
duration=$(ffmpeg -i "$input_file" 2>&1 | grep "Duration" | awk '{print $2}' | tr -d , | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')

# Calculate the speed-up factor to make the duration slightly less than 3 seconds
target_duration=2.4
speed_factor=$(echo "$duration / $target_duration" | bc -l)

# Resize, speed up, and make the magenta background transparent
ffmpeg -i "$input_file" -vf "scale='if(gt(iw,ih),512,-2)':'if(gt(iw,ih),-2,512)',setpts=PTS/$speed_factor,colorkey=0xFF00FF:0.1:0.2" -an -c:v libvpx-vp9 -pix_fmt yuva420p "$output_file"
		]]
		local ok, stdout, stderr, reason, status = shell.run(text, nil, 16000, 8128)
	    if not status then 
	      reply(reason)
	      return
	    end
	   	reply.html("Status <b>"..status.."</b> ("..(ok and "ok" or reason)..")")
	   	say.big(stdout or "?")
	   	say.big(stderr or "?")
	    bot.sendDocument(msg.chat.id, "output.webm", "There you go strigi you stimky")
	end, 1)

	addCommand( "🍑"	, MODE_UNLISTED, function(msg, text, attrs) --paws an pamps

		local gmsg = reply("🤔🍑.........🍆")
		scheduleEvent( 2, function(m)
		
			bot.editMessageText(m.result.chat.id, m.result.message_id, nil ,"🤔🍑.......🍆")
		
			bot.editMessageText(m.result.chat.id, m.result.message_id, nil ,"🤔🍑......🍆")
		
			bot.editMessageText(m.result.chat.id, m.result.message_id, nil ,"🤔🍑.....🍆")
		
			bot.editMessageText(m.result.chat.id, m.result.message_id, nil ,"🤔🍑....🍆")
		
			bot.editMessageText(m.result.chat.id, m.result.message_id, nil ,"😞🍑...🍆")
		
			bot.editMessageText(m.result.chat.id, m.result.message_id, nil ,"😞🍑..🍆")
		
			bot.editMessageText(m.result.chat.id, m.result.message_id, nil ,"😞🍑.🍆")

			bot.editMessageText(m.result.chat.id, m.result.message_id, nil ,"😞🍑🍆")

			bot.editMessageText(m.result.chat.id, m.result.message_id, nil ,"💥💥")
		
			bot.editMessageText(m.result.chat.id, m.result.message_id, nil ,"🌝")
		end, gmsg)
		
	end, 50)
end

function module.loadTranslation()

	g_locale[LANG_US]["%s tem um total de "] = "%s has an total of "
end


return module