local JSON = require("JSON")
local dailycritters = {
	channel = {
		[1] = "@DailyBears",
		[2] = "@DailyRaccoons",
	},

	internalConfigId = "daily",

	queryId = "daily",

	owners = {
		["mockthebear"] = 1,	
		["ryuuie"] = 2,	
	},


	voteId = {
		[1] = {"❤️", name = "love"},
		[2] = {"👍", name = "like"},
		[3] = {"👎", name = "not liked"},

		
	},

	votesize = 3 ,

	keyboardWidth = 4,

}

function dailycritters.save()
	configs[dailycritters.internalConfigId] = dailycritters.messages
	SaveConfig(dailycritters.internalConfigId)
end

function dailycritters.load()
	dailycritters.messages = configs[dailycritters.internalConfigId] or { counter = 1, schedule = {}}
	if not dailycritters.messages.counter then 
		dailycritters.messages.counter = 1
	end
end

function dailycritters.onCallbackQueryReceive(msg)
	if msg.message then
		local id, mode = msg.data:match(dailycritters.queryId..":(%d+),(%d+)")
		id = tonumber(id or "")
		mode = tonumber(mode or "")
		if id and mode then
			if dailycritters.messages[id] then 
				local dat = dailycritters.messages[id] 
				
				if type(dat.vote) ~= "table" then 
					print(dat.vote)
					dat.vote = {}
				end

					
					if not dailycritters.voteId[mode] then 

						deploy_answerCallbackQuery(msg.id, "fail bro")
						return
					end
					local obj = dailycritters.voteId[mode]


					if dat.vote[msg.from.id] then

						local votid = dailycritters.voteId[dat.vote[msg.from.id]].name
						print(dat[obj.name],obj.name, "last:"..votid)
						dailycritters.messages[id][votid] = (dat[votid] or 0) -1

					end
					dat.vote[msg.from.id] = mode

					dailycritters.messages[id][obj.name] = (dat[obj.name] or 0) +1

					deploy_answerCallbackQuery(msg.id, "Registered "..obj.name.." +1", true)
					if not dat.size then 
						dat.size = 2
					end
					local keyb = {}
					keyb[1] = {}
					for i=1, dat.size do
						local yOffset = 1 + math.floor((i-1)/dailycritters.keyboardWidth)
						if not keyb[yOffset] then 
							keyb[yOffset] = {}
						end
						local a = i - 1
						local off = (a%(dailycritters.keyboardWidth))
						keyb[yOffset][off+1 ] = { text = dailycritters.voteId[i][1].." "..(dat[dailycritters.voteId[i].name] or 0), callback_data = dailycritters.queryId..":"..id..","..i} 
					end

					local kb = JSON:encode({inline_keyboard = keyb })
					deploy_editMessageReplyMarkup(msg.message.chat.id, dat.message_id, msg.inline_message_id, kb)
					
					dailycritters.save()
					print(msg.from.first_name.." votes as "..obj.name.. " on "..(dat.caption or "?"))
			else 
				deploy_answerCallbackQuery(msg.id, "Unknown post")
			end
			return KILL_EXECUTION
		end

	end
	
end

