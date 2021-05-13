local nospam = {
	channel = "@burrbanbot"
}

--[ONCE] runs when the load is finished
function nospam.load()
    if pubsub then
        pubsub.registerExternalVariable("chat", "nospam", {type="boolean"}, true, "Enable no spam", "Nospam")
        pubsub.registerExternalVariable("chat", "maxSpamTime", {type="number", default=60}, true, "Max spam time", "Nospam")
        pubsub.registerExternalVariable("chat", "maxSpamMessages", {type="number", default=30}, true, "Max spam messages", "Nospam")
        pubsub.registerExternalVariable("chat", "actionSpam", {type="string", valid={"ban", "warn", "lock", "mute"}, default="warn" }, true, "Action spam", "Nospam") 
    end
end

--[ONCE] runs when eveything is ready
function nospam.ready()
end

--Runs at the begin of the frame
function nospam.frame()

end

--Runs some times
function nospam.save()

end

function nospam.loadCommands()
	addCommand( "nospam"					, MODE_CHATADMS, getModulePath().."/command.lua", 2, tr("nospam-desc").."\n"..tr("nospam-usage") )
	--addCommand( {"bolo", "cake"}		, MODE_FREE,  getModulePath().."/bolo.lua", 2 , "example-desc" )
end

function nospam.loadTranslation()
	g_locale[LANG_BR]["nospam-desc"] = "Liga/Desliga proteção contra spam."
	g_locale[LANG_US]["nospam-desc"] = "Toggles spam protection"


	g_locale[LANG_US]["nospam-usage"] = "Usage:\n/nospam on -- Turn on\n/nospam off -- Turn off\n/nospam rate 60 -- Set a rate of 60 messages per minute (can be changed)\n/nospam action ban -- Set the action to ban\n/nospam action mute -- Set the action to mute for 30 mins\n/nospam action lock -- Mute the user permamently until an admin unmutes\n/nospam action warn -- Set the action to just warn\n/nospam rates -- Show all user rates so far"
	g_locale[LANG_BR]["nospam-usage"] = "Como usar:\n/nospam on -- Liga o anti spam\n/nospam off -- Desliga\n/nospam rate 60 -- Define uma taxa de mensagens por minuto\n/nospam action ban -- Define a ação a ser tomada quando spammarem como ban do chat\n/nospam action mute -- Define a ação a ser tomada quando spammarem como mutar por 30 minutos\n/nospam action lock -- Define a ação a ser tomada quando spammarem como mutar até que um admin desmute manualmente\n/nospam action warn -- Define a ação a ser tomada quando spammarem como apenas avisar os admins e ao usuário.\n/nospam rates -- Mostra as estatisticas"

	g_locale[LANG_BR]["nospam-stat"] = "Status do no spam: "
	g_locale[LANG_US]["nospam-stat"] = "No spam status: "


	g_locale[LANG_BR]["nospam-active"] = "✅ ativo"
	g_locale[LANG_US]["nospam-active"] = "✅ active"

	g_locale[LANG_BR]["nospam-inactive"] = "❌ inactive"
	g_locale[LANG_US]["nospam-inactive"] = "❌ inactive"

	g_locale[LANG_BR]["nospam-msg-warn"] = "(warn) avisar o usuário sobre o spam."
	g_locale[LANG_US]["nospam-msg-warn"] = "warn the user about the spam."

	g_locale[LANG_BR]["nospam-msg-ban"] = "(ban) banir o usuário."
	g_locale[LANG_US]["nospam-msg-ban"] = "ban (kick) the user."

	g_locale[LANG_BR]["nospam-msg-lock"] = "(lock) mutar o usuário até que um admin desbloqueie."
	g_locale[LANG_US]["nospam-msg-lock"] = "lock the user until an admin unmutes."

	g_locale[LANG_BR]["nospam-msg-mute"] = "(mute) mutar usuário por 30 minutos."
	g_locale[LANG_US]["nospam-msg-mute"] = "mute the user for 30 mins."

	g_locale[LANG_BR]["nospam-msg-kick"] = "(kick) kickar o usuário."
	g_locale[LANG_US]["nospam-msg-kick"] = "kick the user."

	g_locale[LANG_BR]["nospam-msg-rates"] = "\nA taxa de mensagens é de <b>%s mensagens por %s</b>\n"
	g_locale[LANG_US]["nospam-msg-rate"] = "\nThe message per ratio is <b>%s messages per %s</b>\n"

	g_locale[LANG_BR]["nospam-msg-do"] = "Quando um usuário estiver spammando a ação será avisar os admins e <b>%s</b>!"
	g_locale[LANG_US]["nospam-msg-do"] = "And when spam is detected my action would be warn the admins and <b>%s</b>!"

	g_locale[LANG_BR]["nospam-taking-action"] = "Spam detectado. Taxa de mensagens: %s ultrapassou %s mensagens por minuto. Aplicando: %s"
	g_locale[LANG_US]["nospam-taking-action"] = "Spam detected. Message rate:  %s is greater than  %s messages per minute. Applying: %s"

	g_locale[LANG_BR]["nospam-fail-ban"] = "Não foi possivel banir por que: %s"
	g_locale[LANG_US]["nospam-fail-ban"] = "Could not ban because: %"

	g_locale[LANG_BR]["nospam-saying-action"] = "Atenção %s usuário %s está spammando!\nAção: %s"
	g_locale[LANG_US]["nospam-saying-action"] = "Attention %s user %s was spamming!\nAction: %s"

	g_locale[LANG_BR]["nospam-nopermissions"] = "Não foi possivel ativar totalmente por que eu não tenho permissões. Eu preciso poder restringir e deletar mensagens. Você pode usar /permitions para checar quais permissões eu tenho."
	g_locale[LANG_US]["nospam-nopermissions"] = "Cannot fully activate anti spam because i dont have enought permissions. I need to be able to restrict and delete messages. Can use to check permitions /permitions"


