





function deploy_setMessageReaction(chat_id, message_id, reaction, is_big)

    ngx.timer.at(0,function(_, chat_id, message_id, reaction, is_big)  
        g_newhttpc = true; 
        bot.setMessageReaction(chat_id, message_id, reaction, is_big)
    end, chat_id, message_id, reaction, is_big)
end

function deploy_answerCallbackQuery(chat, text, alert)

    ngx.timer.at(0,function(_, chat, text, alert)  
        g_newhttpc = true; 
        bot.answerCallbackQuery(chat, text, alert)
    end, chat, text, alert)
end

function deploy_deleteMessage(chat, mid)
    ngx.timer.at(0,function(_, chat, mid)  
        g_newhttpc = true; 
        bot.deleteMessage(chat, mid)
    end, chat, mid)
end

function deploy_editMessageReplyMarkup(chat, msgid, inlineid, kb)
    ngx.timer.at(0,function(_, chat, msgid, inlineid, kb)  
        g_newhttpc = true; 
        bot.editMessageReplyMarkup(chat, msgid, inlineid, kb)
    end, chat, msgid, inlineid, kb)
end

function deploy_editMessageText(chat_id, message_id, inline_message_id, text, parse_mode)

    bot.editMessageText(chat_id, message_id, inline_message_id, text, parse_mode)
    ngx.timer.at(0,function(_, chat_id, message_id, inline_message_id, text, parse_mode)  
        g_newhttpc = true; 
        bot.editMessageReplyMarkup(chat_id, message_id, inline_message_id, text, parse_modeb)
    end, chat_id, message_id, inline_message_id, text, parse_mode)
end

function deploy_sendMessage(chat_id, text, parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)
    -- body
    ngx.timer.at(0,function(_, chat_id, text, parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)  
        g_newhttpc = true; 
        bot.sendMessage(chat_id, text, parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)
    
    end, chat_id, text, parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)
end

function deploy_sendMessageDelete(time, chat_id, text, parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)
    deploy_sendMessage(chat_id, text, parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)
end


function deploy_Meme(uid,chat, uname, uwu)
    ngx.thread.spawn(function()
        whoMeme(uid,chat, uname, uwu)
    end)
end


function deploy_replyEmpty(chat)
    local pid = ngx.thread.spawn(function()
        bot.answerInlineQuery(chat, {}, nil, nil, nil, "", "kektus")
    end)
    ngx.timer.at(2,function (_, pid)
        ngx.thread.kill(pid)

        -- body
    end, pid)
end

function deploy_replySpoiler(chat, text, name)
    ngx.thread.spawn(function()
        local spoiler = text   
        local keyb = {}
        keyb[1] = {}
        keyb[1][1] = { text = "Click to see the spoiler", callback_data = spoiler} 
        g_newhttpc=true
        bot.answerInlineQuery(chat, { {type="article", id=1, title="Your spoiler: "..spoiler, input_message_content = {message_text=name.." sent a spoiler!\n\nTo send a spoiler too:\n@burrsobot spoiler: (your spoiler here)",   }, reply_markup =  {inline_keyboard = keyb }   } }, nil, "Markdown", nil, "", "kektus")
    end)
end


function whoMeme(uid,chat, uname, nm)
    local newN = ""
    local skipper = 0
    --/lua print(string.char(240)..string.char(159)..string.char(142)..string.char(128))
    for i=1, #uname do 
        local n = string.byte(uname:sub(i,i))
        if n == 240 then 
            skipper = 4
        end
        if skipper <= 0 then
            newN = newN .. uname:sub(i,i)
        else 
            skipper = skipper -1
        end
    end
    uname = newN
    uname = newN:match("(.-)%s") or newN
    g_newhttpc=true
    bot.sendMessage(chat,"Making a meme to: ["..uname.."] "..nm..". Might take a while")
    g_newhttpc=true
    local res = bot.getUserProfilePhotos(uid, 0, 1)
    if res and res.ok then 
        local ibgs = res.result.photos[1]
        local image = ibgs[#ibgs]
        g_newhttpc=true
        local ret = bot.downloadFile(image.file_id, "../cache/"..nm.."in.jpg")
        if not ret or not ret.success then 
            g_newhttpc=true
            bot.sendMessage(chat,"failed because: "..(ret.description or "nil").." - "..image.file_id..Dump(ret))
            return
        end
        print("Line: ","../cache/"..nm.."in.jpg")
        g_newhttpc=true
        bot.sendChatAction(chat, "upload_photo")
        os.execute("./whowins/who \""..uname.."\" "..nm )
        g_newhttpc=true
        bot.sendPhoto(chat, "../cache/"..nm..".jpg")
    else
        g_newhttpc=true
        bot.sendMessage(chat,"You dont have a valid profile pic")
    end
end





function bartMeme(uid,chat, msg, nm)
    bot.sendChatAction(chat, "upload_photo")
    os.execute("./whowins/barto \""..msg.."\" "..nm)
    bot.sendSticker(chat, "../cache/"..nm..".png")
end 

function ayleenMeme(uid,chat, msg, nm)
    bot.sendChatAction(chat, "upload_photo")
    os.execute("./whowins/ayleen \""..msg.."\" "..nm)
    bot.sendSticker(chat, "../cache/"..nm.."a.png")
end 
function guiMeme(uid,chat, msg, nm)
    bot.sendChatAction(chat, "upload_photo")
    os.execute("./whowins/gui \""..msg.."\" "..nm)
    bot.sendSticker(chat, "../cache/"..nm.."k.png")
end 

function mockMeme(uid,chat, msg, nm)
    bot.sendChatAction(chat, "upload_photo")
    os.execute("./whowins/mock \""..msg.."\" "..nm)
    bot.sendSticker(chat, "../cache/"..nm..".png")
end 

function sMeme(uid,chat, msg, nm)
    bot.sendChatAction(chat, "upload_photo")
    print("./whowins/ssay \""..msg.."\" "..nm)
    os.execute("./whowins/ssay \""..msg.."\" "..nm)
    bot.sendSticker(chat, "../cache/"..nm.."k.png")
end 

