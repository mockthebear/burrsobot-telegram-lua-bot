local quotes = {
	chat = -324547263,
	require = {
		sql = {
			"SELECT 1 FROM `quote` LIMIT 1",
		}
	}
}


--[ONCE] runs when the load is finished
function quotes.load()
	if not configs["quote_rep"] then 
		configs["quote_rep"] = {}
	end
end

--[ONCE] runs when eveything is ready
function quotes.ready()

end

--Runs at the begin of the frame
function quotes.frame()

end

--Runs some times
function quotes.save()

end

function quotes.loadCommands()
	addCommand( {"quote"}		, MODE_FREE,  getModulePath().."/command.lua", 2 , "quotes-message-helper" )
end

function quotes.loadTranslation()


	g_locale[LANG_BR]["quotes-message-onlynum"] = "Somente números"
	g_locale[LANG_US]["quotes-message-onlynum"] = "Only numbers"

	g_locale[LANG_BR]["quotes-message-randomquote"] = "Quote aleatoria com id <b>%s</b>. \nTodas as quotes ficam em: <i>@quoteburrbot</i>"
	g_locale[LANG_US]["quotes-message-randomquote"] = "Random quote with id <b>%s</b>. \nAll quotes can be found at: <i>@quoteburrbot</i>"

	g_locale[LANG_BR]["quotes-message-noforward"] = "Mensagem não pode ser encaminhada:"
	g_locale[LANG_US]["quotes-message-noforward"] = "Message could not be forwarded:"

	g_locale[LANG_BR]["quotes-message-modified"] = "Mensagem alterada!\nMensagem original: <b>%s</b>"
	g_locale[LANG_US]["quotes-message-modified"] = "Modified message!\nOriginal message <b>%s</b>"

	g_locale[LANG_BR]["quotes-message-noquote"] = "Não consegui achar nem uma quote com id %s"
	g_locale[LANG_US]["quotes-message-noquote"] = "Could not find quote with id %s"


	g_locale[LANG_BR]["quotes-message-okquote"] = "Quote aprovada com ID %s\nUse /quote %s para ve-la,\n\nTodas as quotes estão no canal: https://t.me/quoteburrbot"
	g_locale[LANG_US]["quotes-message-okquote"] = "Approved quote with ID %s\nUse /quote %s to see it. \n\nAll quotes are in this channel: https://t.me/quoteburrbot"



	g_locale[LANG_BR]["quotes-message-quoterequest"] = "Requisição de quote enviada com ID <b>%s</b> por %s Em breve será aprovada ou negada."
	g_locale[LANG_US]["quotes-message-quoterequest"] = "Quote request <b>%s</b> was sent by %s and will be reviewd soon."


	g_locale[LANG_BR]["quotes-message-quotevoteok"] = "Requisição de quote <b>%s</b> foi <b>aprovada (good: %s/ bad:%s).</b>"
	g_locale[LANG_US]["quotes-message-quotevoteok"] = "Quote request <b>%s</b> is <b>approved (good: %s/ bad:%s).</b>"

	g_locale[LANG_BR]["quotes-message-quotevotenotok"] = "Quote <b>%s</b> foi <b>recusada. (good: %s/ bad:%s)</b>"
	g_locale[LANG_US]["quotes-message-quotevotenotok"] = "Quote <b>%s</b> was <b>refused. (good: %s/ bad:%s)</b>"


	g_locale[LANG_BR]["quotes-message-quotecomment"] = "\nCommentários:\n<code>%s</code>"
	g_locale[LANG_US]["quotes-message-quotecomment"] = "\nComments:\n<code>%s</code>"

	g_locale[LANG_BR]["quotes-message-helper"] = "Mostra uma quote ou salva uma quote. Quote é tipo uma mensagem salva. Salva-se mensagens engraçadas.\nPara exibir uma mensagem aleatoria use: /quote\nPara exibir uma mensagem especifica use: /quote (numero)\nPara adicionar uma mensagem, responda a mensagem que deve ser adicionada com o comando /quote"
	g_locale[LANG_US]["quotes-message-helper"] = "Shows a quote or save a quote. Quote is a messaged saved. You can store funny messages or something like that.\nTo show a random message just use /quote\nTo show a given message use /quote (number)\nTo add a quote, reply the given message with the /quote command"
	


end

function quotes.onTextReceive(msg)
	if msg.chat and msg.chat.id == quotes.chat then
		if msg.reply_to_message and msg.reply_to_message.text and msg.reply_to_message.text:match("Quote request (%d+)") then 
			local id = tonumber(msg.reply_to_message.text:match("Quote request (%d+)"))
			if id and configs["quote_rep"][id] then
				configs["quote_rep"][id].comment = (configs["quote_rep"][id].comment or "")..msg.from.first_name.."> "..msg.text.."\n\n"
				reply.html("Added comment: <code>"..msg.text:htmlFix().."</code>")
			else 
				reply("unknow quote "..tostring(id))
			end
			SaveConfig("quote_rep")
		end
	end
end

