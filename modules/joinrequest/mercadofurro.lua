local mercadofurro = {
	chat=-1001063487371,
    warn_chat = -1001420250189,
    image_cooldown = 3600 * 6,
    post_duration = 300,
    image_count = 3,
    maxwarnings = 3,
    mute_time = 3600*24,
    adminchat=-1002023074299,
    lastGlobalWarning=0,
    mediaGroups={},
    notextMd5 = ngx.md5('<mensagem sem texto>'),
    validHashes = {},
    cachedConfirmation = {},
    reasons = {
        [1] = "Mensagem sem texto",
        [2] = "Falta preço e mensagem não esta em portugues",
        [3] = "Mensagem sem preço",
        [4] = "Sem preço em real",
        [5] = "Contem preço certo mas mensagem não esta em portugues",
    }
}

--[ONCE] runs when the load is finished
function mercadofurro.load()
    mercadofurro.warnings = configs["warnings"] or {}
    mercadofurro.validHashes = configs["validHashes"] or {}
end

--[ONCE] runs when eveything is ready 
function mercadofurro.ready()
end

--Runs at the begin of the frame
function mercadofurro.frame()
end

--Runs some times
function mercadofurro.save()
   configs["warnings"] = mercadofurro.warnings
   configs["validHashes"] = mercadofurro.validHashes
end

function mercadofurro.loadCommands()
    addCommand( {"mf_forgive"}  , mercadofurro.adminchat, function(msg)

        local usr, tgt = getTargetUser(msg, nil, true)
        if not usr then 
            return tgt and reply(tr("Quem é %s?", tgt))
        end 

        usr.mf_warning_count = 0
        usr.mf_lastmedia = 0

        mercadofurro.warnings[usr.telegramid] = 0
        mercadofurro.save()
        SaveUser(usr.telegramid)
        reply("ok")

     end,2 , "Perdão a um usuario.")

end

function mercadofurro.loadTranslation() 
end

function mercadofurro.remainingTime(tgt)
	local diff = tgt 
	local hours =  math.floor(diff/3600)
	diff = diff - hours*3600
	local mins =   math.floor(diff/60)

	local secs = diff%60
	return (hours > 0 and string.format("%2.2d", hours)..":" or "")..string.format("%2.2d:%2.2d", mins, secs)
end



function mercadofurro.check_warning(msg, last_warning)
    if os.time()-last_warning < (mercadofurro.image_cooldown * 2/3) then 
        --Mandou antes de 10h
        users[msg.from.id].mf_warning_count = (users[msg.from.id].mf_warning_count or 0) + 1
        if users[msg.from.id].mf_warning_count > 1 then 
            local said = say.html("<b>[WARNING]</b> "..formatUserHtml(msg)..". Este é o aviso "..(users[msg.from.id].mf_warning_count-1).."/"..mercadofurro.maxwarnings..". Por favor respeitar os limites de anuncios.")
            bot.sendMessage(mercadofurro.warn_chat, "<b>[WARNING]</b> to user "..formatUserHtml(msg).."! Este é o aviso "..(users[msg.from.id].mf_warning_count-1).."/"..mercadofurro.maxwarnings, "HTML")
            if (users[msg.from.id].mf_warning_count-1) >= mercadofurro.maxwarnings then 
                bot.restrictChatMember(msg.chat.id, msg.from.id, os.time()+mercadofurro.mute_time, false, false, false, false)
            end
            scheduleEvent( 60, function(msg, said)
                if said.ok then
                    bot.deleteMessage(said.result.chat.id, said.result.message_id)
                end
            end, msg, said)
        end
    else 
        users[msg.from.id].mf_warning_count = 1
    end
end


