function OnCommand(msg, txt, args)
  if args[2] == "clear" then 
   	chats[msg.chat.id].data.disabledc = {}
    reply(tr("core-disable-clear"))
  else

    local locked = 0
    for i,b in pairs(g_commands) do 
    	if b.mode == MODE_FREE then 
          locked = locked+1
					chats[msg.chat.id].data.disabledc[thisOrFirst(b.words)] = true
    	end
    end
    reply(tr("core-disable-all", locked))

  end

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

  if disabledCommandString:len() > 0 then
    reply(tr("core-disable-show", disabledCommandString))
  end
  updateCommandListInChat(msg.chat.id)
  SaveChat( msg.chat.id )
end