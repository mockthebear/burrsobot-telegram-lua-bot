local DEFAULT_PRIORITY = 0
if not DEFAULT_PRIORITY then 
	DEFAULT_PRIORITY = 0
end


local antispam = {
	priority = DEFAULT_PRIORITY - 10001200,
}


local utf8 = require("utf8")

local headRegexp = "([ \n^%w])"

local function printdbg(...)
	if antispam.DEBUG then 
		print(...)
	end
end


local emoji_pattern = "[\128-\255][\128-\255][\128-\255][\128-\255]?"  -- Basic UTF-8 emoji pattern

local function count_emojis(message)
    local emoji_count = 0
    for emoji in string.gmatch(message, emoji_pattern) do
        emoji_count = emoji_count + 1
    end
    return emoji_count
end

local function emoji_percentage(message)
    local total_chars = #message
    if total_chars == 0 then return 0 end
    
    local emoji_count = count_emojis(message)
    return (emoji_count / total_chars) 
end

function is_valid_url(url)
    -- Pattern to match URLs with or without protocol
    local pattern = "^((https?://)?[%w-_%.]+%.[%w-_%.]+[%w-_%./?%%&=]*)$"
    
    -- Check if the string matches the URL pattern
    if url:match(pattern) then
        return true
    else
        return false
    end
end

local function contains_link(s)
    -- Pattern to match URLs with http/https
    local pattern1 = "https?://[%w-_%.%?%.:/%+=&]+"
    -- Pattern to match URLs without http/https (e.g., example.com)
    local pattern2 = "[%w-_]+%.[%a]+[%w-_%.%?%.:/%+=&]*"
    
    if string.find(s, pattern1) then
        return true
    else
    	local from,to = string.find(s, pattern2)
    	if from then   
    		local url = s:sub(from, to)
    		return is_valid_url(url)
    	end
        return false
    end
end


function antispam.hasPriceMention(strLower)
    local conditions = {
        "([%d,%.]+)[%$€]",
        "([%d,%.]+).?[%$€]",
        "[%$€]([%d,%.]+)",
        "[%$€]%s*([%d,%.]+)",
        "([%d,%.]+)[%$€]",
        "([%d,%.]+)%s*brl",
        "([%d,%.]+)%s*r",

        "[%$€]([%d,%.]+)",
        "brl%s*([%d,%.]+)",
        "r%$%s*([%d,%.]+)",
        "r%s*([%d,%.]+)",


        "usd%s*([%d,%.]+)",
        "euro?%s*([%d,%.]+)",
        "([%d,%.]+)%s*usd",
        "([%d,%.]+)%s*euro?",
        "%-%s([%d,%.]+)",
        "$:%s*([%d,%.]+)",
    
    }

    for a,c in pairs(conditions) do 
        if strLower:match(c) and strLower:match("%d") then 
            return true, c
        end
    end
    
    return false
end



function antispam.classifyMessageDanger(msg) 

	local original_str = (msg.text or msg.description or msg.caption) or ""

	local emojiPercent = antispam.getCustomEmojiPercentage(msg) 

	
	local str = antispam.remove_accents(original_str)

	local strLower = str:lower()

	local hasBotMention = antispam.hasBotMention(strLower)
	local hasCrypto, info = antispam.hasCryptoMention(str, strLower, emojiPercent, original_str)
	local hasIllegal = antispam.hasIllegalStuff(strLower)
	local hasScam, infos = antispam.hasActualScam(strLower, original_str, emojiPercent)

	local result = "Emoji percent: "..(emojiPercent*100).."\n"..
					"MentionBot: "..hasBotMention.."\n".. 
					"hasCrypto: "..hasCrypto..(info and (" "..info) or "").."\n".. 
					"hasIllegal: "..hasIllegal.."\n" ..
					"hasScam: "..hasScam..(infos and (" "..infos) or "").."\n"
	if hasCrypto == 1 then 
		return true, "Cripto shit", result
	end

	if hasIllegal == 1 then 
		return true, "Drug selling", result
	end

	if hasScam == 1 then 
		return true, "Money scam", result
	end

	return false, "safe", result
end

