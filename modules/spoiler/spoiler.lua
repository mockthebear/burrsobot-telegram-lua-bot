local spoiler = {
	priority = DEFAULT_PRIORITY,
}

--[ONCE] runs when the load is finished
function spoiler.load()

end

--[ONCE] runs when eveything is ready
function spoiler.ready()

end

function spoiler.onCallbackQueryReceive(msg)
	if msg.data:match("spl:(.+)") then
		local spoilerstr = msg.data:match("spl:(.+)")
		bot.answerCallbackQuery(msg.id, spoilerstr, true)
		return KILL_EXECUTION
	end
end


function spoiler.onInlineQueryReceive(msg)
	if msg.query:match("spoiler[:%s,](.+)") then
		g_lang = detectLanguage(msg)
		local spoilerstr = msg.query:match("spoiler[:%s,](.+)")
		spoilerstr = spoilerstr:sub(1, 58)
		spoilerstr = spoilerstr:gsub("\"","'")
		spoiler.replySpoiler(msg.id, spoilerstr, msg.from)
		return KILL_EXECUTION
	end
end

function spoiler.replySpoiler(id, spoilerstr, usr)	
	local keyb = {}
	keyb[1] = {}
	keyb[1][1] = { text = "Click to see the spoiler", callback_data = "spl:"..spoilerstr} 
	local parsedStr = ""
	for i=1,#spoilerstr do 
		if spoilerstr:sub(i,i) == " " then 
			parsedStr = parsedStr.. "░"
		else 
			parsedStr = parsedStr.."▒"
		end
	end
	bot.answerInlineQuery(id, { {type="article", id=1, title="Send spoiler: "..spoilerstr, input_message_content = {message_text=tr("spoiler-spoiler", formatUserHtml(usr), parsedStr:htmlFix(), g_botname), parse_mode="HTML"   }, reply_markup =  {inline_keyboard = keyb }   } }, nil, "HTML", nil, "", "kektus")	
end

--Runs at the begin of the frame
function spoiler.frame()

end

--Runs some times
function spoiler.save()

end

function spoiler.loadCommands()
	
end

function spoiler.loadTranslation()
	g_locale[LANG_US]["spoiler-spoiler"] = "%s <b>sent a spoiler:</b>\n<code>%s</code>\nTo send a spoiler just type:\n<code>@%s spoiler: (your spoiler here up to 60 characters)</code>"
	g_locale[LANG_BR]["spoiler-spoiler"] = "%s <b>enviou um spoiler:</b>\n<code>%s</code>\nPara enviar spoiler digite:\n<code>@%s spoiler: (seu spoiler, até 60 caracteres)</code>"
end


return spoiler