function dailycritters.post(n)
	for where, i in pairs(dailycritters.messages.schedule) do 
		print(n, where, i)
		if n == where then
			if type(dailycritters.messages.schedule) ~= "table" then 
					dailycritters.messages.schedule = {}
			end
			if type(dailycritters.messages.schedule[where]) ~= "table" then 
				dailycritters.messages.schedule[where] = {}
			end
				
			if #dailycritters.messages.schedule[where] == 0 then 
				dailycritters.notifyOwner("<b>FAILED TO POST BECAUSE NO PHOTO IN QUEUE!</b> at "..dailycritters.channel[where])
				return false, "No more posts"
			else

				


				local n = math.random(1,#dailycritters.messages.schedule[where])
				local post = dailycritters.messages.schedule[where][n]
				table.remove(dailycritters.messages.schedule[where], n)


			 
				local keyb = {}
				keyb[1] = {}
				for i =1, dailycritters.votesize do
					local yOffset = 1 + math.floor((i-1)/dailycritters.keyboardWidth)
					if not keyb[yOffset] then 
						keyb[yOffset] = {}
					end
					local a = i - 1
					local off = (a%(dailycritters.keyboardWidth))
					keyb[yOffset][off+1] = { text = dailycritters.voteId[i][1].." 0", callback_data = dailycritters.queryId..":"..dailycritters.messages.counter..","..i}
				end
				local kb = JSON:encode({inline_keyboard = keyb })

				post[2] = post[2] .. "\n\n"..dailycritters.channel[post[3]].." ("..os.date("%d/%m")..")"

				local ret = bot.sendPhoto(dailycritters.channel[where],post[1], post[2], false, false, kb)	
				if ret.ok then 
					dailycritters.messages[dailycritters.messages.counter] = {message_id = ret.result.message_id, vote = {}, caption = post[2], size = dailycritters.votesize}
					dailycritters.messages.counter = dailycritters.messages.counter +1

					dailycritters.save()
					dailycritters.notifyOwner("Posted <b>"..post[2].."</b>!\n\nLeft <b>"..(#dailycritters.messages.schedule[where]).."</b> images in queue. at "..dailycritters.channel[where])

					if #dailycritters.messages.schedule == 0 then
						dailycritters.notifyOwner("<b>WARNING. No more images on queue!</b> at "..dailycritters.channel[where])
					end


					return true
				else 
					dailycritters.notifyOwner("<b>WARNING: "..Dump(ret).."!</b> at "..dailycritters.channel[where])
					return false, ret.reason
				end
			end
		end
	end
	dailycritters.notifyOwner("<b>Nothing scheduled at</b>  "..dailycritters.channel[n])
end


function dailycritters.notifyOwner(msg)
	for i,b in pairs(dailycritters.owners) do 
		local id = getUserByUsername(i)
		deploy_sendMessage(id.telegramid, msg, "HTML", true)
	end
end

function dailycritters.onHour(min, hour, day)
	if hour == 22 or hour == 10 then 
		dailycritters.post(1)
		dailycritters.post(2)
		dailycritters.save()
	end
end






function dailycritters.scheduler(msg, where) 

	if not msg.photo and (msg.photo[4] or msg.photo[3] or msg.photo[2] or msg.photo[1]) then 
		return false, 1
	end

	if not msg.caption then 
		return false, 2
	end

	local sch = {
		(msg.photo[4] or msg.photo[3] or msg.photo[2] or msg.photo[1]).file_id, msg.caption, where or 1
	}
	if type(dailycritters.messages.schedule) ~= "table" then 
		dailycritters.messages.schedule = {}
	end
	if type(dailycritters.messages.schedule[where]) ~= "table" then 
		dailycritters.messages.schedule[where] = {}
	end
	dailycritters.messages.schedule[where][#dailycritters.messages.schedule[where]+1] = sch


	dailycritters.notifyOwner("Scheduled <b>"..sch[2].."</b>!\n\nTotal of <b>"..(#dailycritters.messages.schedule[where]).."</b> images in queue of "..dailycritters.channel[where]..".")
	
	dailycritters.save()

	return true, dailycritters.schedule
end



--[ONCE] runs when eveything is ready
function dailycritters.ready()

end

--Runs at the begin of the frame
function dailycritters.frame()

end

function dailycritters.loadCommands()


	addCommand( "dailybear"	, MODE_UNLISTED, getModulePath().."/dailybear.lua", 0, "")
	addCommand( "dailyraccoon"	, MODE_UNLISTED, getModulePath().."/dailyraccoon.lua", 0, "")
	addCommand( "forcebear"	, MODE_UNLISTED, function(msg, text, attrs) --paws an pamps

	    	 dailycritters.post(1)
	end, 1)

	addCommand( "forceraccoon"	, MODE_UNLISTED, function(msg, text, attrs) --paws an pamps

	    	 dailycritters.post(2)  
	end, 1)


end

function dailycritters.loadTranslation()
	g_locale[LANG_US]["example-desc"] = "Displaya cake"
	g_locale[LANG_US]["example-desc"] = "Mostra um bolo"

end


return dailycritters