function formatChatMessage(msg)

    if not msg.chat then 
        return false
    end
    local chatObj = chats[msg.chat.id]

    chatObj.id = msg.chat.id
    chatObj.title = msg.chat.title
    chatObj.type = msg.chat.type
    chatObj.invite_link = msg.chat.invite_link
    local prev = chatObj.last_message
    chatObj.last_message = os.time()


    g_lang = getUserLang(msg) 
    
    msg.isChat = true

    if not chatObj._tmp.users[msg.from.id] then 
        chatObj._tmp.users[msg.from.id] = msg.from
    end

    chatObj.data.message_count = (chatObj.data.message_count or 0)+1

    checkChatStats(chatObj)

    if not prev or prev+3600 < os.time() then 
        SaveChat(msg.chat.id)
    end

    checkCacheChatAdmins(msg)
end

function checkChatStats(chatObj)
    if not chatObj.data.member_count or  (chatObj.data.auto_update or 0) <= os.time() then
        local cc = bot.getChatMembersCount(chatObj.id)
        if cc.ok then 
            chatObj.data.member_count = cc.result
        else 
            chatObj.data.member_count = 1
        end
        chatObj.data.auto_update = os.time() + 60*2
        SaveChat(chatObj.id)
    end
end

function listOldChats(diff)
    local res = {}
    for id, chatObj in pairs(chats) do 
        if not chatObj.last_message or chatObj.last_message + diff < os.time() then 
            res[#res+1] = chatObj
        end
    end
    return res
end



function checkCacheChatAdmins(msg, chatOverride)
    if msg.chat.type ~= "private" then
        local chatObj = chats[chatOverride or msg.chat.id]
        if chatObj and ((chatObj._tmp.adms_cache or 0 ) <= os.time()) then
            cacheAdministrators({chat={id=chatOverride or  msg.chat.id}})
        end
        SaveChat(msg.chat.id)
    end
end

function cacheAdministrators(msgs)
    local chatid = msgs.chat.id
    local basechatInfo = bot.getChat(chatid)
    local adms = bot.getChatAdministrators(chatid)

    local chatobj = chats[chatid]
    if adms and adms.ok then
        chatobj._tmp.adms = {}
        for i,b in pairs(adms.result) do 
            chatobj._tmp.adms[b.user.id] = true
        end
        chatobj._tmp.adms_cache = os.time() + 3600
    end
    if basechatInfo.ok then
        chatobj.invite_link = basechatInfo.result.invite_link
        chatobj.title = basechatInfo.result.title
        chatobj.description = basechatInfo.result.description
        chatobj.linked_chat_id = basechatInfo.result.linked_chat_id
    end
end

function emptyTMP()
    return { adms={}, users={}, checking = {}, newUser = {}, spam={}}
end

function CheckChat(msg)

    local isNewChat = false
	if msg.chat.type == "group" or msg.chat.type == "supergroup" then 
        if not chats[msg.chat.id] then
        
            local newChat = {
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

            local basechatInfo = bot.getChat(newChat.id)
            if basechatInfo.ok then
                newChat.invite_link = basechatInfo.result.invite_link
                newChat.title = basechatInfo.result.title
                newChat.description = basechatInfo.result.description
                newChat.linked_chat_id = basechatInfo.result.linked_chat_id
            end

            chats[msg.chat.id] = newChat

            if not onNewChat(newChat.id, msg) then 
                chats[newChat.id] = nil
                return false, "no chat allowed"
            else 
                isNewChat = true
            end

            SaveChat(id)
        end
        checkUsername(msg.chat, "chat", msg.chat.username)

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
            if i ~= "_tmp" and i ~= "_type" then
                g_redis:hset(chatKey, i, formatToJson(b)) 
            end     
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
            if chatObj.last_message then
                g_redis:hset(rootKey, "last_message", formatToJson(chatObj.last_message))
            end
            if chatObj.last_message then
                g_redis:hset(rootKey, "linked_chat_id", formatToJson(chatObj.linked_chat_id))
            end
            if chatObj.last_message then
                g_redis:hset(rootKey, "description", formatToJson(chatObj.description))
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
        chatObject._tmp.type = "chat"
        chatObject.data = {}

        for i,b in pairs(chatData) do 
            chatObject.data[i] = unformatFromJson(b) 
        end


        local mt = {__newindex = function(org, field, val)
            if field ~= "title" and field ~= "id" and field ~= "type" and field ~= "invite_link"  and field ~= "username" and field ~= "description" and field ~= "linked_chat_id" and field ~= "last_message" then
                error("Trying to set a var in protected region. Use _tmp for temporary or data to permanent> "..field)
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