local module = {
	priority = DEFAULT_PRIORITY,
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


module.bottomEmojis = {
	["👉"] = 1,
	["🥺"] = 5,
	["👈"] = 1,
	["💖"] = 2,		
	["✨"] = 2,
	["🍆"] = 2,
	["🍑"] = 2,
	["🌝"] = -2,
	["😎"] = -2,
	["😉"] = 2,
	["😚"] = 2,
	["😙"] = 2,
	["😍"] = 2,
	["🥰"] = 2,
	["😘"] = 2,
	["😌"] = 2,
	["🙃"] = -2,
	["🙃"] = -2,
	["🥹"] = 2,
	["😤"] = 2,
	["🌚"] = -2,
	["🔪"] = -2,
	["🗡"] = -2,
	["🔫"] = -2,
	["👌"] = -2,

}

module.bottomWords = {
	["👉👈"] = 10,
	["uwu"] = 5,
	[":3"] = 4,
	["rs"] = 3,
	[":p"] = 3,
	["bottom"] = 2,
	["naum"] = 3,
	["aie"] = 3,
	["falah"] = 3,
	["axim"] = 3,
	[">w<"] = 6,
	[">~>"] = 6,
	[":3c"] = 3,
	["kurwa"] = -5,
	["daddy"] = 6,
	["ui"] = 3,
	["ewe"] = 2,
	["huggies"] = 5,
	["nheii"] = 5,
	["nhei"] = 5,
	["qwq"] = 2,
	["bumbum"] = 8,
	["bundinha"] = 8,
	["bundinhaa"] = 8,
	["bundinhaaa"] = 8,
	["~"] = 1,
	["top"] = 1,
	["<3"] = 4,
	["okie"] = 1,
	["dildo"] = 1,
	["weenie"] = 4,
	["plug"] = 1,
	["heck"] = 4,
	["comia"] = -4,
	['xd'] = -1,
	['lol'] = -1,
	['lmao'] = -1,
	['wow'] = -2,
	['sus'] = -5,
	['oof'] = -5,
	['yikes'] = -5,
	['ugh'] = -5,
	['omg'] = -5,
	['mood'] = -5,
	['rip'] = -5,
	["sussy"] = 5,
	["baka"] = 5,
}

--I also mention my weenie to talk about how small and in chastity it is
--I'm a bottom

module.bottomSentences = {
	["im a bottom"] = 50,
	["i'?m not%s?a?%s?bottom"] = 50,
	["i'm a bottom"] = 50,
	["i'm a top"] = 25,
	["im a top"] = 10,
	['fuck me'] = 20,
	['my penis'] = -8,
	['my dick'] = -8,
	['my butt'] = 8,
	['minha bunda'] = 8,
	['fuck you'] = -5,
	['cutie'] = -5,
	['awwww'] = 5,
	['uwuw[uw]*'] = 5,
	['you\'re cute'] = -5,
	['youre cute'] = -5,
	['you re cute'] = -5,
	['.ggies'] = 8,
	['anal beads'] = 7,
	['my ass'] = 7,
	['your ass'] = -7,
	['your dick'] = 7,
	['[ts]eu cu'] = -7,
	['meu cu'] = 7,
	['viadagem'] = -5,
	['%*giggles%*'] = 5,
	['made me cum'] = 20,
	['your* prostate'] = -5,
	['hufff*'] = -5,
	['my prostate'] = 5,
	['mine prostate'] = 5,
	['^ha[ha]*$'] = 5,
	['^same$'] = -3,
	['^hey$'] = -3,
	['^ok$'] = -3,
	['^haha no$'] = -3,
	['^nope$'] = -3,
	['^oh no$'] = -3,
	['^f$'] = -3,
	['^nice$'] = -3,
	['^bottom$'] = -3,
	['^mood af$'] = -3,
	['^woah$'] = -3,
	['^bruh$'] = -3,
	['^valid$'] = -3,
	['^idk$'] = -3,

}

function module.onTextReceive(msg)
	if msg.isChat then 
		local bottomScore = 0
		if not chats[msg.chat.id].data.bottom then 
			
			local txt = msg.text .." "
			txt = txt:gsub('\n', ' ')
			txt = txt:lower()
			for word in txt:gmatch("(.-)%s") do
				if module.isKeySmash(word) then 
					bottomScore = bottomScore + 10
				end
				for a,score in pairs(module.bottomEmojis) do 
					if word:find(a) then 
						bottomScore = bottomScore + score
					end
				end
				if module.bottomWords[word] then
					bottomScore = bottomScore + module.bottomWords[word]
				end
			end

			for wrd, score in pairs(module.bottomSentences) do 
				if txt:find(wrd) then 
					bottomScore = bottomScore + score
				end
			end
		end
		if bottomScore ~= 0 and users[msg.from.id] then
			print("[BOTTOM] score "..bottomScore.." for: "..msg.text:htmlFix().."")
			users[msg.from.id].bottom_score = (users[msg.from.id].bottom_score or 0) + bottomScore
			SaveUser(msg.from.id)
		end
	end
end

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

function module.loadCommands()
	addCommand( {"bottom"}		, MODE_FREE,  getModulePath().."/bottom_cmd.lua", 2 , "bottom-desc" )
	addCommand( {"top"}		, MODE_FREE,  getModulePath().."/top_cmd.lua", 2 , "bottom-top-desc" )
end

function module.loadTranslation()
	g_locale[LANG_US]["bottom-top"] = "These are the bottoms of the chat and their score:\n"
	g_locale[LANG_BR]["bottom-top"] = "Esses são os bottoms do chat e seu score:\n"

	g_locale[LANG_US]["bottom-top-top"] = "These are the tops of the chat and their score:\n"
	g_locale[LANG_BR]["bottom-top-top"] = "Esses são os tops do chat e seu score:\n"

	g_locale[LANG_US]["bottom-desc"] = "Display ranking of bottoms"
	g_locale[LANG_BR]["bottom-desc"] = "Mostra o ranking de bottoms"

	g_locale[LANG_US]["bottom-top-desc"] = "Display ranking of tops"
	g_locale[LANG_BR]["bottom-top-desc"] = "Mostra o ranking de tops"
end


return module