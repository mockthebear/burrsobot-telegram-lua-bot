
say = { }

metaSay = { }
setmetatable( say, metaSay )

metaSay.__call  = function( myself, text, format, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup )
    assert(text, "missing text")
	if g_chatid then 
        local ret = nil 
        repeat
            ret = bot.sendMessage(g_chatid, text, format or g_sayMode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)
            if ret and ret.ok then 
                logMessage(ret.result, "say")
            else 
            	if ret and ret.description:find("Bad Request") then
                	say.admin("Failed to send msg ("..text:sub(1, 100)..") because: "..ret.description.. " at "..g_chatid, nil, "Error")
                end
            end
        until ret
        return includeUpdate(ret)      
    end
    return false
end


function say.error(text)
    local admStr = ""
    local one = nil
    for i,b in pairs(admins) do 
        one = i
        if users[i] then 
            admStr = '<a href="tg://user?id='..i..'">'..users[i].first_name:htmlFix()..'</a>'
        end
    end

    if admStr == "" then 
        if one then
            admStr = '<a href="tg://user?id='..one:htmlFix()..'">BOT ADMIN</a>'
        else 
            admStr = "BOT ADMIN"
        end
    end
    say.html(tr("Error, please notify %s about it and will be fixed as soon as possible:\n", admStr)..text:htmlFix())
    say.admin("ERROR: "..text.."\n\n"..Dump(g_msg or {}))
end

function say.delete( m, t, mk )
    g_sayMode = mk 
    local ms = say(m)    
    scheduleEvent( t or 120, function(ms)
        if ms.ok then
            bot.deleteMessage(ms.result.chat.id,ms.result.message_id)
        end
    end, ms)
    g_sayMode = nil
end

function say.admin(text, format, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)
    --for i, admId in pairs(admins) do 
        print("INFO: "..text)
        bot.sendMessage(81891406, "Info: "..text, format, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)
    --end
end


function say.common( ... )
    g_sayMode = ""
    local r = say(...)
    g_sayMode = nil 
    return r
end

function say.html( ... )
    g_sayMode = "HTML"
    local r = say(...)
    g_sayMode = nil 
    return r
end

function say.markdown( ... )
    g_sayMode = "Markdown"
    local r = say(...)
    g_sayMode = nil 
    return r
end

