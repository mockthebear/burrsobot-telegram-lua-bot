diaperfur = {
	channel = {
		diaperfur = "@diaperfurries", --
		messy = "@messydiaper",
	},


	internalConfigId = "dpr",

	queryId = "dpr",

	owners = {
		["mockthebear"] = 1,		
		["sosowhoof"] = 1,		
		["bearusu_myo"] = 1,		
		["murdock_wolfgang"] = 1,		
	},


	voteId = {
		[1] = {"❤️", name = "love"},
		[2] = {"👍", name = "like"},
		[3] = {"👎", name = "not liked"},
		--[3] = {"👀", name = "seen"},
		[4] = {"🍆", name = "eggplant"},
		[5] = {"🍆", name = "seena"},
		[6] = {"🍆", name = "hard"},
		[7] = {"🍆", name = "gay"},
		
	},

	votesize = 3 ,

	keyboardWidth = 4,

}

local JSON = require("JSON")

function diaperfur.save()
	configs[diaperfur.internalConfigId] = diaperfur.messages
	saveConfig(diaperfur.internalConfigId)
end


function diaperfur.load()
	diaperfur.messages = configs[diaperfur.internalConfigId] or { counter = 1, }
	addDirectQuery(diaperfur.query, diaperfur.queryId)
	if not diaperfur.messages.counter then 
			diaperfur.messages.counter = 1
	end
end


function diaperfur.query(data, msg)
	local id, mode = data:match("(%d+),(%d+)")
	id = tonumber(id or "")
	mode = tonumber(mode or "")
	if id and mode then
		if diaperfur.messages[id] then 
			local dat = diaperfur.messages[id] 
			
				if type(dat.vote) ~= "table" then 
					print(dat.vote)
					dat.vote = {}
				end

				
				if not diaperfur.voteId[mode] then 

					deploy_answerCallbackQuery(msg.id, "fail bro")
					return
				end
				local obj = diaperfur.voteId[mode]


				if dat.vote[msg.from.id] then
					print()
					local votid = diaperfur.voteId[dat.vote[msg.from.id]].name
					print(dat[obj.name],obj.name, "last:"..votid)
					diaperfur.messages[id][votid] = (dat[votid] or 0) -1

				end
				dat.vote[msg.from.id] = mode

				diaperfur.messages[id][obj.name] = (dat[obj.name] or 0) +1

				deploy_answerCallbackQuery(msg.id, "Registered "..obj.name.." +1")
				if not dat.size then 
					dat.size = 2
				end
				local keyb = {}
				keyb[1] = {}
				for i=1, dat.size do
					local yOffset = 1 + math.floor((i-1)/diaperfur.keyboardWidth)
					if not keyb[yOffset] then 
						keyb[yOffset] = {}
					end
					local a = i - 1
					local off = (a%(diaperfur.keyboardWidth))
					keyb[yOffset][off+1 ] = { text = diaperfur.voteId[i][1].." "..(dat[diaperfur.voteId[i].name] or 0), callback_data = diaperfur.queryId..":"..id..","..i} 
				end

				--keyb[1][1] = { text = "ð "..dat.yes, callback_data = diaperfur.queryId..":"..id..",1"} 
				--keyb[1][2] = { text = "ð "..dat.no, callback_data = diaperfur.queryId..":"..id..",2"} 
				local kb = JSON:encode({inline_keyboard = keyb })
				deploy_editMessageReplyMarkup(msg.message.chat.id, dat.message_id, msg.inline_message_id, kb)
				
				diaperfur.save()
				print(msg.from.username.." votes as "..obj.name.. " on "..(dat.caption or "?"))
			
		end
		
	end
	return true
end


function diaperfur.post(msg, where)
	if not msg.photo and (msg.photo[4] or msg.photo[3] or msg.photo[2] or msg.photo[1]) then 
		return false, 1
	end
	if not msg.caption then 
		return false, 2
	end


	local keyb = {}
	keyb[1] = {}
	for i =1, diaperfur.votesize do
		local yOffset = 1 + math.floor((i-1)/diaperfur.keyboardWidth)
		if not keyb[yOffset] then 
			keyb[yOffset] = {}
		end
		local a = i - 1
		local off = (a%(diaperfur.keyboardWidth))
		keyb[yOffset][off+1] = { text = diaperfur.voteId[i][1].." 0", callback_data = diaperfur.queryId..":"..diaperfur.messages.counter..","..i}
	end
	local kb = JSON:encode({inline_keyboard = keyb })

	local ret = bot.sendPhoto(diaperfur.channel[where], (msg.photo[4] or msg.photo[3] or msg.photo[2] or msg.photo[1]).file_id, msg.caption, false, false, kb)	
	if ret.ok then 
		diaperfur.messages[diaperfur.messages.counter] = {message_id = ret.result.message_id, vote = {}, caption = msg.caption, size = diaperfur.votesize}
		diaperfur.messages.counter = diaperfur.messages.counter +1

		diaperfur.save()
		if where == "diaperfur" then 
			bot.forwardMessage(-1001186625744, diaperfur.channel[where], false, ret.result.message_id)
		end
		return true
	else 
		say(DumpTableToStr(ret))
	end
	return false 
end