end

function nospam.renderSpamStatus(chatid)
	local txt = tr("nospam-stat")
	if chats[chatid].data.nospam then 
		txt = txt .. tr("nospam-active")
	else 
		txt = txt .. tr("nospam-inactive")
	end
	local rate = ((chats[chatid].data.maxSpamTime or 60)/60)
	if rate == 1 then 
		rate = tr("minute")
	else
		rate = (math.floor(rate*10)/10) .." "..tr("minutes")
	end
	local action = chats[chatid].data.actionSpam

	if action == "warn" then 
		action = tr("nospam-msg-warn")
	elseif action == "ban" then 
		action = tr("nospam-msg-ban")
	elseif action == "lock" then 
		action = tr("nospam-msg-lock")
	elseif action == "mute" then 
		action = tr("nospam-msg-mute")
	else
		action = tr("nospam-msg-kick")
	end
	txt = txt .. tr("nospam-msg-rates", (chats[chatid].data.maxSpamMessages or 30), rate)
	txt = txt .. tr("nospam-msg-do", action)
	reply.html(txt)
end


function nospam.calculate_rate(rl)
    local diffTime = (os.time()-rl[1]) 
    local deltaTime = diffTime / rl.max
    local loc = rl[2] == false and 1 or 2
    local rate = rl.rate[loc] + (rl.rate[loc == 2 and 1 or 2])*(1.0-deltaTime) 
    return rate
end


