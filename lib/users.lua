--[[
local storedUsers = {['a']=123}
local aux = {
    __index = function(my, field ) 
        local usr = rawget(my, field)
        if not usr then 
            local s = loadUser(id, username)
            --storedUsers[field.."USR"] = 321
            --storedUsers[field] = 555
            usr = 123
            rawset(my, field, usr)
        end
        return usr
    end,

    
}
setmetatable(users, aux)]]


function getUserById(id)
    if not users[id] then 
        local usr = loadUser(id, username)
        return usr
    end
    return users[id]
end

function getUserByUsername(uname)
    uname = uname:lower()
    if uname:sub(1,1) == "@" then 
        uname = uname:sub(2, -1)
    end
    if not users[uname] then 
        local usr = loadUser(nil, uname)
        return usr
    end
    return users[uname]
end


function getTargetUser(msg, needTarget, global)
    local tgtStr 
    if msg.text:sub(1,1) == "/" then 
        if msg.text:match("/.-%s([^%s]+)") then 
            tgtStr = msg.text:match("/.-%s([^%s]+)")
        end
    end

    if tgtStr and tgtStr:len() > 1 then 
        tgtStr = tgtStr:gsub("@",""):lower()
        local usr = getUserByUsername(tgtStr)
        if not usr or not (usr.telegramid or usr.id) then 
            print("No user from "..tgtStr)
            if tonumber(tgtStr) and users[tonumber(tgtStr)] and users[tonumber(tgtStr)].id then 
                usr = users[tonumber(tgtStr)]
                print("from id? "..tgtStr)
            end
        end
        if not usr then 
            print("NAN")
            return nil, tgtStr
        else 
            if global then
                return usr
            else
                local res = bot.getChatMember(msg.chat.id, usr.telegramid or usr.id)
                if not res.ok or ( (res.result.status == "left" or res.result.status == "kicked")) then 
                    print("NAAN")
                    return nil, tgtStr
                end
                return res.result.user
            end
        end
    else 
        if msg.reply_to_message and msg.reply_to_message.from and msg.reply_to_message.from  ~= "burrsobot"  then 
            --Load user
            getUserById(msg.reply_to_message.from.id)
            return msg.reply_to_message.from
        else 
            if needTarget then
                return nil
            end
            return msg.from
        end
    end
end
 


function loadUser(id, username)
    
    local found = false    
    local counter = 0
    local updateUsername = ""
    local obj = nil
    local ret 
    if id then
        local ret = db.getResult("SELECT * FROM `users` WHERE tid="..id.." LIMIT 1;")
        if ret:getID() ~= -1 and ret:getID() ~= nil then

            local dat = ret:getDataString('data')
            counter = counter +1
            local unse = unserialize(dat)
            if unse then
               local setUsername = username
                --print("From 1 ->"..tostring(username).." -> "..ret:getDataString('username'):lower())
                if ret:getDataString('username'):lower() ~= username then 
                    setUsername = username or ret:getDataString('username'):lower()
                    unse.username = setUsername
                    print("Mismatched username! DB="..ret:getDataString('username'):lower().." observed="..tostring(username)) 
                end

                if not unse.username then 
                    unse.username = setUsername
                end
                unse._tmp = {}
                users[setUsername] = unse
                users[id] = unse
                obj = users[id]

                for i,b in pairs(obj) do
                    g_redis:hset("user:"..id, i, tostring(b))
                end

                found = true
            else 
                print("Failed to parse~")
            end
            ret:free()
            if updateUsername:len() > 0 then 
                db.executeQuery("UPDATE `users` SET `username` = '"..db.escapeString(setUsername).."' WHERE tid="..id.." LIMIT 1;")
            end
        end
    end

    if not found then
        ret = db.getResult("SELECT * FROM `users` WHERE `username` = '"..db.escapeString(username).."' LIMIT 1;")
        if ret:getID() ~= -1 and ret:getID() ~= nil then
            local dat = ret:getDataString('data')
            counter = counter +1
            local unse = unserialize(dat)
            --print("From 2 ->" ..username)
            if unse then
                
                local targetId = ret:getDataInt('tid')
                ret:free()

                if id and targetId ~= id then 
                    say.admin("Mismatched id: ".. ret:getDataInt('tid').." ~= "..id.. " upon "..username)
                    db.executeQuery("DELETE FROM `users` WHERE `tid` = '"..id.."';")
                    db.executeQuery("UPDATE `users` SET tid="..id.." WHERE `username` = '"..db.escapeString(username).."';")
                    targetId = id
                end

                --print("Assigned as: "..username.." = ".. targetId)

                unse.telegramid = targetId 
                users[username] = unse
                users[targetId] = unse
                if not users[targetId].id then 
                    users[targetId].id = targetId
                    users[targetId].first_name = username
                end
 

                if not unse.username then 
                    unse.username = username
                end

                obj = users[targetId]

                for i,b in pairs(obj) do
                    g_redis:hset("user:"..targetId, i, tostring(b))
                end
            end
            
            ret:free()
        end     
    end
    return obj
end

