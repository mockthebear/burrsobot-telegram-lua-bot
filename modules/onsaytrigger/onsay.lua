function OnCommand(msg, text, args)
    if not chats[msg.chat.id] then 
        say.html(tr("onsay-chatonly"))
        return
    end
    if args[2] == "clear" then 
        chats[msg.chat.id].data.onSay = {}
        SaveChat(msg.chat.id)
        reply("Cleared")
        return
    end


    if type(chats[msg.chat.id].data.onSay) ~= "table" then 
        chats[msg.chat.id].data.onSay = {}
    end

    if args[2] == "list" then 
        
        local str = ""
        for i,b in pairs(chats[msg.chat.id].data.onSay) do 
            str = str .. "*"..i:htmlFix( ).." -> <code>"..(b:len() > 20 and (b:sub(1,8):htmlFix( ).. " [...] "..b:sub(#b-8,#b):htmlFix( )) or b:htmlFix( )).."</code>\n"
        end
        reply.html(tr("onsay-keywords", str ))
        return
    end

    if args[2] == "delete" then 
        if not args[3] then 
            reply.html(tr("onsay-missing-delete"))
            return
        end
        local keyword = args[3]
        if not chats[msg.chat.id].data.onSay[keyword] then

            keyword = keyword:gsub("%-", "\\-")
            keyword = keyword:gsub("%+", "\\+")
            keyword = keyword:gsub("%[", "\\[")
            keyword = keyword:gsub("%]", "\\]")
            keyword = keyword:gsub("%(", "\\)")
            keyword = keyword:gsub("%.", "\\.")
            keyword = keyword:gsub("%?", "\\?")
            keyword = keyword:gsub("%^", "\\^")
            keyword = keyword:gsub("%$", "\\$")
            keyword = keyword:gsub("%*", "\\*")
            keyword = keyword:gsub("\\", "\\\\")
            keyword = keyword:gsub("#", "\\#")
            keyword = keyword:gsub("&", "\\&")

            if not chats[msg.chat.id].data.onSay[keyword] then 
                reply.html(tr("onsay-unknown-keyword", keyword))
                return
            else 
                chats[msg.chat.id].data.onSay[keyword] = nil
            end
        else 
            chats[msg.chat.id].data.onSay[keyword] = nil
        end

        reply.html(tr("onsay-deleted", keyword))

        SaveChat(msg.chat.id) 
        return
    end

    if ((not args[3] or args[4]) and not msg.reply_to_message and not (msg.reply_to_message and msg.reply_to_message.text and msg.reply_to_message.text:len() > 0)) or (msg.reply_to_message and args[3]) or (not args[2] or args[2]:len() <= 2 ) then 
        reply.html( tr("onsay-noparams", tr("onsay-usage"), tr("onsay-usage-plus") ))
        return
    end

    local keyword = args[2]
    local repl = msg.reply_to_message and entitiesToHTML(msg.reply_to_message) or args[3]

    local res = say.html(repl or "????????")
    if not res.ok then 
        reply(res.description or "OHNO")
        return
    end

    reply.html(tr("onsay-done", keyword))  

    keyword = keyword:gsub("%-", "\\-")
    keyword = keyword:gsub("%+", "\\+")
    keyword = keyword:gsub("%[", "\\[")
    keyword = keyword:gsub("%]", "\\]")
    keyword = keyword:gsub("%(", "\\)")
    keyword = keyword:gsub("%.", "\\.")
    keyword = keyword:gsub("%?", "\\?")
    keyword = keyword:gsub("%^", "\\^")
    keyword = keyword:gsub("%$", "\\$")
    keyword = keyword:gsub("%*", "\\*")
    keyword = keyword:gsub("\\", "\\\\")
    keyword = keyword:gsub("#", "\\#")
    keyword = keyword:gsub("&", "\\&")

    chats[msg.chat.id].data.onSay[keyword] = repl 
     SaveChat(msg.chat.id) 
end