function antispam.checkInnerElement(elem, strLower, original_str)
	local info = ""
	if type(elem) == 'string' then 
		if not strLower:find(elem) then
			return 0
		end
		info = info .. "Matched "..elem
	elseif type(elem) == 'table' then 
		for _, orElem in pairs(elem) do  
			if type(orElem) == 'string' then 
				if strLower:find(orElem) then 
					return 1, orElem
				end
			else 
				local useStr = strLower
				if orElem == contains_link  or orElem == antispam.hasPriceMention  then  
					useStr = original_str
				end
				local res = orElem(useStr)
				if res == 1 or res == true then  
					return 1, orElem
				end
			end
		end
		return 0
	else 
		local useStr = strLower
		if elem == contains_link or elem == antispam.hasPriceMention then  
			useStr = original_str
		end
		local res = elem(useStr)
		if res ~= 1 and res ~= true then   
			return 0
		end
	end
	return 1, elem
end


local cryptoCollection = { 
		{"[^%w]airdrop", "[^%w]crypto"},
		{"airdrop", contains_link},
		{{"[^%w]bitcoin", "[^%w]btc"}, "cashout"},
		{"[^%w]nft", "[^%w]reward", antispam.hasPriceMention},
		{{"[^%w]bitcoin", "[^%w]btc"}, "[^%w]usdt", contains_link},

	}


local scamCollection = { 
		{"[^%w]girl", "[^%w]fuck", "[^%w]click", {antispam.contains_link}},
		{"[^%w]profit[^%w]", "[^%w]contact[^%w]", antispam.hasPriceMention},
		{"[^%w]earning[^%w]", "[^%w]effortless", antispam.hasPriceMention},
		{"[^%w]invest[^%w]", "[^%w]earn[^%w]", antispam.hasPriceMention},
		{"[^%w]invest[^%w]", "[^%w]profit[^%w]", antispam.hasPriceMention},
		{"[^%w]retorno[^%w]", "[^%w]dinheiro[^%w]", antispam.hasPriceMention},
		{"[^%w]retorno[^%w]", "[^%w]verificado[^%w]", "[^%w]investidor", antispam.hasPriceMention},
		{"[^%w]day trade[^%w]", "[^%w]transfiro[^%w]", antispam.hasPriceMention},
		{"[^%w]honest", "[^%w]invest", {antispam.hasPriceMention, contains_link}},
		{"[^%w]honest", "[^%w]invest", {antispam.hasPriceMention, contains_link}},
		{"[^%w]social media", {"[^%w]crypto", "[^%w]paypal"}, {antispam.hasPriceMention}},
		{"[^%w]instagram", {"[^%w]verified", "[^%w]follower"}, "instant", {antispam.hasPriceMention}},
		{"[^%w]fuck", "[^%w]hot", {"[^%w]join", "[^%w]link"}, {antispam.contains_link}},
		{"[^%w]crypto", "[^%w]transaction", {"[^%w]free", "[^%w]buy"}, {antispam.contains_link}},
		{"[^%w]dinheiro", "[^%w]plataforma", {"[^%w]ganhe", "[^%w]ganhei"}, {antispam.contains_link}},
		{"[^%w]seguidor", "[^%w]instagram", {"venda", "venta"}, {antispam.hasPriceMention}},
	}

function antispam.checkCollection(setList, strLower, original_str, emojiPercent)
	strLower = " "..strLower.." "

	for a, set in pairs(setList) do 
		local ok = 1
		local info = "Matched collection "..a..": ["
		for _, elem in pairs(set) do  
			
			ok , match = antispam.checkInnerElement(elem, strLower, original_str)
			info = info..tostring(match)..','
			if ok == 0 then  
				break
			end
		end
		if ok == 1 then
			return 1, info..']'
		end
	end

	if emojiPercent > 0.65 and contains_link(original_str) and original_str:find("🫰") then 
		return 1, "Emoji percent, found emoji and has link"
	end
	return 0, ""
end

