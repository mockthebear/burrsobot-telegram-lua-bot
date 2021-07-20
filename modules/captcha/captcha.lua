local captcha = {
	sequences = {},
	require={
		os = {
			"convert"
		}
	}
}

captcha.priority = DEFAULT_PRIORITY - 10000

--captcha.chatOnly = true

--[ONCE] runs when the load is finished
function captcha.load()
	captcha.hasTTS = hasOsModule("google_speech")
	--[[convert -version
	Version: ImageMagick 6.9.7-4 Q16 x86_64 20170114 http://www.imagemagick.org
	Copyright: © 1999-2017 ImageMagick Studio LLC
	License: http://www.imagemagick.org/script/license.php
	Features: Cipher DPC Modules OpenMP
	Delegates (built-in): bzlib djvu fftw fontconfig freetype jbig jng jpeg lcms lqr ltdl lzma openexr pangocairo png tiff wmf x xml zlib
	]]
end

--[ONCE] runs when eveything is ready
function captcha.ready()

end

--Runs at the begin of the frame
function captcha.frame()

end

--Runs some times
function captcha.save()

end

function captcha.loadCommands()
	addCommand( {"captcha"}		, MODE_ONLY_ADM, function(msg, text, attrs) --No chat pra tudo.
	    say("vam")
	    captcha.startCaptchaProcedure(msg.chat.id, msg.from.id, "pinto", function()
	    	reply("aeeeee")
	    end, function()
	    	reply("ah nao mano :/")
	    end, false, true)
	end)
end

function captcha.loadTranslation()
	g_locale[LANG_BR]["captcha-message-wrong"] = "Errado! Você pode tentar mais %d vezes.\nSe estiver dificil de ler, você pode gerar outro usando /recaptcha"
	g_locale[LANG_US]["captcha-message-wrong"] = "Wrong! You can try %d more times.\nIf you cannot guess, type /recaptcha"


	g_locale[LANG_BR]["captcha-message-norecaptcha"] = "Desculpe, você não pode usar de novo :/"
	g_locale[LANG_US]["captcha-message-norecaptcha"] = "Sorry, you can do it again :/"

	g_locale[LANG_BR]["captcha-tts"] = "A sequencia é: %s"
	g_locale[LANG_US]["captcha-tts"] = "The sequence is: %s"

	g_locale[LANG_BR]["captcha-can-tts"] = "\nSe você preferir, pode usar audio ao invéz de imagem usando /audio"
	g_locale[LANG_US]["captcha-can-tts"] = "\nIf you prefeer, you can use a audio message using /audio"
end

function captcha.onTextReceive(msg)

	local captchaId = users[msg.from.id].captcha
	if captchaId then
		local seq = captcha.sequences[captchaId]
		if seq and seq.chatid == msg.chat.id then 
			logText("captcha", os.date("%d/%m/%y %H:%M:%S",os.time()).." resp=\""..msg.text.."\" by="..msg.chat.id.." name=\""..msg.from.first_name.."\" username=\""..(msg.from.username or "-").."\" at=\"".. (msg.chat.type ~= "private" and (msg.chat.title)   or msg.chat.type).."\" chatid="..msg.chat.id.."\n")
			if msg.text:find("^/cancel") then
				seq.tries = 0
			end
			local seqParse = msg.text:gsub("o", 0)
			seqParse = seqParse:gsub("%s", "")
			if seqParse == seq.secret then 
				seq.success = true
				seq.onSucces(msg, seq)
				captcha.sequences[captchaId] = nil
				users[msg.from.id].captcha = nil
				users[msg.from.id].is_human_limit_counter = 3
				users[msg.from.id].human_counter_global = (users[msg.from.id].human_counter_global or 0) + 1
				users[msg.from.id].is_human_timer = os.time() + 3600

				if users[msg.from.id].human_counter_global >= 10 then 
					--users[msg.from.id].is_human_permanent = true
				end
				SaveUser(msg.from.id)
			elseif captcha.hasTTS and msg.text:find("^/audio") then
				if not seq.audio then 
					seq.audio = 1
					local lang = g_locale.langs[g_lang];
					local shell = shell or require "resty.shell"
					local secr = seq.secret:gsub("o", 0)
					secr = secr:gsub("O", 0)
					local newStr = ""
					for i=1,#secr do 
						newStr = newStr ..secr:sub(i,i)..", "
					end
					local ok, stdout, stderr, reason, status = shell.run("google_speech -l "..lang.." -o ../media/tts.mp3 \""..tr("captcha-tts", newStr).."\"", nil, 5000, 4096)
					if ok then 
						bot.sendAudio(seq.chatid, "../media/tts.mp3")
					end
				else 
					reply("error generating: "..tostring(stderr))
				end
			elseif msg.text:find("^/start") then
				reply("You are in a captcha now. Cancel or solve please.")
			elseif msg.text:find("^/recaptcha") then
				if not seq.renew then 
					local str, ok, photo = captcha.sendCaptcha(seq.chatid, nil)
					if ok then 
						deploy_deleteMessage(seq.chatid, seq.msgId)
						seq.msgId = photo.result.message_id
						seq.secret = str
						seq.renew = true
						seq.audio = nil
					end
				else 
					reply(tr("captcha-message-norecaptcha"))
				end
			else
				seq.tries = seq.tries - 1
				if seq.tries <= 0 then 
					seq.onFail(msg)
					captcha.sequences[captchaId] = nil
					users[msg.from.id].captcha = nil
					SaveUser(msg.from.id)
				else
					reply(tr("captcha-message-wrong", seq.tries))
				end
			end
			return KILL_EXECUTION
		else 
			users[msg.from.id].captcha = nil
			SaveUser(msg.from.id)
		end
	end