function say.parallel(...) 
    if g_chatid then 
        local arg = {...}
        if #arg > 1 then 
            local str = "["..#arg.."]: "
            for i,b in pairs(arg) do
                str = str..tostring(b)..',  '


            end
            if (#arg > 0) then
                str = str:sub(1,#str-3)
            end

            str = tostring(str)
            deploy_sendMessage(g_chatid,str, g_sayMode)

        else
            arg[1] = tostring(arg[1])
            ret = deploy_sendMessage(g_chatid, arg[1], g_sayMode)
        end 
    end
end

function say.big(msg, ...)
    local maxS = 2048
    while msg:len() > maxS do 
        local susub = msg:sub(1, maxS-1)
        say(susub, ...)
        msg = msg:sub(maxS, #msg)
    end
    if msg:len() > 0 then 
        say(msg, ...)
    end
end


function say.big_mono(msg, ...)
    local maxS = 2048
    while msg:len() > maxS do 
        local susub = msg:sub(1, maxS-1)
        say.html("<code>"..susub:htmlFix().."</code>", ...)
        msg = msg:sub(maxS, #msg)
    end
    if msg:len() > 0 then 
        say.html("<code>"..msg:htmlFix().."</code>", ...)
    end
end

function say.fancy(str)
     local dur = math.random(1,8)
    if str:len() < 10 then 
        dur =  math.min(dur, 3)
    elseif str:len() < 20 then 
        dur =  math.min(dur, 4)
    elseif str:len() < 30 then 
        dur =  math.min(dur, 5)
    elseif str:len() < 40 then 
        dur =  math.min(dur, 6)
    elseif str:len() < 50 then 
        dur =  math.min(dur, 7)
    end
    scheduleEvent(dur, function(a)
        g_chatid = a
        say(str)
    end, g_chatid)  
    bot.sendChatAction(g_chatid, "typing")
end



reply = { }

metaReply = { }
setmetatable( reply, metaReply )

metaReply.__call  = function( myself, ... )
    if g_chatid then 
        local arg = {...}
        if #arg > 1 then
            local str = "["..#arg.."]: "
            for i,b in pairs(arg) do
                str = str..tostring(b)..',  '
            end
            if (#arg > 0) then
                str = str:sub(1,#str-3)
            end

            local ret = nil 

            repeat
                str = tostring(str)
                ret = bot.sendMessage(g_chatid,str, g_sayMode,true,false,g_msg.message_id)
                if ret and  ret.ok then 
                    --print("Reply to "..g_msg.message_id.." ["..(  ( ( chats[g_chatid]) and chats[g_chatid].name or "???"  )  or "???" ).."] "..g_botname..": "..str)
                    logMessage(ret.result, "reply")
                else 
                    print("Failed to send rep", tostring(ret))
                    if ret and ret.description:find("Bad Request") then
                    	say.admin("Failed to send msg ("..arg[1]..") because: "..ret.description.. " at "..g_chatid)
                    end
                end
            until ret
            return includeUpdate(ret)  
        else
            local ret = nil 
            repeat
                arg[1] = tostring(arg[1])
                ret = bot.sendMessage(g_chatid,arg[1], g_sayMode,true,false,g_msg.message_id)
                if ret and ret.ok then 
                    --print("Reply "..g_msg.message_id.." ["..(  ( ( chats[g_chatid]) and chats[g_chatid].name or "???"  )  or "???" ).."] "..g_botname..": "..arg[1])
                    logMessage(ret.result, "reply")
        
        		else    
        			if ret and ret.description:find("Bad Request") then
                    	say.admin("Failed to send msg ("..arg[1]..") because: "..ret.description.. " at "..g_chatid)
                    end
                    print("Failed to send rep", tostring(ret))
                end
            until ret
            return includeUpdate(ret) 
        end 
        
    end
end

function includeUpdate(msg)
    if msg then 
        msg.update = {}
        local metaUpdate = {}
        setmetatable( msg.update , metaUpdate )
        metaUpdate.__index = function(  )
            return nil
        end
        metaUpdate.__call  = function( myself, text, parse, web, markup )
            updateMessage(msg, text, parse, web, markup )
        end
    end
    return msg
end

function updateMessage(msg, text, parse, web, markup )
    bot.editMessageText(msg.result.chat.id, msg.result.message_id, nil, text, parse, web, markup)
end



function reply.common( ... )
    g_sayMode = nil 
    local r = reply(...)

    return r
end

function reply.markdown( ... )
    g_sayMode = "Markdown"
    local r = reply(...)
    g_sayMode = nil
    return r
end

function reply.html( ... )
    g_sayMode = "HTML"
    local r = reply(...)
    g_sayMode = ""
    return r
end


function reply.delete( m, t, mk )
    g_sayMode = mk 
    local ms = reply(m)
    
    scheduleEvent( t or 120, function(ms)
        if ms.ok then
            bot.deleteMessage(ms.result.chat.id,ms.result.message_id)
        end
    end, ms)
    g_sayMode = nil
end

function reply.parallel(...) 
    if g_chatid then 
        local arg = {...}
        if #arg > 1 then
            local str = "["..#arg.."]: "
            for i,b in pairs(arg) do
                str = str..tostring(b)..',  '
            end
            if (#arg > 0) then
                str = str:sub(1,#str-3)
            end
            str = tostring(str)
            deploy_sendMessage(g_chatid,str, g_sayMode,true,false,g_msg.message_id)
        else
            arg[1] = tostring(arg[1])
            deploy_sendMessage(g_chatid,arg[1], g_sayMode,true,false,g_msg.message_id)
        end 
    end
end

function reply.fancy(str)
    local dur = math.random(1,8)
    if str:len() < 10 then 
        dur =  math.min(dur, 3)
    elseif str:len() < 20 then 
        dur =  math.min(dur, 4)
    elseif str:len() < 30 then 
        dur =  math.min(dur, 5)
    elseif str:len() < 40 then 
        dur =  math.min(dur, 6)
    elseif str:len() < 50 then 
        dur =  math.min(dur, 7)
    end
    scheduleEvent(dur, function(a,b)
        local ret = bot.sendMessage(a, str, g_sayMode,true,false,b)
        if ret and  ret.ok then
            logMessage(ret.result, "reply")
        else 
            print("Failed to send rep", tostring(ret))
            if ret and ret.description:find("Bad Request") then
                say.admin("Failed to send msg ("..arg[1]..") because: "..ret.description.. " at "..a, nil, "Error")
            end
        end
    end, g_chatid, g_msg.message_id)  
    return {result = { text =str} }, bot.sendChatAction(g_chatid, "typing")
end


function assertMsg(r) 
    if r and not r.ok  then 
        say_admin(Dump(r))
    end
end