function antispam.hasActualScam(strLower, original_str, emojiPercent)
	local phone = antispam.hasPhoneNumber(strLower)
	local money = antispam.hasPriceMention(strLower)
	local scamMentions = {
		"apple pay",
		"cash app",
		"bank",
		"crypto",
		"transfer",
		"cloned card",
		"cartao clonado",
		"social media",
		"pix",
		"paypal",
		"whatsapp",
		"gift card",
		"gift cards",
		"seguidores",
		"seguidor",
		"trading",
		"invest",
		"investidora",
	}

	strLower = " "..strLower.." "
	local reason = ""
	local scamCount = 0
	for a, kw in pairs(scamMentions) do  
		if strLower:find("[^%w]"..kw.."[^%w]") then  
			reason = reason .. "Found '"..kw.."' "
			scamCount = scamCount +1
		end
	end

	if scamCount <= 3 then  
		return antispam.checkCollection(scamCollection, strLower, original_str, emojiPercent)
	end
	if money and phone then  
		return 1, reason
	else 
		if scamCount >= 6 then  
			return 1, reason
		end
		return antispam.checkCollection(scamCollection,strLower, original_str, emojiPercent)
	end
end
function antispam.hasIllegalStuff(strLower)
	local drugStuff = {
		"lsd",
		"heroine",
		"cannabis",
		"meth",
		"medelin",
		"cocaine",
		"cocaina",
		"cogumelo",
		"mushroom",
		"thc",
		"mdma",
		"xanax",
		"oxycodone",
		"ketamine",
		"cdb",
	}
	strLower = " "..strLower.." "
	local drugCount = 0
	for a, kw in pairs(drugStuff) do  
		if strLower:find("[^%w]"..kw.."[^%w]") then  
			drugCount = drugCount +1
		end
	end

	if drugCount <= 2 then  
		return 0
	end
	local hasPriceMention = antispam.hasPriceMention(strLower)
	if hasPriceMention then  
		return 1
	end

	return drugCount >= 4 and 1 or 0
end

function antispam.fancyReplacer(txt)
	txt = txt:gsub("𝐑", "r")
	txt = txt:gsub("𝐄", "e")
	txt = txt:gsub("𝐀", "a")
	txt = txt:gsub("𝐈", "i")
	txt = txt:gsub("𝐒", "s")
	txt = txt:gsub("𝐓", "t")
	txt = txt:gsub("𝐍", "n")
	txt = txt:gsub("𝐅", "f")
	txt = txt:gsub("𝐎", "o")
	txt = txt:gsub("𝑴", "m")
	txt = txt:gsub("𝑵", "n")
	txt = txt:gsub("𝑼", "u")
	txt = txt:gsub("𝑪", "c")
	return txt

end
local accent_map = {
        ['áàãâä'] = 'a', ['ÁÀÃÂÄ'] = 'A',
        ['éèêë'] = 'e', ['ÉÈÊË'] = 'E',
        ['íìîï'] = 'i', ['ÍÌÎÏ'] = 'I',
        ['óòõôö'] = 'o', ['ÓÒÕÔÖ'] = 'O',
        ['úùûü'] = 'u', ['ÚÙÛÜ'] = 'U',
        ['ç'] = 'c', ['Ç'] = 'C',
        ['ñ'] = 'n', ['Ñ'] = 'N',
        [".,;/\\|?!~*"] = " ",


	    ["Т"] = "T",
	    ["Е"] = "E",
	    ["е"] = "e", 
	    ["р"] = "r", 
	    ["а"] = "a", 
	    ["о"] = "o", 
	    ["в"] = "v", 
	    ["А"] = "a",  



}

function antispam.remove_accents(str)
    local normalized_str = ""
    for p, c in utf8.chars(str) do
        local char = c
        for accents, replacement in pairs(accent_map) do
            if accents:find(char, 1, true) then
                char = replacement
                break
            end
        end
        normalized_str = normalized_str .. char
    end
    normalized_str = antispam.fancyReplacer(normalized_str)

    local a = normalized_str:gsub("[\1-\8\11\12\14-\31\127-\255]", "") 

    return a
end



