function OnCommand(user, txt, args)
	for i=1,#args-1 do 
		args[i] = args[i+1]
	end
	args[#args] = nil
	if user.reply_to_message and not args[1] then 

		local id = os.time()
		
		local keyb2 = {}
        keyb2[1] = {}
        keyb2[2] = {}
        keyb2[1][1] = {text = tr("good"), callback_data = "gqte:"..id }
        keyb2[2][1] = {text = tr("bad"), callback_data = "bqte:"..id }
        local JSON = require("JSON")
        local kb3 = JSON:encode({inline_keyboard = keyb2 })

		local msg1 = bot.sendMessage(quotes.chat,"Quote request <b>"..id.."</b> by "..formatUserHtml(user)..'\nReply this message to add comments', "HTML", true, false, nil, kb3)
        local msg2 = bot.forwardMessage(quotes.chat, user.reply_to_message.chat.id, false, user.reply_to_message.message_id)


        configs["quote_rep"][id] = {
			quote = {user.reply_to_message, user.from.username},
			good = 0,
			bad = 0,
			msg1=msg1,
			msg2=msg2,
			chat = user.reply_to_message.chat.id,
			votes = {},
			duration = os.time() + 1800,
		}
		SaveConfig("quote_rep")


        reply.html(tr("quotes-message-quoterequest", id, formatUserHtml(user)))

        
		--StoreMessage(user.reply_to_message, user.from.username)
	else 

		if args[1] == "del" and user.from.id == 81891406 then 
			for i,b in pairs(args) do 
				if i ~= 1 then
					say("del: "..b)
					db.executeQuery("DELETE FROM `quote` WHERE `id`="..b..";")
				end
			end
			return
		end
		local recv = false
		if not args[1] or args[1]:lower() == "random" then 
			local ret = db.getResult("SELECT id FROM `quote` ORDER BY id DESC LIMIT 1")
			if ret then
				args[1] = math.random(0,ret:getDataInt('id'))
				ret:free()
				recv = true
			end
		end
		quotes.showQuote(user.chat.id, args[1], args[2], recv, 0, args[1])
	end	
end
