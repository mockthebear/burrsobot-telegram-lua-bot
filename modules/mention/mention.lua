local module = {
	marked = {}
}

--[ONCE] runs when the load is finished
function module.load()

end

--[ONCE] runs when eveything is ready
function module.ready()

end

--Runs at the begin of the frame
function module.frame()

end

--Runs some times
function module.save()

end

function module.loadCommands()
	addCommand( {"marcado", "mention"}	, MODE_FREE, getModulePath().."/mention-command.lua",2 , "Mostra onde você foi mencionado.")
end

function module.loadTranslation()
	g_locale[LANG_US]["Desculpe, nem uma menção a @%s na%s utima%s %d hora%s e %d minuto%s."] = "Sorry, no mentions to @%s in the past%s%s %d hour%s and %d minute%s."
	g_locale[LANG_US]["Desculpe, isso não pode ser usado aqui, só em chats"] = "Sorry, this cant be used here, only in group chats."
	g_locale[LANG_US]["A menção foi apagada, quem te marcou foi @%s a o texto dizia:\n`%s`\n\n"] = "The mention was deleted and who said was @%s and the text said:\n`%s`\n\n"
	g_locale[LANG_US]["\n*Ainda existem %d mençoes. Repita o comando para ve-las.*"] = "\n*There are still %d mentions. Repeat the command to see it*."
	g_locale[LANG_US]["A menção mais recente é essa."] = "The most recent mention is this one."
end

function module.CheckMarked(msg)
	if msg.chat and msg.chat.id and chats[msg.chat.id] then 
        if not module.marked[msg.chat.id] then 
            module.marked[msg.chat.id]  = {}
        end
        local txt = msg.text or msg.caption
        if txt then 

            local uname = txt:match("@([%l%u%d]+)")
            uname = uname and uname:lower() or nil
            if users[uname] and not uname:match("(.-)bot") then 
                if not  module.marked[msg.chat.id][uname] then 
                     module.marked[msg.chat.id][uname] = {}
                end
                local size = # module.marked[msg.chat.id][uname]+1
                 module.marked[msg.chat.id][uname][size] = {msg.message_id, txt, msg.from.username, os.time()}
                if size >= 10 then
                    table.remove(module.marked[msg.chat.id][uname], 1)
                end
            end
        end
    end
end

function module.onTextReceive(msg)
	module.CheckMarked(msg)
end

function module.onPhotoReceive(msg)
	module.CheckMarked(msg)
end

function module.onAudioReceive(msg)
	module.CheckMarked(msg)
end

return module