function mercadofurro.check_media(msg)
    if msg.chat and msg.chat.id == mercadofurro.chat then 
        local entity, which = getEntity(msg)
        if which ~= "user" then 
            bot.deleteMessage(msg.chat.id, msg.message_id)
            if mercadofurro.lastGlobalWarning <= os.time() then
                mercadofurro.lastGlobalWarning  = os.time() + 60
                local said = say.html("Atenção "..formatUserHtml(msg).." infelizmente não é permitido que anuncios sejam feitos usando canais. Faça seu anuncio usando sua conta normal por favor :)")
                scheduleEvent( 30, function(msg, said)
                    if said.ok then
                        bot.deleteMessage(said.result.chat.id, said.result.message_id)
                    end
                end, msg, said)
            end
            return false
        end

        if entity then 
            local last_media = entity.mf_lastmedia or 0 

            if last_media >= os.time() then 
                local time_since = os.time() - last_media + mercadofurro.image_cooldown
                local alternateMessage = false
                if time_since > 0 and time_since >= mercadofurro.post_duration then 
                    entity.mf_mediacount = mercadofurro.image_count
                    alternateMessage = true
                end
                if entity.mf_mediacount >= mercadofurro.image_count then 
                    local last_warning = (entity.mf_last_warning or 0 )
                    if last_warning < os.time() then 
                        local nextAllowed = entity.mf_lastmedia
                        local lastSent = os.date("%H:%M:%S",nextAllowed - mercadofurro.image_cooldown)
                        nextAllowed = os.date("%H:%M:%S", nextAllowed )
                        local txt =  "só é permitido apenas "..mercadofurro.image_count.." (imagens/video/stickers) a cada <b>"..math.floor(mercadofurro.image_cooldown/3600).."</b> horas."
                        if alternateMessage then 
                            txt =  "só é permitido apenas UM POST a cada <b>"..math.floor(mercadofurro.image_cooldown/3600).."</b> horas."
                        end

                        local said = say.html("Atenção "..formatUserHtml(msg).." "..txt.." Sua utima postagem foi as <b>"..lastSent.."</b> e você só poderá postar novamente as <b>"..nextAllowed.."</b> (aproximadamente: "..mercadofurro.remainingTime(entity.mf_lastmedia-os.time())..")")
                        scheduleEvent( 30, function(msg, said)
                            if said.ok then
                                bot.deleteMessage(said.result.chat.id, said.result.message_id)
                            end
                        end, msg, said)
                        mercadofurro.check_warning(msg, last_warning)
                        entity.mf_last_warning = os.time() + 30
                    end
                    bot.deleteMessage(msg.chat.id, msg.message_id)
                    return false
                else 
                    entity.mf_mediacount = (entity.mf_mediacount or 1) + 1
                end                
            else 
                entity.mf_lastmedia = os.time() + mercadofurro.image_cooldown
                entity.mf_mediacount = 1
            end
            SaveUser(msg.from.id)
        end
    end
    return true
end

--[[
Headshot: 5 USD  | 20 BRL
Halfbody: 10 USD  |  30 BRL
Fullbody: 15 USD  |  40 BRL

]]

--curl https://ws.detectlanguage.com/0.2/detect -H "Authorization: Bearer e0ff4b538a0fd685667b53352a34cc94" -d 'q=eu gosto de bolo eita'


function mercadofurro.isPortuguese(msg)
    local http = require("resty.http")

    -- Define the API endpoint and parameters
    local api_url = "https://ws.detectlanguage.com/0.2/detect"
    local api_key = "e0ff4b538a0fd685667b53352a34cc94"


    -- Create HTTP client
    local httpc = http.new()

    -- Set the headers
    local headers = {
        ["Authorization"] = "Bearer " .. api_key,
        ["Content-Type"] = "application/x-www-form-urlencoded",
    }

    -- Set the request body
    local body = "q=" .. ngx.escape_uri(msg)

    -- Make the HTTP request
    local res, err = httpc:request_uri(api_url, {
        method = "POST",
        body = body,
        ssl_verify = false,
        headers = headers,
    })

    if not res then
        return false, "error: "..err
    end



    if res.status == 200 then 
        print(res.body)
        local content = cjson.decode(res.body)
        --{"data":{"detections":[{"language":"pt","isReliable":true,"confidence":12.56}]}}
        if not content or not content.data or not content.data.detections then 
            return false, "error"
        end

        local languages = ""

        for a,c in pairs(content.data.detections) do 
            languages = languages ..c.language..', ' 
            if c.language == "pt" then  
                return true, res.body
            end
        end 

        if languages == "" then 
            return false, "Nenhuma lingua detectada"
        end

        return false, "Linguagens: "..languages
    end
    return false, "error status: "..tostring(res.status)
end

