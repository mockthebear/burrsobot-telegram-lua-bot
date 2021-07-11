function OnCommand(user, msg, args)
    if not user.chat.id or not chats[user.chat.id] then 
        deploy_sendMessage(g_chatid,"This only owrks on chats")
        return
    end
    if args[2] == "msg" then 
        if args[3] and args[3]:len() > 0 then 
            say("Ban message set to: "..args[3])
            chats[user.chat.id].data.banmsg = args[3]
            SaveChat( user.chat.id )
        else 
          say(tr("Use assim: /bansticker msg \"Nao pode isso aqui jovem.\""))
        end
        return
    elseif args[2] == "clear" then 
        chats[user.chat.id].data.banpack = {}
        chats[user.chat.id].data.bansticker = {}
        say(tr("Lista limpa!"))
        SaveChat( user.chat.id )
        return
    end
    if user.reply_to_message then 
        if user.reply_to_message.sticker then 
            user = user.reply_to_message
            if args[2] == "pack" then 
                if not chats[user.chat.id].data.banpack then 
                    chats[user.chat.id].data.banpack = {}
                end
                if type(chats[user.chat.id].data.banpack) ~= "table" then 
                    chats[user.chat.id].data.banpack = {}
                end
                if not chats[user.chat.id].data.banpack[ user.sticker.set_name ] then
                    chats[user.chat.id].data.banpack[ user.sticker.set_name ] = true
                    say.markdown(tr("Sticker pack *%s* banido!", user.sticker.set_name))
                    deploy_deleteMessage(user.chat.id, user.message_id)
                    SaveChat( user.chat.id )
                else 
                    chats[user.chat.id].data.banpack[ user.sticker.set_name ] = nil
                    say.markdown(tr("Sticker pack *%s* desbanido!", user.sticker.set_name))
                    SaveChat( user.chat.id )
                end
            else 
                if type( chats[user.chat.id].data.bansticker) ~= "table" then 
                    chats[user.chat.id].data.bansticker = {}
                end
                if not chats[user.chat.id].data.bansticker[ user.sticker.file_unique_id ] then
                    chats[user.chat.id].data.bansticker[ user.sticker.file_unique_id ] = true
                    say.markdown(tr("Sticker *%s* banido! Use */bansticker pack* para banir o pack inteiro.", user.sticker.file_unique_id))
                    deploy_deleteMessage(user.chat.id, user.message_id)
                    SaveChat( user.chat.id )
                else 
                    chats[user.chat.id].data.bansticker[ user.sticker.file_unique_id ] = nil
                    say.markdown(tr("Sticker *%s* desbanido!", user.sticker.file_unique_id))
                    SaveChat( user.chat.id )
                end
                
            end
        else 
            say(tr("Use isso respondendo em um sticker."))
 

            return
        end
    else 
        say(tr("Responda a um sticker usando /bansticker para banir o sticker ou /bansticker pack para banir o pack inteiro.\nOu /bansticker msg \"Nao pode aqui\", para setar uma mensagem ao deletar o sticker.\n/bansticker clear, para limpar tudo"))
        if chats[user.chat.id].data.banpack then 
            local ret = ""
            ret = ret .. "Packs banidos: \n"
            for i,b in pairs(chats[user.chat.id].data.banpack) do 
                ret = ret .."<a href=\"t.me/addstickers/"..i.."\">"..i.."</a>\n"
            end
            bot.sendMessage(g_chatid, ret, "HTML")
         end
        return
    end
end