function quotes.showQuote(chat,id, r, recurs, n, masterId)


	id = tonumber(id) 

	if not id then 
		say(tr("quotes-message-onlynum"))
		return
	end
	local ret = db.getResult("SELECT * FROM `quote` WHERE `id`="..id..";")
	if ret:getID() ~= -1 and ret:getID() ~= nil then
		if r then
			say(ret:getDataString('text').."\nId: "..ret:getDataInt('id').." At "..os.date("%H:%M:%S %d/%m/%y",tonumber(ret:getDataInt('date') or "0")))
		else
			reply.html(tr("quotes-message-randomquote", id, id))

			local rer = bot.forwardMessage(chat, ret:getDataString('chatid'), false, ret:getDataString('msgid'))
			if rer and rer.ok == false then 
				bot.sendMessage(chat,tr("quotes-message-noforward").." "..rer.description)
				bot.sendMessage(chat,ret:getDataString('text').."\nId: "..ret:getDataInt('id').." At "..os.date("%H:%M:%S %d/%m/%y",tonumber(ret:getDataInt('date') or 0)).." message id: "..ret:getDataString('msgid'))
			else 
				if rer.result.text and rer.result.text ~= ret:getDataString('text'):match("@.-:%s(.+)") then 
					bot.sendMessage(chat, tr("Modified message!\nOriginal message by <b>%s</b>", ret:getDataString('text'):htmlFix()), "HTML")
				end
			end
		end
		ret:free()
		return true
	else 
		n = n or 0
		if recurs then 
			if n < 0 then
				n = (n or 0)-1
			else 
				n = (n or 0)+1
			end
			n = -n 
			showQuote(chat,id+n, r, true, n, masterId)
		else
			say(tr("quotes-message-noquote",id))
		end
	end
end

function quotes.onCallbackQueryReceive( msg )
	if msg.message then
		if msg.data:match("bqte:(%d+)") then
			local id = tonumber(msg.data:match("bqte:(%d+)"))
			if configs["quote_rep"][id] then
				if type(configs["quote_rep"][id].votes) == "string" then 
					configs["quote_rep"][id].votes = {}
				end

				if configs["quote_rep"][id].votes[msg.from.id] and configs["quote_rep"][id].votes[msg.from.id] ~= 'b' then 
					configs["quote_rep"][id].votes[msg.from.id] = nil
					configs["quote_rep"][id].good = configs["quote_rep"][id].good -1
				end

				if not configs["quote_rep"][id].votes[msg.from.id] or configs["quote_rep"][id].duration <= os.time() then 
					configs["quote_rep"][id].votes[msg.from.id] = 'b'
					configs["quote_rep"][id].bad = configs["quote_rep"][id].bad +1
					deploy_answerCallbackQuery(msg.id, "voted ( good "..configs["quote_rep"][id].good.." / bad: "..configs["quote_rep"][id].bad.." )", "true")
					if configs["quote_rep"][id].bad == 4 then 
						quotes.applyQuote(msg, id)
						return KILL_EXECUTION
					end
				else 
					deploy_answerCallbackQuery(msg.id, "No dual vote! ( good "..configs["quote_rep"][id].good.." / bad: "..configs["quote_rep"][id].bad.." )", "true")
				end
			else
				deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
			end
			return KILL_EXECUTION
		elseif msg.data:match("gqte:(%d+)") then
			local id = tonumber(msg.data:match("gqte:(%d+)"))

			if configs["quote_rep"][id] then
				if type(configs["quote_rep"][id].votes) == "string" then 
					configs["quote_rep"][id].votes = {}
				end

				if configs["quote_rep"][id].votes[msg.from.id] and configs["quote_rep"][id].votes[msg.from.id] ~= 'g' then 
					configs["quote_rep"][id].votes[msg.from.id] = nil
					configs["quote_rep"][id].bad = configs["quote_rep"][id].bad -1
				end
				
				if not configs["quote_rep"][id].votes[msg.from.id] or configs["quote_rep"][id].duration <= os.time() then 
					configs["quote_rep"][id].votes[msg.from.id] = 'g'
					configs["quote_rep"][id].good = configs["quote_rep"][id].good +1
					deploy_answerCallbackQuery(msg.id, "voted ( good "..configs["quote_rep"][id].good.." / bad: "..configs["quote_rep"][id].bad.." )", "true")
					if configs["quote_rep"][id].good == 4 then 
						quotes.applyQuote(msg, id)
						return KILL_EXECUTION
					end
				else 
					deploy_answerCallbackQuery(msg.id, "No dual vote! ( good "..configs["quote_rep"][id].good.." / bad: "..configs["quote_rep"][id].bad.." )", "true")
				end

			else
				deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
			end
			return KILL_EXECUTION
		end
	end
end


