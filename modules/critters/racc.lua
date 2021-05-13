function OnCommand(user, msg, args)
    local isAdm =  isUserBotAdmin(user.from.id)
    if isAdm and user.reply_to_message and user.reply_to_message.photo then 
        local dat = user.reply_to_message.photo[3]
        if not dat then 
            dat = user.reply_to_message.photo[2]
            if not dat then 
                dat = user.reply_to_message.photo[1]
                if not dat then 
                    say("Photo too small to set as a group photo.") 
                    return
                end
            end
        end 
        local fname = "../media/racc/"..os.time()..".jpg"

        bot.downloadFile(dat.file_id, fname)
        say("Added to "..fname)
        return
    end
    local f = assert(io.popen("ls ../media/racc", 'r'))
    local s = assert(f:read('*a'))
    f:close()
    local files = {}
    for i in s:gmatch("(.-)\n") do 
    	files[#files+1] = i
    end
    local f = files[math.random(1,#files)]
    os.execute("./blinka green 1 yes &")
    bot.sendPhoto(user.chat.id, "../media/racc/"..f) 
    os.execute("./blinka green 1 no &")
end