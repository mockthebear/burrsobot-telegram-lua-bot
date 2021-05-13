local shell = shell or require "resty.shell"

function OnCommand(msg, text, args)
	msg.text = msg.text:gsub("/"..args[1],"",1)

	local lang = g_lang == LANG_BR and "pt-br" or "en"
	if msg.text:match("lang=([a-zA-Z0-9%-]*)%s?") then 
		local auxlang = msg.text:match("lang=([a-zA-Z0-9%-]*)%s?")
		msg.text = msg.text:gsub("lang="..auxlang:gsub("%-","%%%-").." ","",1)
	
		local valid = {'af', 'ar', 'bn', 'bs', 'ca', 'cs', 'cy', 'da', 'de', 'el', 'en', 'en-au', 'en-ca', 'en-gb', 'en-gh', 'en-ie', 'en-in', 'en-ng', 'en-nz', 'en-ph', 'en-tz', 'en-uk', 'en-us', 'en-za', 'eo', 'es', 'es-es', 'es-us', 'et', 'fi', 'fr', 'fr-ca', 'fr-fr', 'hi', 'hr', 'hu', 'hy', 'id', 'is', 'it', 'ja', 'jw', 'km', 'ko', 'la', 'lv', 'mk', 'ml', 'mr', 'my', 'ne', 'nl', 'no', 'pl', 'pt', 'pt-br', 'pt-pt', 'ro', 'ru', 'si', 'sk', 'sq', 'sr', 'su', 'sv', 'sw', 'ta', 'te', 'th', 'tl', 'tr', 'uk', 'vi', 'zh-cn', 'zh-tw'}
		local list = ""
		for i,b in pairs(valid) do 
			list = list .. b .. ", " 
			if auxlang == b then
				lang = auxlang
			end 
		end
		if lang ~= auxlang then 
			list = list:sub(1, #list -2)
			reply.html(tr("useless-tts-lang", list))
			return
		end

	end

	if msg.reply_to_message and msg.reply_to_message.text then 
		msg.text = msg.reply_to_message.text
	end
	
	
	if msg.text:len() > 1 then 
	
		lang = lang:lower()
		if msg.text:len() > 400 then 
			say("too big bro. slow down ur bitch...")
			return 
		end
		msg.text = msg.text:gsub("\"", "\\\"")

		bot.sendChatAction(g_chatid, "record_audio")
		os.execute("rm ../media/tts.mp3")
		print("google_speech -l "..lang.." -o ../media/tts.mp3 \""..msg.text.."\"")
		local ok, stdout, stderr, reason, status = shell.run("google_speech -l "..lang.." -o ../media/tts.mp3 \""..msg.text.."\"", nil, 5000, 4096)
		print(stdout)
		print(stderr)
		if ok then 
			bot.sendAudio(g_chatid, "../media/tts.mp3")
		else 
			say("Error processing request.")
		end
	end
end