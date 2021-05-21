function OnCommand(user, msg, args)
    if not user.chat.id or not chats[user.chat.id] then 
        say("default-chat-only")
        return
    end
    local name1 = user.from.first_name:match("([%a%u%s%dö]+)")
    if not name1 then 
        say("Sorry, your name must contain only A-Z letters.")
        return 
    end

    local list = {}
    for i,b in pairs(chats[user.chat.id]._tmp.users) do 
        if b.id ~= user.from.id then
            list[#list+1] = b
        end
    end
    if #list == 0 then 
        say("Wait some more peopple show up, then use this again. Need more people.")
        return
    end
    local uwu = list[math.random(1,#list)] 

    if uwu.username == "wagesn" then 
        local s = tr('Shippando o casal *@%s* (%s) e *%s*!\nVai dar casamento <3', "wagesn", "Wage", "garçom do abraccio")
        reply_markdown(s)
        return
    end

    local name2 = uwu.first_name:match("([%a%u]+)")
     if not name2 then 
        say("Sorry, your name must contain only A-Z letters.")
        return 
    end	
    	name1 = name1:match("(.-)%s") or name1
    	name2 = name2:match("(.-)%s") or name2

    	local distance1 = math.random(-math.floor(name1:len()/4),math.floor(name1:len()/4)) -1


    	local distance2 = math.random(- math.floor(string.len(name2)/4),math.floor(string.len(name2)/5) )
    	
    	
    	if name1:len()/2 <= 3 then 
    		distance1 = 0
    	end
    	if name2:len()/2 <= 3 then 
    		distance2 = 0
    	end

    	local a1 = string.sub(name1,1,name1:len()/2 + distance1)
        local a2 = string.sub(name2,  name2:len()/2 + distance2 +1,-1)
        local s = tr('Shippando o casal *@%s* (%s) e *@%s* (%s)!\nO nome do casal é: *%s%s*', user.from.username, name1, uwu.username, name2, a1, a2)
        --	print(s)
        reply_markdown(s)

end