function mercadofurro.hasPrice(msg)
    msg = msg:lower()
    local conditions = {
        "([%d,%.]+)%$",
        "([%d,%.]+).?%$",
        "%$([%d,%.]+)",
        "%$%s*([%d,%.]+)",
        "([%d,%.]+)%$",
        "([%d,%.]+)%s*brl",
        "([%d,%.]+)%s*r",

        "%$([%d,%.]+)",
        "brl%s*([%d,%.]+)",
        "r%$%s*([%d,%.]+)",
        "r%s*([%d,%.]+)",


        "usd%s*([%d,%.]+)",
        "([%d,%.]+)%s*usd",
        "%-%s([%d,%.]+)",
        "$:%s*([%d,%.]+)",
    
    }

    for a,c in pairs(conditions) do 
        if msg:match(c) and msg:match("%d") then 
            return true, c
        end
    end
    
    return false
end

function mercadofurro.isReal(msg)
    msg = msg:lower()
    local conditions = {
        "brl%s*≈%s*([%d,%.]+)", 
        "brl%s*([%d,%.]+)", 
        "r%$%s*([%d,%.]+)", 
        "([%d,%.]+)%s*brl", 
        "([%d,%.]+)%s*r%$", 
        "([%d,%.]+)%s*reais",   
        "reais%s*([%d,%.]+)",   
        "([%d,%.]+)%s*reais",
        "r$:%s*([%d,%.]+)",
    }

    for a,c in pairs(conditions) do 
        if msg:match(c) then 
            return true, c
        end
    end
    return false
end

function mercadofurro.deleteMessagesFromGroup(msgid)
    local res = bot.deleteMessage(mercadofurro.chat, msgid)
    if res.ok then 
        for a,mg in pairs(mercadofurro.mediaGroups) do 
            if mg.core_message == msgid then 
                for i,b in pairs(mg.messages) do 
                    local resB = bot.deleteMessage(mercadofurro.chat, b.message_id)
                    --say.admin("Res b is "..cjson.encode(resB))
                end
                mercadofurro.mediaGroups[a] = nil
                return true
            end
        end
        return true
    else 
        return false
    end
end