function nospam.check_spam_message(msg)
    if (msg.date - g_startup) < -10 then 
        print("Skipping message because message is "..(msg.date - os.time()))
        return false
    end
    if msg.chat and msg.chat.id and msg.from.id then 
        local lch = chats[msg.chat.id]
        if lch and lch.data.nospam then 
            if not lch._tmp.spam then 
                lch._tmp.spam = {}
            end
            if not lch._tmp.spam[msg.from.id] then 
                local mx = lch.data.maxSpamTime or 60
                local mr = lch.data.maxSpamMessages or 30
                --[1] = 
                lch._tmp.spam[msg.from.id] = {first_name=msg.from.first_name, max=mx, rate={0,0}, os.time(), false, mr}
            end

            local loc = lch._tmp.spam[msg.from.id][2] == false and 1 or 2

            lch._tmp.spam[msg.from.id].rate[loc] = lch._tmp.spam[msg.from.id].rate[loc] + 1

            while (lch._tmp.spam[msg.from.id][1]+lch._tmp.spam[msg.from.id].max) < os.time() do 
                --print("Reseting window: "..loc.." for "..msg.from.first_name.." - last rate: "..nospam.calculate_rate(lch._tmp.spam[msg.from.id]))
                lch._tmp.spam[msg.from.id][2] = lch._tmp.spam[msg.from.id][2] == false
                
                loc = lch._tmp.spam[msg.from.id][2] == false and 1 or 2
                lch._tmp.spam[msg.from.id].rate[loc] = 0
                
                if (lch._tmp.spam[msg.from.id][1] + lch._tmp.spam[msg.from.id].max * 3 <= os.time() ) then
                    lch._tmp.spam[msg.from.id][1] = os.time()
                    lch._tmp.spam[msg.from.id].rate = {0,0}
                    --print("Hard reset rate for "..msg.from.first_name)
                else
                    lch._tmp.spam[msg.from.id][1] = lch._tmp.spam[msg.from.id][1] + lch._tmp.spam[msg.from.id].max
                end
      
            end

            local rate = nospam.calculate_rate(lch._tmp.spam[msg.from.id])

            if rate >= lch._tmp.spam[msg.from.id][3] then 
                print("Rate limiting "..msg.from.first_name)
                if users[msg.from.id] then 
                    local action = chats[msg.chat.id].data.actionSpam or "ban"
                    reply(tr("nospam-taking-action", rate, lch._tmp.spam[msg.from.id][3], action))
                    nospam.apply_spam_action(msg, action)
                    lch._tmp.spam[msg.from.id] = nil
                    return KILL_EXECUTION
                end
            end
        end
    end
    return true
end



function nospam.apply_spam_action(msg, action)
    if action == 'ban' then 
        local res = bot.kickChatMember(msg.chat.id, msg.from.id)
        if not res.ok then 
        	say(tr("nospam-fail-ban", res.description))
        end
    elseif action == 'lock' then 
        local res = bot.restrictChatMember(msg.chat.id, msg.from.id, -1, false, false, false, false)
        if not res.ok then 
        	say(tr("nospam-fail-ban", res.description))
        end
    elseif action == 'mute' then 
        local res = bot.restrictChatMember(msg.chat.id, msg.from.id, os.time() + 3600/2, false, false, false, false)
        if not res.ok then 
        	say(tr("nospam-fail-ban", res.description))
        end
    elseif action == 'raid' then 
        local res = bot.restrictChatMember(msg.chat.id, msg.from.id, -1, false, false, false, false)
        if not res.ok then 
        	say(tr("nospam-fail-ban", res.description))
        end
        users[msg.from.id].raider = true
        if nospam.channel and tostring(nospam.channel) > 4 then
        	deploy_sendMessage("@burrbanbot","❗️❗️❗️❗️RAIDER detected ("..formatUserHtml(msg)..")❗️❗️❗️❗️", "HTML")
    	end
    end
    local str = ""
    local adms = bot.getChatAdministrators(msg.chat.id)
    for i=1, #adms.result do 
        local admin = adms.result[i]
        str = str .. formatUserHtml({from=admin.user}).." "
    end
    local warnMessage = tr("nospam-saying-action", str, formatUserHtml(msg), action)
    if nospam.channel and #tostring(nospam.channel) > 4 then
    	deploy_sendMessage(nospam.channel,"Spammer detected ("..formatUserHtml(msg)..")❗️❗️❗️❗️\nAction: "..action, "HTML")
    end

    say.html(warnMessage)
end


function nospam.onDocumentReceive(msg, action)
	if not nospam.check_spam_message(msg) then 
		return KILL_EXECUTION
	end
end

function nospam.onPhotoReceive(msg, action)
	if not nospam.check_spam_message(msg) then 
		return KILL_EXECUTION
	end
end

function nospam.onAudioReceive(msg, action)
	if not nospam.check_spam_message(msg) then 
		return KILL_EXECUTION
	end
end

function nospam.onStickerReceive(msg, action)
	if not nospam.check_spam_message(msg) then 
		return KILL_EXECUTION
	end
end

function nospam.onTextReceive(msg, action)
	if not nospam.check_spam_message(msg) then 
		return KILL_EXECUTION
	end
end

return nospam