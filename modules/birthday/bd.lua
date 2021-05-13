function OnCommand(msg, aa, args)
    if not chats[msg.chat.id] then 
        say("This only works on chats")
        return
    end
    local usr = getTargetUser(msg, true)
    if usr then 

    else 
        say("Who??? Please use /bd @username or /bd in the users name")
        return
    end

    local mid = birthday.congratulations_congratulations_congratulations_congratulations(msg.chat.id, usr.id)
    chats[msg.chat.id].data.birthday = usr.id
    chats[msg.chat.id].data.birthday_pinned = mid
    SaveChat(msg.chat.id)
    
end