function OnCommand(user, msg, args)
	local str = "📈*Bot statistics*📉\n\n"
	local ccount = 0
	for i,b in pairs(chats) do 
		ccount = ccount +1
	end
	str = str .. "🗒 This bot is active in *"..ccount.."* chats.\n"

	local mem = collectgarbage("count")*1024
    local bytes = math.floor(mem/10000)

	str = str .. "💾 Its memmory usage are *"..bytes.."* MB\n"

	local dt = (os.time()-g_startup)
	local h = math.floor(dt/3600)
	dt = dt % 3600
	local sec = dt%60
	local min = math.floor(dt/60)	
	str = str .. "⏱ Also the bot is up for *"..string.format("%2.2d:%2.2d:%2.2d",h,min,sec).."*\n"

	local max7 = {}
	for name, count in pairs(configs["stats"]) do 
		max7[name] = count
	end
	ccount = 0
	for i,b in pairs(users) do 
		ccount = ccount +1
	end
	str = str .. "👤 Loaded *"..ccount.."* users.\n"


	str = str .. "⏱ Avg request time *"..string.format("%2.2f",bot.getRequestDuration()).."* seconds.\n"

	local upm = bot.getUpdatesCount()
	local mins = math.floor(math.max(1,(os.time()-g_startup)/60))

	str = str .. "🗳 Around *"..string.format("%d", upm/mins ).."* updates per minute.\n"
	str = str .. "⏳ Update time *"..string.format("%2.2f", bot.final[1] ).."* for burrbot.\n"
	str = str .. "⌨️ Update frames *"..bot.g_updates.."* \n"

	str = str .. "🖥 7 most used commands:\n"
	for i=1,7 do 
		local maxC = ""
		local maxN = 0
		for name, count in pairs(max7) do 
			if name ~= "cjoin" and maxN < count and not name:find("rpg") and name ~= "battle" then 
				maxN = count
				maxC = name
			end
		end
		if max7[maxC] then 
			str = str .."-> */".. maxC.."* with *"..maxN.."* uses\n"
			max7[maxC] = nil
		end
	end

	if not user.chat.id or not chats[user.chat.id] then 
        say_markdown(str)
        return 
    else 
    	local cdata 
    	while not cdata do 
			cdata = bot.getChat(user.chat.id)
		end
		local cdata = cdata.result

	

    	str = "📈*Chat statistics*📉\n\n"..
    	"🔢 Chat id *"..cdata.id.."*\n"..
    	"📑 Chat type *"..cdata.type.."*\n"..
    	"🚦 Bot protecion is *"..(chats[user.chat.id].botProtection and "enabled" or "disabled").."*\n"..

    	"\n"..str

        say_markdown(str)
    end
	
end
