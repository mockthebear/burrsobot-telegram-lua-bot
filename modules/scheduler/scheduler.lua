local scheduler = {
	internalConfigId = "scheduler",
	tasks = {}
}

function scheduler.save()
	configs[scheduler.internalConfigId] = scheduler.tasks
	SaveConfig(scheduler.internalConfigId)
end

function scheduler.load()
	scheduler.tasks = configs[scheduler.internalConfigId] or {}
end

function scheduler.displayTimerAlert(obj, isRep, id)
	local kb = nil
	if isRep then 
		local keyb = {}
		keyb[1] = {}

		keyb[1][1] = { text = "Kill timer", callback_data = "scheduler:"..obj.chat..":"..obj.from..":"..id} 

		kb = cjson.encode({inline_keyboard = keyb })
	end
	local usr = getUser(obj.from)
	local txt = isRep and tr("scheduler-timer-rep-now", formatUserHtml(usr), obj.msg, scheduler.pastDate(os.time()+obj.diff, os.time())) or tr("scheduler-timer-now", formatUserHtml(usr), obj.msg)
	local res = bot.sendMessage(obj.chat,  txt, "HTML", true, false, obj.message_id, kb)
	if not res.ok then 
		res = bot.sendMessage(obj.chat, txt , "HTML", true, false, nil, kb)
		if not res.ok then 
			res = bot.sendMessage(obj.from, txt , "HTML", true, false, nil, kb)
			obj.chat = obj.from
			if not res.ok then 
				return false
			end
		end
	end
	return true
end


function scheduler.onCallbackQueryReceive(msg)
	if msg.message then
		if msg.data:match("scheduler:(.+)") then
			local  chat, user, id = msg.data:match("scheduler:(.-):(.-):(.+)")
			
			user = tonumber(user)
			chat = tonumber(chat)
			id = tonumber(id)

			if not scheduler.tasks[id] then 
				deploy_answerCallbackQuery(msg.id, "This timer is already deleted", "true")
				return
			end

			local canDelete = false
			if user == chat then 
				canDelete = true
			elseif msg.from.id == user then
				canDelete = true
			elseif chats[chat] then 
				if not msg.chat then 
					msg.chat = {
						id = chat
					}
				end
				if isEntityChatAdmin(msg, chat) then 
					canDelete = true
				end
			else
				canDelete = true
			end

			if canDelete then 
				scheduler.tasks[id] = nil
				deploy_answerCallbackQuery(msg.id, "Timer deleted", "true")
				deploy_editMessageReplyMarkup(msg.message.chat.id, msg.message.message_id, msg.inline_message_id, "{}")
				scheduler.save()
			else
				deploy_answerCallbackQuery(msg.id, "You cant delete this timer. Only the timer owner or a chat admin", "true")
			end
		end
	end
end

function scheduler.onMinute(min, hour, day)
	for id, obj in pairs(scheduler.tasks) do 
		if obj.mode == "at" then 
			if obj.timestamp <= os.time() then 
				scheduler.displayTimerAlert(obj, false, id)
				scheduler.tasks[id] = nil
				scheduler.save()
				return scheduler.onMinute(min, hour, day)
			end
		elseif obj.mode == "every" then 
			if obj.timestamp <= os.time() then 
				obj.timestamp = os.time() + obj.diff
				if not scheduler.displayTimerAlert(obj, true, id) then 
					scheduler.tasks[id] = nil
					scheduler.save()
					return scheduler.onMinute(min, hour, day)
				end
				
			end
		end
	end
end

function scheduler.calcAndSub(inp, val)
	local count = math.floor(inp/val)

	return count,inp - count*val
end
function scheduler.pastDate(ts, diff)
	diff = ts - diff
	local str = ""
	if diff <= 5 and diff >= -60 then 
		return tr("scheduler-now")
	end
	if diff < 0 then 
		str = tr("scheduler-past")
		diff = -diff
	else
		str =  tr("scheduler-in")
	end

	local mins, hour, days
	days, diff = scheduler.calcAndSub(diff, 3600*24)
	hour, diff = scheduler.calcAndSub(diff, 3600)
	mins, diff = scheduler.calcAndSub(diff, 60)
	
	
	local hourStr
	local dayStr
	local minStr
	if days > 0 then 
		dayStr = days.." " ..tr("scheduler-day")..(days > 1 and "s" or "")
	end
	if hour > 0 then 
		hourStr = hour.." " ..tr("scheduler-hour")..(hour > 1 and "s" or "")
	end
	if mins > 0 then 
		minStr= mins.." " ..tr("scheduler-min")..(mins > 1 and "s" or "")
	end

	if dayStr then 
		str = str .. " "..dayStr
	end

	if hourStr then 
		str = str .. ((dayStr and not minStr) and " and " or " ") ..hourStr
	end

	if minStr then 
		str = str .. ((hourStr or dayStr) and " and " or " ") ..minStr
	end
	return str
