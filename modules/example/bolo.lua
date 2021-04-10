function OnCommand(user, text, args)
    local c = math.random(1,4)
    if c <= 3 then
        local f = assert(io.popen("ls "..getModulePath().."/bolos/", 'r'))
        local s = assert(f:read('*a'))
        f:close()
        local files = {}
        for i in s:gmatch("(.-)\n") do 
            files[#files+1] = i
        end
        local f = files[math.random(1,#files)]

        bot.sendPhoto(user.chat.id, getModulePath().."/bolos/"..f) 
    else
        bot.sendSticker(user.chat.id,choose("CAADAQADyAEAAk6Q4QS_q3GUA5TXbgI", "CAADAQADJQEAAk6Q4QQ-FfR1Tu6dJAI", "CAADAQAD9gEAAk6Q4QTlofIDqbuEkRYE"))
    end
end

