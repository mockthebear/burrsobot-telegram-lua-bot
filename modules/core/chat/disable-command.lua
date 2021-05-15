function OnCommand(msg, txt, args)
    local disabledCommandString = ""
    local lineC = 1
    for i,b in pairs(g_commands) do 
      if isCommandDisabledInChat(msg.chat.id, b) then
        if lineC%5 == 0 then 
          disabledCommandString = disabledCommandString .. "\n"
        end  
        disabledCommandString = disabledCommandString .. "/"..thisOrFirst(b.words).." "
        lineC = lineC+1
      end
    end

    if not args[2] then 
      reply(tr("core-disable-show", disabledCommandString))
      return
    end

    local cmd = getCommandByWord(args[2])
    if not cmd then 
      reply(tr("core-disable-unknown", args[2]))
      return
    end

     if not chats[msg.chat.id].data.disabledc then 
      chats[msg.chat.id].data.disabledc = {}
    end

    if chats[msg.chat.id].data.disabledc[thisOrFirst(cmd.words)] then
      reply(tr("core-disable-noenabled"))
      return
    end
     
		if cmd.mode == MODE_CHATADMS or cmd.mode == MODE_ONLY_ADM then
			reply(tr("core-disable-noadm"))
			return
		end

   	chats[msg.chat.id].data.disabledc[thisOrFirst(cmd.words)] = true

    reply(tr("core-disable-disabled", thisOrFirst(cmd.words), disabledCommandString))

   	SaveChat( msg.chat.id )
end