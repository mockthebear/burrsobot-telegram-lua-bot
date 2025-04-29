function OnCommand(user, msg, args)
    local edir = ""
    if args[2] == "abdl" then 
        edir = "/abdl"
    elseif args[2] == "pronz" then 
    	if chats[user.chat.id] and chats[user.chat.id].data.sfw ~= false then 
			reply("NO. need to enable nsfw here.")
    		return
    	end
        edir = "/pdonz" 
    elseif args[2] == "fursuit" then 
        edir = "/fursuit"
    end
    local f = assert(io.popen("ls ../media/mocc"..edir, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    local files = {}
    for i in s:gmatch("(.-)\n") do 
    	files[#files+1] = i
    end
    local f = files[math.random(1,#files)]
    while f == "abdl" or f == "pdonz" do 
        f = files[math.random(1,#files)]
    end
    os.execute("./blinka green 1 yes &")
    if f:find("%.mp4") then 
        bot.sendVideo(user.chat.id, "../media/mocc"..edir.."/"..f, f, false,user.message_id) 
    else
        bot.sendPhoto(user.chat.id, "../media/mocc"..edir.."/"..f, f, false,user.message_id) 
    end
    os.execute("./blinka green 1 no &")
end