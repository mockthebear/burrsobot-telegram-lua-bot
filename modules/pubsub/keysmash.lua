local module = {
	priority = DEFAULT_PRIORITY,
	cooldown = {}
}


local function count_segments(text)
	local laughtLenght = 0
	local lastIsVowel = false
	local repetitionMap = {}
	local keysSmashScore = 0
	local segmentVowels = 0

	local common = "[asdfghjklç0-9]"
	local uncommon = "[zxcqwem,%.uio]"
	local vogals = '[aeiou]'
	local laught = "[ahus]" --Ppl lught wih: shusauhashuhsuauhashusa

	for i=1, #text do 
		local let = text:sub(i,i)
		if not repetitionMap[let] then 
			repetitionMap[let] = 0
		end
		repetitionMap[let] = repetitionMap[let] +1
		if let:match(common) then 
			keysSmashScore = keysSmashScore +1
		end

		if let:match(laught) then 
			laughtLenght = laughtLenght + 1
		end

		if let:match(uncommon) then 
			keysSmashScore = keysSmashScore +0.3
		end
		if let:match(vogals) then 

			segmentVowels = segmentVowels -1
			if (lastIsVogal) then 
				segmentVowels = segmentVowels -1
			end
			lastIsVogal = true
		else 
			segmentVowels = segmentVowels +1
			if (lastIsVogal) then 
				segmentVowels = segmentVowels -1
			end
			lastIsVogal = false
		end
		
	end

	return laughtLenght, repetitionMap, segmentVowels, keysSmashScore
end

function module.isKeySmash(text, minimumKeysmashCharacters, repetitionTreshHold)
	text = text:lower()
	
	minimumKeysmashCharacters = minimumKeysmashCharacters or 8
	repetitionTreshHold = repetitionTreshHold or 0.7

	if text:match("[%[%]%(%)%%0-9;!%?@\\|/]") then 
		return false, 0, "contains accentuation"
	end

	if text:match("http.+")  then
		return false, score, "it seems to be a http link"
	end

	if text:find("çã") or text:find("çõ") then 
		
		return false, 0, "found çã and çõ;"
	end

	local laughtLenght, repetitionMap, segmentVowels, keysSmashScore = count_segments(text)
	local treshhold = #text*(1 - 0.15)
	local range = math.max((#text-math.max(1, treshhold)), minimumKeysmashCharacters)

	if laughtLenght >= treshhold then 
		return false, keysSmashScore, "it seems to  be just a laught"
	end

	if not (keysSmashScore > minimumKeysmashCharacters and keysSmashScore >= (#text-math.max(1, treshhold))) then
		return false, keysSmashScore, "not enoght score (<"..range..");"
	end

	if segmentVowels <= 0 then
		return false, keysSmashScore, "too many vowels (vowel score: "..segmentVowels..");"
	end

	local limit = repetitionTreshHold * #text
	for letter, repetitions in pairs(repetitionMap) do 
		if repetitions >= limit then 
			return false, keysSmashScore, "letter "..letter.." repeat more than "..tostring(repetitionTreshHold * 100).."%);"
		end
	end

	return true, "ok", keysSmashScore
end

function module.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "enable_keyshmash", {type="boolean"}, true, "Bother bottoms with keysmash", "Nsfw")
	end
end



function module.onTextReceive(msg)
	if msg.isChat then 
		if chats[msg.chat.id].data.enable_keyshmash then 
			local txt = msg.text .." "
			txt = txt:gsub('\n', ' ')
			for word in txt:gmatch("(.-)%s") do
				if module.isKeySmash(word) then 
					if not module.cooldown[msg.chat.id] or module.cooldown[msg.chat.id] <= os.time() then
						--module.cooldown[msg.chat.id] = os.time() + 60
						if math.random(0, 100) <= 30 then
							bot.sendSticker(msg.chat.id, "CAACAgEAAx0CTJmDiwACJSZfNYoBzJoz_yLy2p3hDskjx_sxsAACGgADkGVrM5x-IZx71rIEGgQ", false, msg.message_id)
		       				return
		       			end
		       		end
				end
			end
		end
	end
end

--Runs at the begin of the frame
function module.frame()

end

--Runs some times
function module.save()

end

--Runs some times
function module.save()

end

function module.loadCommands()  
	addCommand( {"keysmash_bottom"}		, MODE_CHATADMS,  defaultToggleChatCommand("enable_keyshmash", "keysmash-toggle-cmd"), 2 , "keysmash-toggle" )
	addCommand( {"keysmash"}			, MODE_FREE,  getModulePath().."/inspect.lua", 2 , "keysmash-inspect" )
end

function module.loadTranslation()
	g_locale[LANG_US]["keysmash-toggle"] = "Bother keysmashers! It works when it detects keysmashes and send a sticker to it. Only 30% of times."
	g_locale[LANG_BR]["keysmash-toggle"] = "Encomoda keysmashers! Detecta keysmashes e responde com um sticker. Funciona somente 30% das vezes."

	g_locale[LANG_US]["keysmash-inspect"] = "Reply to a message to measure the keysmash score."
	g_locale[LANG_BR]["keysmash-inspect"] = "Responda a uma mensagem para medir o score de keysmash"

	g_locale[LANG_US]["keysmash-toggle-cmd"] = "Keysmash bother is"
	g_locale[LANG_BR]["keysmash-toggle-cmd"] = "Encomodar keysmash está "
end


return module