end

function captcha.startCaptchaProcedure(chat, userId, text, onSucces, onFail, ignoreHuman)
	if not onSucces or not onSucces then 
		error("Missing callbacks")
	end
	if users[userId] then 
		local shouldCaptchaIt = true
		if (users[userId].is_human_timer or 0) > os.time() then
        	users[userId].is_human_limit_counter = (users[userId].is_human_limit_counter or 1) - 1
        	if users[userId].is_human_limit_counter > 0 then 
        		shouldCaptchaIt = not ignoreHuman
        	end
       	end
       	if users[userId].is_human_permanent then
       		shouldCaptchaIt = not ignoreHuman
       	end

       	shouldCaptchaIt = true

       	if shouldCaptchaIt then

			local str, ok, photo = captcha.sendCaptcha(chat, text)
	        if ok then 
	           	--say.admin("User "..formatUserHtml(users[userId]).." reqeusted captcha: "..(chats[chatid] and tostring(chats[chatid].data.title) or "??").." = "..str.." at module: "..g_moduleNow, "HTML")
	           	local photoId = photo.result.message_id
	           	local captchaId = os.time()
	           	captcha.sequences[captchaId] = {
	           		secret = str,
	           		captchaId=captchaId,
	           		msgId = photo,
	           		target = userId,
	           		chatid = chat,
	           		tries = 4,
	           		renew=false,
	           		success=false,
	           		onSucces = onSucces,
	           		onFail = onFail,
	           	}
	           	users[userId].captcha = captchaId
	           	return true, "check", captchaId
	        else 
	        	say.admin("User "..formatUserHtml(users[userId]).." has a failed captcha oh no", "HTML")
	           	return false
	        end
	    else 
	    	say.admin("User "..formatUserHtml(users[userId]).." released from captcha at : "..(chats[chatid] and tostring(chats[chatid].data.title) or "??").." = "..str.." at module: "..g_moduleNow, "HTML")
	    	print("Auto human!")
	    	onSucces(g_msg)
	    	return true, "human"
	    end
    else 
    	return false
	end
end


function captcha.closeCaptha(capid)
	if captcha.sequences[capid] then 
		local seq = captcha.sequences[capid]
		seq.success = false
		users[seq.target].captcha = nil
		SaveUser(seq.target)
		
	end
end


function captcha.sendCaptcha(chat, text)
    local str = string.format("%6.6d",math.random(0,999999)) 
    str = str:gsub("7", "1")                
    str = str:gsub("6", "8")
    text = text or "-"
    --Choose a random file
    local file = io.popen("ls modules/captcha/media/") 
    local s = file:read("*all")
    local parsed = {}
    for file in s:gmatch("(.-)\n") do 
    	parsed[#parsed+1] = file
    end

    local selectedFile = parsed[math.random(1, #parsed)]

    local ok = true
    local a = os.execute("convert ".."modules/captcha/media/"..parsed[math.random(1, #parsed)].."  -fill white -stroke black -pointsize 345 -gravity center -annotate "..(math.random(0,100) <= 50 and "-45" or "45").." '"..str.."' ../cache/cap.png") 
    if not a then 
        say.admin("failed 1-"..str.."-"..selectedFile)
        ok = false
        return str, false, {ok=false}
    end 
    a = os.execute("convert ../cache/cap.png -background white -wave 4x35 ../cache/cap2.png")
    if not a then 
        say.admin("failed 2"..str.."-"..selectedFile)
    end
    local lines = ""
    for i=1,15 do 
        lines = lines .. " -stroke black -strokewidth "..math.random(1,11).." -draw \"line "..math.random(0,960)..","..math.random(0,1280).." "..math.random(0,960)..","..math.random(0,1280).."\""
    end
    a = os.execute("convert ../cache/cap2.png -background white -wave 8x30 ../cache/cap2.png")
    if not a then 
         ok = false
        say.admin("failed 3"..str.."-"..selectedFile)
        return str, false, {ok=false}
    end
    a = os.execute("convert ../cache/cap2.png  "..lines.." ../cache/cap2.png")
    if not a then 
        ok = false
        say.admin("failed 4"..str.."-"..selectedFile)
        return str, false, {ok=false}
    end
    local photoMessage = bot.sendPhoto(chat, "../cache/cap2.png", text..(captcha.hasTTS and tr("captcha-can-tts") or ""), "HTML")
    if not photoMessage then 
    	say.admin("oh no = "..tostring(chat))
    	return str, false, {ok=false}
    end
    return str, photoMessage.ok, photoMessage
end

return captcha
