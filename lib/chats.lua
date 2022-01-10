function formatChatMessage(msg)

    if not msg.chat then 
        return false
    end
    local chatObj = chats[msg.chat.id]

    chatObj.id = msg.chat.id
    chatObj.title = msg.chat.title
    chatObj.type = msg.chat.type
    chatObj.invite_link = msg.chat.invite_link
    chatObj.username = msg.chat.username



        
    g_lang = getUserLang(msg) 
    
    msg.isChat = true

    if not chatObj._tmp.users[msg.from.id] then 
        chatObj._tmp.users[msg.from.id] = msg.from
    end

    if not chatObj.data.mc or (not chatObj.data.countcd2 or chatObj.data.countcd2 <= os.time()) then
        local cc = bot.getChatMembersCount(msg.chat.id)
        if cc.ok then 
            chatObj.data.mc = cc.result
        else 
            chatObj.data.mc = 1
        end
        chatObj.data.countcd2 = os.time() + 20 * 60
    end

    if ((chatObj._tmp.adms_cache or 0 ) <= os.time()) then
        cacheAdministrators(msg)
    end
end

function  checkCacheChatAdmins(msg)
    local chatObj = chats[msg.chat.id]
    if ((chatObj._tmp.adms_cache or 0 ) <= os.time()) then
        cacheAdministrators(msg)
    end
end

function cacheAdministrators(msgs)
    local adms = bot.getChatAdministrators(msgs.chat.id)
    if adms and adms.ok then
        chats[msgs.chat.id]._tmp.adms = {}
        for i,b in pairs(adms.result) do 
            chats[msgs.chat.id]._tmp.adms[b.user.id] = true
        end
        chats[msgs.chat.id]._tmp.adms_cache = os.time() + 3600
    end
end

function emptyTMP()
    return { adms={}, users={}, checking = {}, newUser = {}, spam={}}
end

function CheckChat(msg)

    local isNewChat = false
	if msg.chat.type == "group" or msg.chat.type == "supergroup" then 
        if not chats[msg.chat.id] then
            chats[msg.chat.id] = {
                name = msg.chat.title, 
                title=msg.chat.title, 
                id=msg.chat.id, 
                type=msg.chat.type, 
                data = {
                    sfw=true, 
                    lang=detectLanguage(msg)
                },  
                 _tmp=emptyTMP()
            }
            if not onNewChat(msg.chat.id, msg) then 
                chats[msg.chat.id] = nil
                return false, "no chat allowed"
            else 
                isNewChat = true
            end
            SaveChat(id)
        end
        formatChatMessage(msg)
    end

    return true
end	

function onNewChat(id, msg)

    if not runModulesMethod(msg, "onNewChat", id) then 
        return false
    end

    return true
end


function SaveChat( chatid )


    if chats[chatid] then
        local chatObj = chats[chatid] 
        local chatKey = "chat:data:"..chatid 
        local rootKey = "chat:"..chatid 

        g_redis:rename(rootKey, rootKey..".old")
        g_redis:rename(chatKey, chatKey..".old")

        for i,b in pairs(chatObj.data) do 
            g_redis:hset(chatKey, i, formatToJson(b))      
        end
        if chatObj.title then
            g_redis:hset(rootKey, "title", formatToJson(chatObj.title))
            g_redis:hset(rootKey, "type", formatToJson(chatObj.type))
            g_redis:hset(rootKey, "id", formatToJson(chatObj.id))
            if chatObj.invite_link then
                g_redis:hset(rootKey, "invite_link", formatToJson(chatObj.invite_link))
            end
            if chatObj.username then
                g_redis:hset(rootKey, "username", formatToJson(chatObj.username))
            end
        end


        g_redis:del(rootKey..".old")
        g_redis:del(chatKey..".old")
        return true
    else
        print("Error. No chat ",chatid)
        return false
    end

    --g_pubsub.updateChat(id) 
end