function quotes.applyQuote(msg, id)

    local rest = ""
    if configs["quote_rep"][id].comment then 
        rest = tr("quotes-message-quotecomment", configs["quote_rep"][id].comment:htmlFix())
    end
    if configs["quote_rep"][id].good >= configs["quote_rep"][id].bad then 
        deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)

        --bot.deleteMessage(configs["quote_rep"][id].msg2.result.chat.id, configs["quote_rep"][id].msg2.result.message_id)

        quotes.StoreMessage(configs["quote_rep"][id].quote[1], configs["quote_rep"][id].quote[2]) 
        
        SaveConfig("quote_rep")
        bot.sendMessage(configs["quote_rep"][id].chat, tr("quotes-message-quotevoteok", id, configs["quote_rep"][id].good, configs["quote_rep"][id].bad)..rest, 'HTML', true,false, configs["quote_rep"][id].quote[1].message_id)
        
        if msg.message and msg.message.chat and msg.message.chat.id and configs["quote_rep"] and configs["quote_rep"][id] then
            bot.sendMessage(
                msg.message.chat.id, 
                tr("quotes-message-quotevoteok", id, configs["quote_rep"][id].good, configs["quote_rep"][id].bad)..rest, 'HTML')
        end

        configs["quote_rep"][id] = nil 
        SaveConfig("quote_rep")
    else 
        deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)

        --bot.deleteMessage(configs["quote_rep"][id].msg2.result.chat.id, configs["quote_rep"][id].msg2.result.message_id)

        bot.sendMessage(configs["quote_rep"][id].chat, tr("quotes-message-quotevotenotok", id, configs["quote_rep"][id].good, configs["quote_rep"][id].bad)..rest, 'HTML', true,false, configs["quote_rep"][id].quote[1].message_id)
        if msg.message and msg.message.chat and msg.message.chat.id and configs["quote_rep"] and configs["quote_rep"][id] then
            bot.sendMessage(msg.message.chat.id, tr("quotes-message-quotevotenotok", id, configs["quote_rep"][id].good, configs["quote_rep"][id].bad)..rest, 'HTML')
        end
        configs["quote_rep"][id] = nil 
        SaveConfig("quote_rep")
    end
end

function quotes.onTextReceive(msg) 
	if msg.chat.id == quotes.chat and  msg.reply_to_message and msg.reply_to_message.text and msg.reply_to_message.text:match("Quote request (%d+)") then 
		local id = tonumber(msg.reply_to_message.text:match("Quote request (%d+)"))
		if id and configs["quote_rep"][id] then
			configs["quote_rep"][id].comment = (configs["quote_rep"][id].comment or "")..msg.from.first_name.."> "..msg.text.."\n\n"
			reply.html("Added comment: <code>"..msg.text:htmlFix().."</code>")
		else 
			reply("unknow quote "..tostring(id))
		end
		SaveConfig("quote_rep")
	end
end


function quotes.StoreMessage(rep, who) 
    local ret = db.getResult("SELECT * FROM `quote` WHERE `msgid`="..rep.message_id.." AND `chatid`="..rep.chat.id..";")
    if ret:getID() ~= -1 and ret:getID() ~= nil then
        ret:free()
        say("Sorry, "..rep.chat.id..":"..rep.message_id.." is already stored with ID "..ret:getDataInt('id'))
        return true
    end
    rep.date = rep.date or 0
    local txt = "@"..(rep.from.username or rep.from.first_name)..": "
    if rep.text then 
        txt = txt..rep.text
    else 
        txt = txt.."sent a sticker "
    end



    local ret = db.getResult("SELECT id FROM `quote` ORDER BY id;")
    local found = false
    local nonSeq = 0
    if ret:getID() ~= -1 and ret:getID() ~= nil then
        repeat 
            if nonSeq ~=  ret:getDataInt("id") then 
                found = true
                break
            else 
                nonSeq = nonSeq +1
            end
        until not ret:next()
        ret:free()
    end

    db.executeQuery("INSERT INTO `quote` (`id`, `text`, `msgid`, `chatid`, `date`) VALUES ("..(found and nonSeq or "NULL") ..", '"..db.escapeString(txt).."', '"..rep.message_id.."', '"..rep.chat.id.."', '"..rep.date.."');")

    local ret = db.getResult("SELECT * FROM `quote` WHERE `msgid`="..rep.message_id.." AND `chatid`="..rep.chat.id..";")
    if ret:getID() ~= -1 and ret:getID() ~= nil then
        ret:free()
        local quotid = ret:getDataInt('id')
        g_chatid = rep.chat.id
        local msg3 = say(tr("quotes-message-okquote", quotid, quotid))

        --say_admin("New quote by "..tostring(who))
        --bot.forwardMessage(81891406, rep.chat.id, false, rep.message_id)

        local msg1 = bot.sendMessage("@quoteburrbot","#quote <b>"..ret:getDataInt('id').."</b> by @"..tostring(who), "HTML")
        local msg2 = bot.forwardMessage("@quoteburrbot", rep.chat.id, false, rep.message_id)

       
        local keyb2 = {}
        keyb2[1] = {}
        keyb2[1][1] = {text = tr("delete"), callback_data = "dqte:"..ret:getDataInt('id') }
        local JSON = require("JSON")
        local kb3 = JSON:encode({inline_keyboard = keyb2 })


        bot.sendMessage(81891406, "Quote by "..tostring(who).."->\n\n"..txt, "", true, false, nil, kb3)
        return quotid
        
    else 
        say("Could not store "..rep.chat.id..":"..rep.message_id)
    end
end

return quotes