function mercadofurro.onCallbackQueryReceive(msg)
    if msg.message then
        if msg.data:match("mfurro:.+") then
            if msg.data:match("mfurro:ok:(.+)") then
                local hash = msg.data:match("mfurro:ok:(.+)")
                deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
                deploy_answerCallbackQuery(msg.id, "Pronto")
                mercadofurro.validHashes[hash] = true
                mercadofurro.save()
            elseif msg.data:match("mfurro:sowwy") then
                deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
                deploy_answerCallbackQuery(msg.id, "Boa :3")
            elseif msg.data:match("mfurro:review:(%d+):(%d+)") then
                local userstr, reason = msg.data:match("mfurro:review:(%d+):(%d+)")
                local userid = tonumber(userstr)
                reason = tonumber(reason)
                if msg.from.id ~= userid then  
                    deploy_answerCallbackQuery(msg.id, "Apenas quem levou o alerta pode apertar")
                    return
                end

                if not mercadofurro.cachedConfirmation[userid] or mercadofurro.cachedConfirmation[userid] < os.time() then
                    mercadofurro.cachedConfirmation[userid] = os.time() + 3600
                    deploy_answerCallbackQuery(msg.id, "Anúncios devem incluir texto em português e valores em reais. Falha em ambas condições resulta em aviso. Caso seu anuncio estiver correto, aperte o aviso novamente que um admin será notificado.", "true")
                    return
                end
                local usr = getUserById(userid)
                if not usr.private then  
                    deploy_answerCallbackQuery(msg.id, "A resolução será feita no privado com o bot. Por favor vá no privado com o @burrsobot e dê /start e aperte novamente esse botão.", "true")
                    return
                end

                local res = bot.sendMessage(usr.private, "Opa! Eu notiquei os admins do mercado furry. Assim que der, lhe darei uma devolutiva", "HTML")
                if not res.ok then 
                    deploy_answerCallbackQuery(msg.id, "A resolução será feita no privado com o bot. Por favor vá no privado com o @burrsobot e dê /start e aperte novamente esse botão.", "true")
                    return
                end
                deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
                deploy_answerCallbackQuery(msg.id, "Admins notificados, alguem entrará em contato :3", "true")

                local keyboard = {}
                keyboard[1] = {}
                keyboard[2] = {}

                keyboard[1][1] = { text = "Erro nosso 😭", callback_data = "mfurro:mybad:"..userid} 
                keyboard[2][1] = { text = "Anuncio estava errado 😡", callback_data = "mfurro:yourbad:"..userid} 

                local keyboardkb = cjson.encode({inline_keyboard = keyboard })

                bot.sendMessage(mercadofurro.adminchat, "Usuário "..formatUserHtml(usr).." informou que o anuncio estava correto, por favor verificar.", "HTML", nil, nil, nil, keyboardkb)
                
            elseif msg.data:match("mfurro:mybad:(%d+)") then
                local userstr = msg.data:match("mfurro:mybad:(%d+)")
                local userid = tonumber(userstr)
                deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
                deploy_answerCallbackQuery(msg.id, "Ok", "true")
                if not mercadofurro.warnings[userid] then 
                    mercadofurro.warnings[userid] = 0
                end
                mercadofurro.warnings[userid] = mercadofurro.warnings[userid] -1

                local usr = getUserById(userid)

                usr.mf_warning_count = 0
                usr.mf_lastmedia = 0

                mercadofurro.save()
                SaveUser(usr.telegramid)

                bot.sendMessage(mercadofurro.adminchat, "Resolvido~")
                bot.sendMessage(userid, "Oi, os admins reviram seu anuncio e ele de fato estava correto. Pedimos desculpa pelo ocorrido. Os avisos foram removidos e o cooldown de anuncio foi reiniciado, você pode reenviar seu anuncio.")
            elseif msg.data:match("mfurro:yourbad:(%d+)") then
                local userstr = msg.data:match("mfurro:yourbad:(%d+)")
                local userid = tonumber(userstr)
                deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
                deploy_answerCallbackQuery(msg.id, "Ok", "true")

                bot.sendMessage(mercadofurro.adminchat, "Usuario informado")
                bot.sendMessage(userid, "Oi, os admins reviram seu anuncio, e ele não está conforme as regras.\nLembrando que é obrigatorio que:\nAnuncio esteja em português ou todo texto em inglês também acompanhe sua tradução\nValores em reais.\n\nCaso ainda ache que foi um erro, entre em contato com qualquer um admin do chat.")
            
            elseif msg.data:match("mfurro:del:(%d+):(%d+):(%d+)") then
                local msgid, userid = msg.data:match("mfurro:del:(%d+):(%d+):(%d+)")
                userid = tonumber(userid)
                local usr = getUserById(userid)

                local res = mercadofurro.deleteMessagesFromGroup(tonumber(msgid))
                deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
                if res then 
                    deploy_answerCallbackQuery(msg.id, "Mensagem ja foi excluida.", "true")
                    return
                end
            elseif msg.data:match("mfurro:ban:(%d+):(%d+)") then
                local msgid, userid = msg.data:match("mfurro:ban:(%d+):(%d+)")
                userid = tonumber(userid)
                local usr = getUserById(userid)

                local res = mercadofurro.deleteMessagesFromGroup(tonumber(msgid))
                deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
                if res then 
                    deploy_answerCallbackQuery(msg.id, "Mensagem ja foi excluida.", "true")
                    return
                end
                bot.kickChatMember(mercadofurro.chat, userid,  -1) 
                local usr = getUserById(userid)
                bot.sendMessage(mercadofurro.adminchat, "Ban tomado por "..formatUserHtml(msg).." quanto a "..formatUserHtml(usr)..'\nAvisos desse usuario: '..tostring(mercadofurro.warnings[userid]), "HTML")
            
            elseif msg.data:match("mfurro:warn:(%d+):(%d+):(%d+)") then
                local msgid, userid, reason = msg.data:match("mfurro:warn:(%d+):(%d+):(%d+)")
                userid = tonumber(userid)
                local usr = getUserById(userid)

                local res = mercadofurro.deleteMessagesFromGroup(tonumber(msgid))
                deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
                if not res then 
                    deploy_answerCallbackQuery(msg.id, "Mensagem ja foi excluida.", "true")
                    return
                end

                if not mercadofurro.warnings[userid] then 
                    mercadofurro.warnings[userid] = 0
                end
                mercadofurro.warnings[userid] = mercadofurro.warnings[userid] +1

                local keyboard = {}
                keyboard[1] = {}
                keyboard[2] = {}

                keyboard[1][1] = { text = "Minha postagem está certa", callback_data = "mfurro:review:"..userid..":"..reason} 
                keyboard[2][1] = { text = "Ok, entendi.", callback_data = "mfurro:sowwy"} 

                local keyboardkb = cjson.encode({inline_keyboard = keyboard })

                deploy_answerCallbackQuery(msg.id, "Warning!", "true")
                    
                local reasonMsg = mercadofurro.reasons[tonumber(reason)] or "<error>"

                local said = bot.sendMessage(mercadofurro.chat, "Atenção "..formatUserHtml(usr).." seu post foi excluido, fique atento as regras do grupo. Só são permitidos anuncios <b>que contenham o preço</b> e em <b>REAL</b> e em <b>português</b>.\n\n⚠️Motivo: <b>"..reasonMsg.."</b>\n\nAviso: "..tostring(mercadofurro.warnings[userid]), "HTML", nil, nil, nil, keyboardkb)
                scheduleEvent( 240, function(msg, said)
                    if said.ok then
                        bot.deleteMessage(said.result.chat.id, said.result.message_id)
                    end
                end, msg, said)
                SaveUser(userid)
                local hasPv = false
                if usr.private then
                    local res = bot.sendMessage(usr.private, "Atenção sua postagem no mercado furry foi excluida. Fique atento as regras do grupo. Só são permitidos anuncios que contenham o preço em <b>REAL</b> e em português.\n\n⚠️Motivo: <b>"..reasonMsg.."</b>\n\n\nAviso: "..tostring(mercadofurro.warnings[userid]), "HTML", nil, nil, nil, keyboardkb)
                    hasPv = res and res.ok
                end

                bot.sendMessage(mercadofurro.adminchat, "Ação tomada por "..formatUserHtml(msg).." quanto a "..formatUserHtml(usr)..'\nAvisos desse usuario: '..tostring(mercadofurro.warnings[userid])..'\n'..(hasPv and "Usuário avisado no privado com o bot" or ""), "HTML")
                
            elseif msg.data:match("mfurro:nope:(%d+):(%d+)") then
                local msgid, userid = msg.data:match("mfurro:nope:(%d+):(%d+)")
                userid = tonumber(userid)
                local usr = getUserById(userid)

                local res = mercadofurro.deleteMessagesFromGroup(tonumber(msgid))
                deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
                if not res then 
                    deploy_answerCallbackQuery(msg.id, "Mensagem ja foi excluida.", "true")
                    return
                end

                if not mercadofurro.warnings[userid] then 
                    mercadofurro.warnings[userid] = 0
                end
                mercadofurro.warnings[userid] = mercadofurro.warnings[userid] +1

                deploy_answerCallbackQuery(msg.id, "Warning!", "true")
                    
                local reasonMsg = mercadofurro.reasons[tonumber(reason)] or "<error>"

                local said = bot.sendMessage(mercadofurro.chat, "Atenção "..formatUserHtml(usr).." seu post foi excluido, fique atento as regras do grupo. Esse tipo de anuncio não é permitido.\nAviso "..tostring(mercadofurro.warnings[userid]), "HTML")
                scheduleEvent( 240, function(msg, said)
                    if said.ok then
                        local res = bot.deleteMessage(said.result.chat.id, said.result.message_id)
                        
                    end
                end, msg, said)
                SaveUser(userid)
                local hasPv = false
                if usr.private then
                    local res = bot.sendMessage(usr.private, "Atenção sua postagem no mercado furry foi excluida. Fique atento as regras do grupo. O tipo de anuncio enviado não é permitido", "HTML")
                    hasPv = res and res.ok
                end
                bot.sendMessage(mercadofurro.adminchat, "Ação tomada por "..formatUserHtml(msg).." quanto a "..formatUserHtml(usr)..'\nAvisos desse usuario: '..tostring(mercadofurro.warnings[userid])..'\n'..(hasPv and "Usuário avisado no privado com o bot" or ""), "HTML", nil, nil)
                
            elseif msg.data:match("mfurro:mute:(%d+):(%d+):(%d+)") then
                local msgid, userid, reason = msg.data:match("mfurro:mute:(%d+):(%d+):(%d+)")
                userid = tonumber(userid)
                local usr = getUserById(userid)

                local res = mercadofurro.deleteMessagesFromGroup(tonumber(msgid))
                deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
                if not res then 
                    deploy_answerCallbackQuery(msg.id, "Mensagem ja foi excluida.", "true")
                    return
                end

                mercadofurro.deleteMessagesFromGroup(msgid)

                if not mercadofurro.warnings[userid] then 
                    mercadofurro.warnings[userid] = 0
                end
                mercadofurro.warnings[userid] = mercadofurro.warnings[userid] +1
                bot.restrictChatMember(mercadofurro.chat, userid, os.time()+3600*24, false, false, false, false)
                bot.sendMessage(mercadofurro.adminchat, "Ação tomada (mute) por "..formatUserHtml(msg).." quanto a "..formatUserHtml(usr)..' sobre mensagem\nAvisos desse usuario: '..tostring(mercadofurro.warnings[userid]), "HTML", nil, nil)
                deploy_answerCallbackQuery(msg.id, "Warning!", "true")
                
                local reasonMsg = mercadofurro.reasons[tonumber(reason)] or "<error>"

                local keyboard = {}
                keyboard[1] = {}
                keyboard[2] = {}

                keyboard[1][1] = { text = "Minha postagem está certa", callback_data = "mfurro:review:"..userid..":"..reason} 
                keyboard[2][1] = { text = "Ok, entendi.", callback_data = "mfurro:sowwy"} 

                local keyboardkb = cjson.encode({inline_keyboard = keyboard })

                local said = bot.sendMessage(mercadofurro.chat, "Atenção "..formatUserHtml(usr).." seu post foi excluido, fique atento as regras do grupo. Só são permitidos anuncios que contenham o preço em <b>REAL</b> e em português.\n\n⚠️Motivo: <b>"..reasonMsg.."</b>\n\nVocê foi mutado por 24h", "HTML", nil, nil, nil, keyboardkb)
                scheduleEvent( 240, function(msg, said)
                    if said.ok then
                        bot.deleteMessage(said.result.chat.id, said.result.message_id)
                    end
                end, msg, said)
                SaveUser(userid)
                if usr.private then
                    bot.sendMessage(usr.private, "Atenção sua postagem no mercado furry foi excluida. Fique atento as regras do grupo. Só são permitidos anuncios que contenham o preço em <b>REAL</b> e em português.\n\n⚠️Motivo: <b>"..reasonMsg.."</b>\n\nVocê foi mutado por 24h", "HTML", nil, nil, nil, keyboardkb)
                end

            end


        end
    end 
