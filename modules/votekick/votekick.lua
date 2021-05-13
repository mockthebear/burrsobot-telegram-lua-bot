local module = {
	kicks = {}
}

--[ONCE] runs when the load is finished
function module.load()
	module.kicks = configs["kicks"] or {}
end

--[ONCE] runs when eveything is ready
function module.ready()

end

--Runs at the begin of the frame
function module.frame()

end

--Runs some times
function module.save()
	configs["kicks"] = module.kicks
	SaveConfig("kicks")
end

function module.loadCommands()
	addCommand( "votekick"					, MODE_FREE, getModulePath().."/command.lua", 0, "votekick"  )
	
end

function module.loadTranslation()
	g_locale[LANG_US]["Apenas admins!"] = "Adminso only"

end




function module.renderKickMsg(data, who, onlyResult)
	local str = ""
	if not onlyResult then
		str = "👞Votação para kickar "..formatUserHtml({from=who}).."!🥾\n\n"
	end
	local yes = 0
	local no = 0
	for i,b in pairs(data) do 
		if b == 'y' then 
			yes = yes +1
		else 
			no = no +1
		end
	end

	local percentY = (yes+no) > 0 and math.floor(yes/(yes+no)*100) or "-"
	local percentN = (yes+no) > 0 and math.floor(no/(yes+no)*100) or "-"
	if yes > no then 
		str = str .. "\n🟢<b>Sim:</b> <code>"..yes.."</code>   <i>("..percentY.."%)</i>\n⚪️<b>Não: </b><code>"..no.."</code>   <i>("..percentN.."%)</i>"
	elseif no < yes then
		str = str .. "\n⚪️<b>Sim:</b> <code>"..yes.."</code>   <i>("..percentY.."%)</i>\n🟢<b>Não: </b><code>"..no.."</code>   <i>("..percentN.."%)</i>"
	else
		str = str .. "\n⚪️<b>Sim:</b> <code>"..yes.."</code>   <i>("..percentY.."%)</i>\n⚪️<b>Não: </b><code>"..no.."</code>   <i>("..percentN.."%)</i>"
	end
	return str..(onlyResult and "" or "\n\n(Ação só é tomada por admin)")
end


function module.onCallbackQueryReceive(msg)
	if not msg.data then 
		return
	end


	local kickid, user, selection = msg.data:match("kick:(%d+):(%d+):(.+)")

	--local username = msg.from.username:lower()
	local userid = msg.from.id
	local username = msg.from.name
	local username = msg.from.username


	if kickid then
		kickid = tonumber(kickid)
	
		if not module.kicks[kickid] then 
			deploy_answerCallbackQuery(msg.id, "Kick inexistente.")
			--deploy_deleteMessage(obj.chatid, obj.message_id)
			deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
			return true
		end
		local obj = module.kicks[kickid]

		local yes = 0
		local no = 0
		for i,b in pairs(obj.users) do 
			if b == 'y' then 
				yes = yes +1
			else 
				no = no +1
			end
		end

		if selection == 'e' then 
			if isUserChatAdmin(obj.chatid, userid)  then
				g_chatid = obj.chatid
				say_html("<b>Votação encerrada!!</b>\n\n"..module.renderKickMsg(obj.users, obj.target, true))
				deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
			else 
				deploy_answerCallbackQuery(msg.id, tr("Apenas admins!"))
			end
			return false 
		end
		if selection == 'b' or selection == 'k' then 
			if isUserChatAdmin(obj.chatid, userid)  then
				deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
				if (selection == 'k') then
					local ret = bot.kickChatMember(obj.chatid, user, 0)
		            if not ret or not ret.ok then 
		                deploy_answerCallbackQuery(msg.id, "Failed to kick, reason:"..tostring(ret.description))
		                return
		            else 
		            	g_chatid = obj.chatid
						say_html("Usuário "..formatUserHtml({from=obj.target}).." kickado!\n\n"..module.renderKickMsg(obj.users, obj.target, true))
						deploy_answerCallbackQuery(msg.id, "Kick!")
		            end
				else
					local ret = bot.restrictChatMember(obj.chatid, user, os.time() + 300, false, false, false, false)
					if not ret.ok then 
						
						deploy_answerCallbackQuery(msg.id, "Failed to mute "..(user).." because: "..ret.description)
					else 
						g_chatid = obj.chatid
						local wut = say_html("Muted "..(obj.target.username or obj.target.first_name).." for 5 minutes.\n\n"..module.renderKickMsg(obj.users, obj.target, true))
						scheduleEvent(6, function()
							bot.deleteMessage(wut.result.chat.id,wut.result.message_id)
						end)
						scheduleEvent(50, function()
							bot.restrictChatMember(obj.chatid, user, 0, true, true, true, true)
						end)
					end
				end				
			else 
				deploy_answerCallbackQuery(msg.id, "Apenas admins!")
			end
			return true
		end
		
		obj.users[userid] = selection
		if selection == 'y' then 
			yes = yes +1
		end
		if selection == 'n' then 
			no = no +1
		end
		deploy_answerCallbackQuery(msg.id, "Voto registrado")
		keyb = {}
		keyb[1] = {}				
						

		keyb[1] = {}				
		keyb[2] = {}				
		keyb[1][1] = {text = "✅Sim✅", callback_data = "kick:"..kickid..":"..user..":y" }
		keyb[1][2] = {text = "❌Não❌", callback_data = "kick:"..kickid..":"..user..":n" }

		keyb[2][1] = {text = "(Adm only) ✴️Encerrar (sem tomar ação)✴️", callback_data = "kick:"..kickid..":"..user..":e" }
		if (yes > no) then
			keyb[3] = {}
			keyb[4] = {}
			keyb[3][1] = {text = "(Adm only) 🔇Mutar por 5 min🔇", callback_data = "kick:"..kickid..":"..user..":b" }
			keyb[4][1] = {text = "(Adm only) 🥾Kickar🥾", callback_data = "kick:"..kickid..":"..user..":k" }
		end
		local JSON = require("JSON")
		local kb = JSON:encode({inline_keyboard = keyb})

		bot.editMessageText(obj.chatid, obj.msg.message_id, nil, module.renderKickMsg(obj.users, obj.target), "HTML", nil, kb)	
		
		return KILL_EXECUTION
	end	
end


return module