function checkBotInChats()
    g_startup = os.time()-15
    say.admin("Checking chats")
    for id,b in pairs(chats) do 
        local title = b.title or b.name
        if checkBotInChat(id) then 
            print("Ok for: "..b.title)
            --say.admin("Ok for: "..b.title)
        end
    end
end

function checkBotInChat(chatid)
    if not chats[chatid] then 
        deleteChat(chatid)
        return false
    end
    local chat = bot.getChat(chatid)
    if chat then 
        if chat.ok == false then 
            if chat.description:find("Too Many") then 
                print("Waiting~ "..chat.description)
                ngx.sleep(30)
                return checkBotInChat(chatid)
            end
            say.admin("Bot is not in the chat "..chatid.." - "..tostring(chats[chatid].title).." due to "..chat.description )
            --deleteChat(chatid)
            return false
        else 
            chats[chatid].id = chat.result.id
            chats[chatid].title = chat.result.title
            chats[chatid].type = chat.result.type
            chats[chatid].invite_link = chat.result.invite_link or ""
            chats[chatid].username = chat.result.username or ""

            SaveChat(chatid)
        end
    end
    return true
end


function migrateChat(tochat, from_chat_id)
    local oldElement = chats[from_chat_id]
    if not oldElement then 
        say.admin("Failed to migrate?")
        return
    end
    chats[from_chat_id] = nil

    chats[tochat.id] = oldElement


    local chatKey = "chat:"..from_chat_id
    local dataKey = "chat:data:"..from_chat_id

    local chatKeyNew = "chat:"..tochat.id
    local dataKeyNew = "chat:data:"..tochat.id

    chats[tochat.id].id = tochat.id
    chats[tochat.id].title = tochat.title
    chats[tochat.id].type = tochat.type

    g_redis:rename(chatKey, chatKeyNew)
    g_redis:rename(dataKey, dataKeyNew)

    say.admin("Chat migrated from "..from_chat_id.." to "..tochat.id)
    SaveChat(tochat.id)
end

function deleteChat(chatid)
    local resp = bot.leaveChat(chatid)
    local left = resp.result or false

    chats[chatid] = nil
    local chatKey = "chat:"..chatid
    local dataKey = "chat:data:"..chatid

    g_redis:rename(chatKey, chatKey..".deleted")
    g_redis:rename(dataKey, dataKey..".deleted")

    return left, resp.description
end



function loadChat(chatid) 
    local chatKey = "chat:"..chatid
    local dataKey = "chat:data:"..chatid
    local mainRes = g_redis:hgetall(chatKey)
    local dataRes = g_redis:hgetall(dataKey)

    if mainRes and dataRes then
        local chatObject = {}
        local chatMain = table.arraytohash(mainRes) 
        local chatData = table.arraytohash(dataRes) 

        for i,b in pairs(chatMain) do 
            chatObject[i] = unformatFromJson(b) 
        end
        chatObject._tmp=emptyTMP()
        chatObject.data = {}

        for i,b in pairs(chatData) do 
            chatObject.data[i] = unformatFromJson(b) 
        end


        local mt = {__newindex = function(org, field, val)
            if field ~= "title" and field ~= "id" and field ~= "type" and field ~= "invite_link"  and field ~= "username" then
                error("Trying to set a var in protected region. Use _tmp for temporary or data to permanent")
            else
                rawset(org,field,val)
            end
        end}

        chats[chatid] = setmetatable(chatObject, mt)
    else 
        erro("Error returning key: "..chatKey.. " or "..dataKey)
    end
end

function loadChats()
    local counter = 0
    local chatKeys = g_redis:keys("chat:*")
    for _, key in pairs(chatKeys) do 
        if key:match("chat:([%-%d+]+)$") then 
            local chatid = tonumber(key:match("chat:([%-%d+]+)$"))
            if not chatid then 
                error("Invalid id in "..key)
            end
            loadChat(chatid) 
            counter = counter +1
            
        end 
    end
    print("Loaded "..counter.." chats")
end