end

function mercadofurro.relayMessagePanel(msg, reason, text)


    print("relay!")

    local keyboard = {}
    keyboard[1] = {}
    keyboard[2] = {}
    keyboard[3] = {}
    keyboard[4] = {}
    keyboard[5] = {}
    keyboard[6] = {}


    keyboard[1][1] = { text = "⚠️Dar aviso⚠️", callback_data = "mfurro:warn:"..msg.message_id..":"..msg.from.id..":"..reason} 
    keyboard[2][1] = { text = "❌Dar aviso e mute❌", callback_data = "mfurro:mute:"..msg.message_id..":"..msg.from.id..":"..reason} 
    keyboard[3][1] = { text = "🔞Aviso de postagem proibida🔞", callback_data = "mfurro:nope:"..msg.message_id..":"..msg.from.id} 
    keyboard[4][1] = { text = "💥💥BAAANN💥💥", callback_data = "mfurro:ban:"..msg.message_id..":"..msg.from.id} 
    keyboard[5][1] = { text = "🚽Apagar mensagem🚽", callback_data = "mfurro:del:"..msg.message_id..":"..msg.from.id..":"..reason} 
    keyboard[6][1] = { text = "✅Mensagem ok✅", callback_data = "mfurro:ok:"..mercadofurro.getMessageHash(msg)} 
    local keyboardkb = cjson.encode({inline_keyboard = keyboard })

    mercadofurro.warnings[msg.from.id] = mercadofurro.warnings[msg.from.id] or 0

    bot.sendMessage(mercadofurro.adminchat, "Mensagem ("..msg.message_id..") enviada por "..formatUserHtml(msg).." (Usuário com "..tostring(mercadofurro.warnings[msg.from.id]).." warnings) com <b>"..mercadofurro.reasons[reason]:htmlFix().."</b>  https://t.me/mercadofurry/"..msg.message_id..'\n\n\nTexto:\n<code>'..text:htmlFix()..'</code>', "HTML", nil, nil, nil, keyboardkb)
