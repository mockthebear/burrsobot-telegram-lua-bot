local notifyme = {

    g_lastPvt = {}
}

--[ONCE] runs when the load is finished
function notifyme.load()

end

function notifyme.notifyWord(user, msg, word)
    if msg.from.id == id then 
        return true
    end
    if users[user] then 
        if users[user].private then 
            print("Notifying -> "..user.."="..word)
            local append = ""
            if msg.chat.username then 
                append = '\n\n<a href="https://t.me/'..msg.chat.username..'/'..msg.message_id..'">[Go to message]</a>'
            else 
                local str = tostring(msg.chat.id)
                if str:match("%-100(%d+)") then
                    local cid = str:match("%-100(%d+)")
                    append = '\n\n<a href="https://t.me/c/'..cid..'/'..msg.message_id..'">[Go to message]</a>'
                end
            end
            bot.sendMessage(user, tr("Keyword <code>"..word:htmlFix().."</code> were said in chat <b>"..(msg.chat.title:htmlFix() or "??").."</b> by "..formatUserHtml(msg)..".")..append , "HTML")
            bot.forwardMessage(user , msg.chat.id, false, msg.message_id)
            return true
        end 
    end
    return false
end

function notifyme.onTextReceive(msg)
    if msg.chat and not chats[msg.chat.id] then 
        return
    end
    local hasWarn = {}
    if chats[msg.chat.id].data.warnWords then 
        hasWarn = chats[msg.chat.id].data.warnWords
    end
    local notified = {}

    local kek = msg.text
    kek = kek .. " "
    kek = kek:gsub(",","")
    kek = kek:gsub("%.","")
    kek = kek:gsub("!","")
    kek = kek:gsub("%?","")
    kek = kek:gsub("%*","")
    kek = kek:gsub(";","")
    kek = kek:gsub("\"","")
    kek = kek:gsub("'","")
    kek = kek:lower()

    for word in kek:gmatch("(.-)%s") do 
        if hasWarn and hasWarn[word] then 
            local userList = hasWarn[word]
            local nonAuth = ""
            for user, i in pairs(userList) do 
            
                if user ~= msg.from.id and not notified[user] and users[msg.from.id] then 
                    notified[user] = true
                    if not notifyme.g_lastPvt[user] or notifyme.g_lastPvt[user] <= os.time() then
                        if i then
                            if not notifyme.notifyWord(msg.from.id, msg, word) then
                                nonAuth = nonAuth .."@"..user.."\n"
                            end
                        end
                        notifyme.g_lastPvt[user] = os.time() + (users[msg.from.id].notifyInterval or 60)
                    end
                end
            end
        end
    end
end


function notifyme.loadTranslation()
    g_locale[LANG_US]["Autorizar o bot mandar private"] = "Authorize bot send private message"
    g_locale[LANG_US]["\nKeyword `%s` foi(foram) mencionado(a). Não estou autorizado a mandar private message a você(s). Por favor autorize."] = "\nKeyword `%s` was mentioned. Im not allowed to send a private message to you. Please authorize."    


    --/notifypurge
    g_locale[LANG_US]["Você não tem nem uma keyword de aviso."] = "You dont have any keywords."
    g_locale[LANG_US]["Removido aviso das seguintes palavras:\n"] = "Removed the following keywords:\n"
    g_locale[LANG_US]["Limpa a lista de avisos sua."] = "Clear all of your notification keywords."
    --/notifyme
    g_locale[LANG_US]["Por favor, use o comando assim:  /notifyme (keyword com pelo menos 3 letras)"] = "Please use the command like this: /notifyme (keyword with at least 3 letters)"
    g_locale[LANG_US]["Removido @%s na lista de notificação.\n"] = "Removed @%s from the notification list.\n"
    g_locale[LANG_US]["Adicionado @%s na lista de notificação.\n"] = "Added @%s on the notification list.\n"
    g_locale[LANG_US]["\nÉ bom lembrar que existem outros 2 comandos:\n*/notifypurge , um para remover tudo\n */notifyinterval para definir intervalo minimo de avisos\n\n"] = "\nPlease note there are two other commands:\n*/notifypurge to remove all notification keywords\n*/notifyinterval to set up a interval between each notification\n\n"
    g_locale[LANG_US]["Autorizar o bot mandar private"] = "Authorize me to send you pms.\n"
    g_locale[LANG_US]["\nParece que você não autorizou ainda eu mandar privates pra você. Basta ir no private comigo e dar /start ou clicar no botão abaixo\n"] = "\nIt seems you have not authorized me to send you pms. Just go on private with me and do a /start or press the button above\n"
    g_locale[LANG_US]["Define palavras chaves para o bot te avisar quando forem mencionadas no chat."] = "Define keywords to the bot notify you when those be mentioned on the chat."
    --/notifyinterval
end


function notifyme.loadCommands()
    LoadCommand(nil, "notifyme", MODE_FREE, getModulePath().."/notifycommand.lua", 1,"Set up to the bot warn you when a given word were spoken" )
    LoadCommand(nil, "notifypurge", MODE_FREE, getModulePath().."/notifypurge.lua", 1, "Limpa a lista de avisos sua." )
    LoadCommand(nil, "notifyinterval", MODE_FREE, getModulePath().."/notifyinterval.lua", 1, "Define um intervalo entre avisos" )
end


return notifyme