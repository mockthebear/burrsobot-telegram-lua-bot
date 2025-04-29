local module = {
	edited = {}
}
local JSON = require("JSON")
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

function module.replyGay(chat)

    local pid = ngx.thread.spawn(function()
        local keyb = {}
        keyb[1] = {}
        keyb[1][1] = { text = " 🏳️‍🌈Press here if you are gay🏳️‍🌈", callback_data = "gay"} 
        g_newhttpc=true
        bot.answerInlineQuery(chat, { {type="article", id=1, title="check who is gay", input_message_content = {message_text="WHO PRESSES FIRST IS GAY",   }, reply_markup =  {inline_keyboard = keyb }   } }, nil, nil, nil, "", "kektus")  
    end)

    ngx.timer.at(2,function (_, pid)
        ngx.thread.kill(pid)

        -- body
    end, pid)

end

function module.loadCommands()
	addCommand( "gay", MODE_FREE, function(msg, text, attrs) --paws an pamps
	
		local keyb = {}
		keyb[1] = {}
		keyb[1][1] = { text = " 🏳️‍🌈Press here if you are gay🏳️‍🌈", callback_data = "gay"} 
		local kb2 = cjson.encode({inline_keyboard = keyb})

		bot.sendMessage(g_chatid, "WHO PRESSES FIRST IS GAY", "", true, false, nil, kb2)  
	

	end, 4)
end

function module.onCallbackQueryReceive(msg)

	if msg.data == "gay" then
		msg.inline_message_id = msg.inline_message_id or msg.message.message_id
		if not module.edited[msg.inline_message_id] then
			module.edited[msg.inline_message_id] = 1
			deploy_answerCallbackQuery(msg.id, "<3")
				
			if not configs["gay"] then 
				configs["gay"] = {n=0}
			end

			configs["gay"].n = configs["gay"].n +1

		
			local keyb = {} 
		    keyb[1] = {}
		    keyb[1][1] = { text = "Send the gay button to someone else", switch_inline_query = "gay"} 

		    local kb = cjson.encode({ inline_keyboard = keyb })
		    local gg = configs["gay"].n
		      	
		    if msg.message then
				bot.editMessageText(msg.message.chat.id, msg.message.message_id, nil, "🏳️‍🌈🏳️‍🌈🏳️‍🌈 HECC "..formatUserHtml(msg).." IS GAY! 🏳️‍🌈🏳️‍🌈🏳️‍🌈\nSo far we have <b>"..gg.."</b> gays.", "HTML", nil, kb)
			else 
				bot.editMessageText(nil, nil, msg.inline_message_id, "🏳️‍🌈🏳️‍🌈🏳️‍🌈 HECC "..formatUserHtml(msg).." IS GAY! 🏳️‍🌈🏳️‍🌈🏳️‍🌈\nSo far we have <b>"..gg.."</b> gays.", "HTML", nil, kb)
			end
				
			SaveConfigs()
			return KILL_EXECUTION
		end
	end	
end

function module.onInlineQueryReceive(msg)
	if msg.query == "gay" then
		module.replyGay(msg.id)
		return KILL_EXECUTION
	end
end


return module