end

function mercadofurro.isInvalidMessage(msg)
    
    if not msg.chat then 
        return
    end

    for a,mg in pairs(mercadofurro.mediaGroups) do 
        if mg.expire < os.time() then 
            mercadofurro.mediaGroups[a] = nil 
            break
        end
    end

    if  msg.chat.id == mercadofurro.chat  then --or msg.chat.id == 5146565303
        --if msg.chat.id == mercadofurro.chat then 
        local isMainMessage = true
        if msg.media_group_id then 
            if not mercadofurro.mediaGroups[msg.media_group_id] then 
                mercadofurro.mediaGroups[msg.media_group_id] = {
                    expire = os.time()+3600 * 12,
                    messages={msg},
                    core_message=msg.message_id
                }

                scheduleEvent( 8, function(media_group_id)
                    for __, imsg in pairs(mercadofurro.mediaGroups[media_group_id].messages) do  
                        local text = msg.text or msg.caption or msg.description
                        if text ~= nil then
                            mercadofurro.mediaGroups[media_group_id].core_message=imsg.message_id
                            mercadofurro.checkMessageProcedure(imsg)
                            break
                        end
                    end
                end, msg.media_group_id)
            else 
                mercadofurro.mediaGroups[msg.media_group_id].messages[#mercadofurro.mediaGroups[msg.media_group_id].messages+1]=msg
            end
            return
        end
      
        return mercadofurro.checkMessageProcedure(msg)

    end

    return false
end


function mercadofurro.getMessageHash(msg)
    local text = msg.text or msg.caption or msg.description

    text = text or '-'

    local photoId = ""

    if msg.photo and msg.photo[1] then
        photoId = msg.photo[1].file_unique_id
    end

    if msg.document and msg.document.file_unique_id then
        photoId = msg.document.file_unique_id
    end

    local hashId = text:lower()..":"..msg.from.id .. ":" ..photoId

    return ngx.md5(hashId)
end

function mercadofurro.checkMessageProcedure(msg)
   local text = msg.text or msg.caption or msg.description

        if not text then 
            return mercadofurro.relayMessagePanel(msg, 1, '<mensagem sem texto>')
        end

        if not text then 
            return
        end


        local lang, langErr = nil

        text = text:lower()

        local hash = mercadofurro.getMessageHash(msg)
        if mercadofurro.validHashes[hash] == true and hash ~= mercadofurro.notextMd5 then 
            return
        end

        if not mercadofurro.hasPrice(text) then 
            lang, langErr = mercadofurro.isPortuguese(text)
            if not lang then 
                return mercadofurro.relayMessagePanel(msg, 2, text)
            end
            return mercadofurro.relayMessagePanel(msg, 3, text)
        end


        if not mercadofurro.isReal(text) then 

            lang, langErr = mercadofurro.isPortuguese(text)

            if not (lang and text:match("pix")) then 
                return mercadofurro.relayMessagePanel(msg, 4, text)
            end

            
        end

        if lang == nil then 
            lang, langErr = mercadofurro.isPortuguese(text)
        end

        if not lang then 

            return mercadofurro.relayMessagePanel(msg, 5, text)
        end
    return false
end

function mercadofurro.onDocumentReceive(msg, action)
	if not mercadofurro.check_media(msg) then 
		return KILL_EXECUTION
	end
    mercadofurro.isInvalidMessage(msg)
end


function mercadofurro.onTextReceive(msg, action)
    mercadofurro.isInvalidMessage(msg)
end

function mercadofurro.onVideoReceive(msg, action)
    if not mercadofurro.check_media(msg) then 
        return KILL_EXECUTION
    end
    mercadofurro.isInvalidMessage(msg)
end

function mercadofurro.onPhotoReceive(msg, action)
	if not mercadofurro.check_media(msg) then 
		return KILL_EXECUTION
	end
    mercadofurro.isInvalidMessage(msg)
end

function mercadofurro.onAudioReceive(msg, action)
	if not mercadofurro.check_media(msg) then 
		return KILL_EXECUTION
	end
    mercadofurro.isInvalidMessage(msg)
end

function mercadofurro.onStickerReceive(msg, action)
    if not mercadofurro.check_media(msg) then 
        return KILL_EXECUTION
    end
    mercadofurro.isInvalidMessage(msg)
end


return mercadofurro