function isUserChatAdmin(chat, id)
    if type(chat) == "table" then 
        id = chat.from.id
        chat = chat.chat.id
    end
    if chats[chat] then 
        if #chats[chat]._tmp.adms == 0 or ((chats[chat]._tmp.adms_cache or 0 ) <= os.time()) then
            cacheAdministrators({chat={id=chat}})
        end
        for i,b in pairs(chats[chat]._tmp.adms) do 
            if i == id or b == id then 
                return true
            end
        end
    else 
        return false
    end
end

function isUserBotAdmin(id)
    for i,b in pairs(admins) do 
        if i == id or b == id then 
            return true
        end
    end    
    return false    
end


function CheckUser(msg, isNew)
    if not msg.from then 
        return true
    end
    if not msg.from.username then 
        return true
    end

    msg.from.username = msg.from.username:lower()

    
    
    local loded = nil
    --Load user~
    if not users[msg.from.id] or not users[msg.from.username] then 
        local newUser = true
        loded = loadUser(msg.from.id, msg.from.username)
        if not loded then
            print("New user: ",msg.from.username .. ":"..msg.from.id) 
            users[msg.from.username] = {telegramid = msg.from.id, first_name=msg.from.first_name, username=msg.from.username, joinDate={}}
            users[msg.from.id] = users[msg.from.username]
            
            if msg.chat and chats[msg.chat.id] then
                chats[msg.chat.id]._tmp.newUser[msg.from.username] = isNew
            end

            db.executeQuery("INSERT INTO `users` (`id`, `username`, `data`, `tid`, `last_seen`) VALUES (NULL, '"..db.escapeString(msg.from.username:lower()).."', '', '"..msg.from.id.."', "..os.time()..");")
                
            if isNew then
                local ret, res = checkUserSafe(msg.chat.id, msg.from.id)
                if not ret then --or msg.from.username ~= msg.from.username2 or chats[msg.chat.id].data.botEnforced
                    --say.admin("New user "..msg.from.username.." with unsafe = "..res)
                    users[msg.from.id].unsafe = res
                end
            end
        else 
            --print("Loaded user: "..msg.from.username)
        end
    end

    local userObj = users[msg.from.id]

    if type(userObj.joinDate) ~= 'table' then 
        userObj.joinDate = {}

    end

    if msg.chat then
        --If the user is sending a private message, we store that he sent us a private and set the language~
        if msg.chat.type == "private" then 
            g_lang = tonumber(userObj.lang) or LANG_BR
            if not userObj.private then 
                userObj.private = msg.chat.id
            end
        end



        
        if msg.isChat then

            if not userObj.joinDate[msg.chat.id] then 

                userObj.joinDate[msg.chat.id] = tonumber(msg.date) --todo adjust this sheet.
                print(msg.from.first_name.." joins chat "..msg.chat.title.." at "..msg.date) 
                SaveUser(msg.from.id)
            end
        end
    end

    userObj.id = msg.from.id
    userObj.last_name = msg.from.last_name
    userObj.language_code = msg.from.language_code

    if userObj.first_name~=msg.from.first_name then 
        userObj.first_name = msg.from.first_name:gsub("[#@\"]", "")
        SaveUser(msg.from.id)
    end

    return true
end




function SaveUser(id)
    if not id then 
        return false
    end

    if type(id) == "string" then
        id = id:lower()
    end
    if tonumber(id) then 
        id = tonumber(id)
    end

    if users[id] then 

        uname = users[id].username or uname


        if not users[id].telegramid then 
            if type(id) == "number" then
                users[id].telegramid = id
            else
                say.admin("Error saving unknow1 "..id..":"..debug.traceback())
            end
        end
        
        local dat = serialize(users[id])
        local res, err, erra = db.executeQuery("UPDATE `users` SET `username` = '"..db.escapeString(uname).."', `data`='"..db.escapeString(dat).."', `last_seen`='"..os.time().."' WHERE `tid` = '"..users[id].telegramid.."'") 
        if (res == 0) then
            db.executeQuery("INSERT INTO `users` (`id`, `username`, `data`, `tid`) VALUES (NULL, '"..db.escapeString(uname:lower()).."', '"..db.escapeString(dat).."', '"..users[id].telegramid.."');")
            say.admin("Error saving users "..uname.." here its data:"..debug.traceback().."\n\n"..dat)
            say.admin("Saving error describe as: "..tostring(err).." = "..tostring(erra))
            logText("users", os.time().."\t"..uname.." "..users[id].telegramid.." "..dat)
            return false
        end
        return true
    else 
        say.admin("Error saving unknow "..id..":"..debug.traceback()) 
    end
    return false
 
end

function checkUserSafe(chat, id)
    local data = bot.getChatMember(chat, id)
    if data and data.ok then 
        if not data.result.user.username then 
            return false, "estar sem username"
        end
    end
    local res = bot.getUserProfilePhotos(id,0, 1)
    if res and res.ok then 
        if not res.result or not res.result.photos[1] then 
            return false, "estar sem foto de perfil"
        end
    else 
        return false, "estar sem foto de perfil"
    end
    return true
end