end


function scheduler.loadCommands()
	addCommand( "timer"	, MODE_FREE, getModulePath().."/timer.lua", 0, "")
end

function scheduler.loadTranslation()
	g_locale[LANG_US]["scheduler-now"] = "is now"
	g_locale[LANG_BR]["scheduler-now"] = "é agora"

	g_locale[LANG_US]["scheduler-in"] = "in"
	g_locale[LANG_BR]["scheduler-in"] = "em"

	g_locale[LANG_US]["scheduler-past"] = "past"
	g_locale[LANG_BR]["scheduler-past"] = "foi há"

	g_locale[LANG_US]["scheduler-day"] = "day"
	g_locale[LANG_BR]["scheduler-day"] = "dia"

	g_locale[LANG_US]["scheduler-min"] = "minute"
	g_locale[LANG_BR]["scheduler-min"] = "minuto"

	g_locale[LANG_US]["scheduler-hour"] = "hour"
	g_locale[LANG_BR]["scheduler-hour"] = "hora"

	g_locale[LANG_US]["scheduler-second"] = "second"
	g_locale[LANG_BR]["scheduler-second"] = "segundo"

	g_locale[LANG_US]["scheduler-minute"] = "minute"
	g_locale[LANG_BR]["scheduler-minute"] = "minuto"

	g_locale[LANG_US]["scheduler-month"] = "month"
	g_locale[LANG_BR]["scheduler-month"] = "mes"

	g_locale[LANG_US]["scheduler-year"] = "year"
	g_locale[LANG_BR]["scheduler-year"] = "ano"

	g_locale[LANG_US]["scheduler-timer-now"] = "%s your timer is up!!!\n\n<b>%s</b>"
	g_locale[LANG_BR]["scheduler-timer-now"] = "%s o seu timer acabou!!!\n\n<b>%s</b>"


	g_locale[LANG_US]["scheduler-timer-rep-now"] = "%s your timer is here!!!\n\n<b>%s</b>\n\nNext timer will be <code>%s</code>"
	g_locale[LANG_BR]["scheduler-timer-rep-now"] = "%s seu timer aqui!!!\n\n<b>%s</b>\n\nProximo timer será <code>%s</code>"


	g_locale[LANG_BR]["scheduler-timer-set"] = "Timer definido para <code>%s</code> isso será <b>%s</b>\nMensagem: <code>%s</code>"
	g_locale[LANG_US]["scheduler-timer-set"] = "Timer set to <code>%s</code> that would be <b>%s</b>\nMessage: <code>%s</code>"

	g_locale[LANG_BR]["scheduler-timer-past"] = "Esse timer <code>%s</code>"
	g_locale[LANG_US]["scheduler-timer-past"] = "This timer is <code>%s</code>"


	g_locale[LANG_BR]["scheduler-timer-how"] = "Use assim:\n/timer as (data DD/MM/YYYY podendo ter dia ou horario HH:MM) (mensagem):\n\n/timer as 25/12/2021 13:25 tomar remédio\n/timer as 16:20 hora do toddynho\n\n/timer as 27/06/2021 aniversario do guac\n\nOu:\n/timer em (podendo ser X minuto,hora,dia,mes,anos) (mensagem)\n\n/timer em 8 horas lembrar de ir no mercado\ntimer em 20 minutos o forno ta ligado\n\nOu você pode definir da mesma forma do '/timer em' usando 'cada' para o times se repetir:\n\n/timer cada 2 dias EU QUE LAVO A LOUÇA HOJE"
	g_locale[LANG_US]["scheduler-timer-how"] = "Use like:\n/timer at (date on format DD/MM/YY and/or time HHH:MM) (message):\n\n/timer at 25/12/2021 13:25 take my pills\n/timer at 16:20 chocolate milk time\n\n/timer at 27/06/2021 guac birthday\n\nOr:\n/timer in (can be X minute,hour,day,month,year) (message)\n\n/timer in 8 hours remember to go gorceries\ntimer in 20 minutes the oven is on\n\nOr you can use the same syntax of '/timer in' as 'every' to the timer repeat itself:\n/timer every 2 days  I MUST GO DO THE DISHES TODAY"

end


return scheduler