function antispam.hasCryptoMention(str, strLower, emojiPercent, original_str)
	local cryptoKeywords = {
		"airdrop",
		"btc",
		"ton",
		"usdt"
	}
	
	strLower = " "..strLower.." "
	str = " "..str.." "
	local hasMentionOf = ""
	local hasAnuncio = false
	for a, kw in pairs(cryptoKeywords) do  
		local e,b = strLower:find(headRegexp..kw..headRegexp)
		
		if e then  
			hasAnuncio = true
			hasMentionOf = "Has mention of '"..kw.."'"
			break
		end
	end
	if not hasAnuncio then  

		if emojiPercent > 0.65 and antispam.hasBotMention(strLower) == 1 and strLower:match("ton") then  
			return 1, hasMentionOf.." and has emoji or bot mention"
		end
		return antispam.checkCollection(cryptoCollection, strLower, original_str, emojiPercent)
	end

	if str:match("[^%w]%$([A-Z]+)[^%w]") then 
		return 1, hasMentionOf.." and mentions directly an crypto currency"
	end


	if emojiPercent > 0.7 and antispam.hasBotMention(strLower) == 1 and strLower:match("ton") then  
		return 1, hasMentionOf.." and has emoji or bot mention"
	end

	return antispam.checkCollection(cryptoCollection, strLower, original_str, emojiPercent)
end

function antispam.hasPhoneNumber(str)
	if str:match("%+%d+") then 
		return 1
	end
	return 0
end

function antispam.hasBotMention(str)
	if str:match("@([a-zA-Z0-9_]+)bot") or str:match("t%.me/([a-zA-Z0-9_]+)bot") then 
		return 1
	end
	return 0
end

function antispam.classifyText(str)

end


function antispam.getCustomEmojiPercentage(msg)
	if not msg.entities then  
		return 0
	end
	local str = (msg.text or msg.description) or ""
	if str == "" then 
		return 0
	end
	str = antispam.remove_accents(str)
	str = str:gsub("%s"," ")
	local emojiLen = 0
	for a, entity in pairs(msg.entities or msg.caption_entities or msg.description_entities) do 
		if entity.type == 'custom_emoji' then  
			if not entity.length then  
				entity.length = entity.text:len()
			end
			emojiLen = emojiLen + entity.length
		end
	end
	return emojiLen/(str:len()+emojiLen)
end

function antispam.onNewChatParticipant(msg)
end

function antispam.onTextReceive(msg)
	if msg.from then
		local isSpam, class, breakdown = antispam.classifyMessageDanger(msg)
		if isSpam then
			print("Encontrado spam do tipo "..class.."\n"..breakdown)
			local str = (msg.text or msg.description or msg.caption)
			print(str)
			local chatid = msg.chat and msg.chat.id or msg.from.id
			bot.sendMessage(5146565303, "Encontrado spam do tipo "..class.."\n"..breakdown..'\nNo chat: '..chatid)
			local res = bot.forwardMessage(5146565303, msg.from.id, false, msg.message_id)
			if not res.ok then  
				bot.sendMessage(5146565303, "Spam found: \n"..str)
			end
		end
	end
end

function antispam.onPhotoReceive(msg)
	if msg.from then
		local isSpam, class, breakdown = antispam.classifyMessageDanger(msg)
		if isSpam then
			print("Encontrado spam do tipo "..class.."\n"..breakdown)
			local str = (msg.text or msg.description or msg.caption)
			print(str)
			local chatid = msg.chat and msg.chat.id or msg.from.id
			bot.sendMessage(5146565303, "Encontrado spam do tipo "..class.."\n"..breakdown..'\nNo chat: '..chatid )
			local res = bot.forwardMessage(5146565303, msg.from.id, false, msg.message_id)
			if not res.ok then  
				bot.sendMessage(5146565303, "Spam found: \n"..str)
			end
		end
	end
end

function antispam.onDocumentReceive(msg)
	if msg.from then
		local isSpam, class, breakdown = antispam.classifyMessageDanger(msg)
		if isSpam then
			print("Encontrado spam do tipo "..class.."\n"..breakdown)
			local str = (msg.text or msg.description or msg.caption)
			print(str)
			local chatid = msg.chat and msg.chat.id or msg.from.id
			bot.sendMessage(5146565303, "Encontrado spam do tipo "..class.."\n"..breakdown..'\nNo chat: '..chatid)
			local res = bot.forwardMessage(5146565303, msg.from.id, false, msg.message_id)
			if not res.ok then  
				bot.sendMessage(5146565303, "Spam found: \n"..str)
			end
		end
	end
end

function antispam.loadCommands()
end




function antispam.loadTranslation()
end


function antispam.load()
end 

function antispam.save()
end

function antispam.ready()
end

function antispam.frame()

end

return antispam