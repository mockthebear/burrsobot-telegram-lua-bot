local noraid = {
	staticRaiders = {},

	badwords = {
	    {"bitcoin", "buy"},
	    {"bitcoin", "sell"},
	    {"bitcoin", "trade"},
	    {"ethereum", "buy"},
	    {"ethereum", "sell"},
	    {"ethereum", "trade"},
	    {"hail", "hitler"},
	    {"furries are zoophil"},
	    {"faggots"},
	    {"crypto", "currency"},
	    {"cryptocurrency"},
	    {"fique em casa e ganhe"},
	    {"furries are phedophi"},
	},

	evil_whitelist = {
		[-1001138399875] = {[818904286] = true},
		['all'] = {[899097050] = true, [2096961757]=true}
	},

	channel = "@burrbanbot",
	warnBotAdmin = true,

	timeTreshhold = 1200,
	bardWordsTimeTreshhold = 600,
	mediaTreshhold = 8,

	chat = -1001244253394,
	priority = DEFAULT_PRIORITY - 1000200,
}

--[ONCE] runs when the load is finished
function noraid.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "simple_noraid", {type="boolean"}, true, "Ban only when the user joins", "Anti-raid")
		pubsub.registerExternalVariable("chat", "noraid_agressive", {type="boolean"}, true, "Make noraid more agressive", "Anti-raid")
		pubsub.registerExternalVariable("chat", "noraid", {type="boolean"}, true, "Anti raid on/off", "Anti-raid")
		pubsub.registerExternalVariable("chat", "autoban_raid", {type="boolean"}, true, "Auto ban foreign bots", "Anti-raid")

		pubsub.registerExternalVariable("chat", "raid_join_interval", {type="number",default=60}, true, "Amount of time in seconds between each join to be considered a raid", "Anti-raid")
		pubsub.registerExternalVariable("chat", "raid_join_count", {type="number", default=4}, true, "Amount of sequential joins to be considered raid", "Anti-raid")
		pubsub.registerExternalVariable("chat", "disable_bot_raid", {type="boolean"}, true, "Disable bot raid", "Anti-raid")
	end
	--
	if core then  
		core.addStartOption("Anti raid", "*grr*", "noraid", function() return tr("noraid-start-desc") end )
	end

	noraid.staticRaiders = configs["staticRaiders"] or {}
end



function noraid.save()
	configs["staticRaiders"] = noraid.staticRaiders
	SaveConfig("staticRaiders")
end

--[ONCE] runs when eveything is ready
function noraid.ready()

end

--Runs at the begin of the frame
function noraid.frame()

end

function noraid.noraid_bannedReason(msg)
	if users[msg.from.id].noraid_banned_reason then 
		return users[msg.from.id].noraid_banned_reason
	end
	if isChineseBot(msg.from.first_name) then 
		return "Chinese Bot"
	end
	if isArabicBot(msg.from.first_name) then 
		return "Arabic Bot"
	end
	if isRussianBot(msg.from.first_name) then 
		return "Russian Bot"
	end
	return "Raider"
end

function noraid.onPhotoReceive(msg)
	return noraid.checkUserMessage(msg, true)
end

function noraid.onDocumentReceive(msg)
	return noraid.checkUserMessage(msg, true)
end


function noraid.onAudioReceive(msg)
	return noraid.checkUserMessage(msg, false)
end

function noraid.onStickerReceive(msg)
	return noraid.checkUserMessage(msg, false)
end
 

function noraid.findRaiderWords(txt) 
    for i,b in pairs(noraid.badwords) do 
        local found = true
        for _,word in pairs(b) do 
            if not txt:find(word) then
                found = false
                break
            end            
        end
        if found then 
            say_admin("Banned for saying: "..txt)
            return true
        end
    end    

    return false
end

function noraid.onTextReceive(msg)
	local res, inTime = noraid.checkUserMessage(msg, false)
	if res == KILL_EXECUTION then 
		return KILL_EXECUTION
	end

	--If in time, this means noraid IS active and this use is within the noraid time and he is not banned yet
	if inTime then 
		if noraid.findRaiderWords(msg.text) then
			noraid.TakeAction(msg, whatIs)
			users[msg.from.id].noraid_banned_reason = "Nazi"
			users[msg.from.id].noraid_banned = true
			SaveUser(msg.from.id)
			deploy_deleteMessage(msg.chat.id, msg.message_id)
		end
	end
end



function noraid.checkUserMessage(msg, countMessage)

	if noraid.staticRaiders[msg.from.username:lower()] then
		say.admin("<b>[NORAID]</b>\n\nFound: "..msg.from.username, "HTML")
		noraid.staticRaiders[msg.from.username:lower()] = nil
		users[msg.from.id].noraid_banned = true 
		SaveUser(msg.from.id)
		noraid.save()
	end

	if noraid.staticRaiders[tostring(msg.from.id)] then
		say.admin("<b>[NORAID]</b>\n\nFound: "..msg.from.username, "HTML")
		noraid.staticRaiders[tostring(msg.from.id)]  = nil
		users[msg.from.id].noraid_banned = true 
		SaveUser(msg.from.id)
		noraid.save()
	end


	if msg.isChat then

		local chatMain = chats[msg.chat.id]
		local chatObj = chats[msg.chat.id].data
		local enabled = chatObj.noraid 

		if enabled then

			if noraid.isEvilWhitelist(msg) then 
				print("User is whitelisted")
				return nil, false
			end

			if users[msg.from.id].noraid_banned then 
				deploy_deleteMessage(msg.chat.id, msg.message_id)
				return KILL_EXECUTION, false
			end


			local opUser = users[msg.from.id]
			msg.date = tonumber(msg.date) 


			--Check if my join date is within 1200 seconds (20 min)
			if opUser.joinDate[msg.chat.id] and math.abs(opUser.joinDate[msg.chat.id]-msg.date) <= noraid.timeTreshhold then
				if countMessage then
					--If not the media counter is created, we create (for the chat)
					if not chatMain._tmp.mediaCounter then 
						chatMain._tmp.mediaCounter = {}
					end
					--Now we check if the user hase some stuff in it~
					if not chatMain._tmp.mediaCounter[msg.from.id] then 
						chatMain._tmp.mediaCounter[msg.from.id] = {}
					end
					--Get messages
					local opCount = chatMain._tmp.mediaCounter[msg.from.id]
					--Store this message~
					opCount[#opCount+1] = {msg.date, msg.message_id}

					if (#opCount >= noraid.mediaTreshhold) then
						if not chatMain._tmp.mediaCounter.warned then 
							chatMain._tmp.mediaCounter.warned = {}
						end
 
						if not chatMain._tmp.mediaCounter.warned[msg.from.id] then 
							say.admin("User is on the edge of beeing banned: "..formatUserHtml(msg).." at "..(msg.from.title or "?"), "HTML")
							chatMain._tmp.mediaCounter.warned[msg.from.id] = true

							if noraid.chat then
								bot.sendMessage(noraid.chat, "User is on the edge of beeing banned: "..formatUserHtml(msg).." at "..(msg.from.title or "?"), "HTML")
							end 

						end
						local now = msg.date

						local inSameMinute = 0
						--Check if was sent at least 8 within 1 minute of difference
						for i,b in pairs(opCount) do 
							if math.abs(b[1]-now) <= 60 then 
								inSameMinute = inSameMinute +1
							end
						end

						if inSameMinute >= noraid.mediaTreshhold or chatMain.noraid_agressive then 
							if not users[msg.from.id].noraid_banned then
								noraid.TakeAction(msg, "Spam/Raider", true)
								users[msg.from.id].noraid_banned_reason = "Spam/Raider"
								users[msg.from.id].noraid_banned = true
								SaveUser(msg.from.id)

								if noraid.chat then
									bot.sendMessage(noraid.chat, "<b>[NORAID]</b>\n\nRaid detected from "..formatUserHtml(msg) .." (id: "..msg.from.id..") at chat "..msg.chat.title:htmlFix(), "HTML")
								end

								for i,b in pairs(opCount) do
									deploy_deleteMessage(msg.chat.id, b[2])
								end
								opCount = {}
								return KILL_EXECUTION
							end
						end
					end
				end
				return nil, math.abs(opUser.joinDate[msg.chat.id]-msg.date) <= noraid.bardWordsTimeTreshhold
			else 
				--If we are way past the time, reset the data so we dont store garbage
				if chatMain._tmp.mediaCounter and chatMain._tmp.mediaCounter[msg.from.id] then 
					chatMain._tmp.mediaCounter[msg.from.id] = nil
				end
			end
			return nil, false
		else 
			if users[msg.from.id].noraid_banned then
				if chatObj.simple_noraid then
					return KILL_EXECUTION, false 
				else 
					if chatObj.lastRaidBan ~= msg.from.id then
						noraid.TakeAction(msg)
						chatObj.lastRaidBan = msg.from.id
					end
					bot.deleteMessage(msg.chat.id, msg.message_id)

					return KILL_EXECUTION, false
				end
			end
		end

	else 
		if users[msg.from.id].noraid_banned then 
			return KILL_EXECUTION, false
		end
	end
	return nil, false
end

--Runs some times
function noraid.onNewChatParticipant(msg)

	local chatObj = chats[msg.chat.id].data
	local enabled = chatObj.noraid 
	local raidInternal = chatObj.raid_join_interval or 60
	local raidCount = chatObj.raid_join_count or 4

	--Get the last time a user joined the chat
	local previousJoin = chatObj.last_join or 0
	chatObj.last_join = os.time()

	local autoban = false

	local fromLink = msg.actor.id ~= msg.from.id

	if  noraid.isEvilWhitelist(msg) then 
		return nil
	end

	--Check if the user is marked as a raider~
	if noraid.staticRaiders[msg.from.username:lower()] or users[msg.from.id].noraid_banned or noraid.staticRaiders[tostring(msg.from.id)]  then 
		users[msg.from.id].noraid_banned = true
		if noraid.staticRaiders[msg.from.username:lower()] or noraid.staticRaiders[tostring(msg.from.id)] then
			say.admin("<b>[NORAID]</b>\n\nFound: "..(msg.from.username or msg.from.id), "HTML")
			noraid.staticRaiders[msg.from.username:lower()] = nil
			noraid.staticRaiders[tostring(msg.from.id)] = nil
			noraid.save()
		end

	   	local whatIs = noraid.noraid_bannedReason(msg)
	   	if enabled then
	   		noraid.TakeAction(msg, whatIs)
		else
			noraid.WarnDisabled(msg, whatIs)
			
		end
		SaveUser(msg.from.id)
		return KILL_EXECUTION
	end

	if fromLink then
		--If the user joined whting 1 minute of the otther
		if ( os.time()-previousJoin ) < raidInternal then
			chatObj.sequential_joins = (chatObj.sequential_joins or 0) +1

			if chatObj.disable_bot_raid then
				if chatObj.sequential_joins >= raidCount then 
					if chatObj.sequential_joins == raidCount then
						say.html(tr("noraid-botraid"))
						say.admin(tr("<b>[NORAID]</b>\n\nbot raid at %s", msg.chat.title:htmlFix()), "HTML")
					end 
					--Autoban!
					if not limited then 
						--Check all checking users and ban them!
						for id_,b in pairs(chats[msg.chat.id]._tmp.checking) do 
							if users[id_] then 
								if enabled then
									for id, data in pairs(schedule) do
										if data.args[1].id == id then
											triggerEvent(id)
		 								end
									end
								end
							end 
						end
					end
					noraid.TakeAction(msg, "Chat-raid", true)
					return KILL_EXECUTION
				end
			end
		else 
			chatObj.sequential_joins = 0
		end
	end
	SaveChat(msg.chat.id)

	local isForeignBot = chatObj.botProtection and (isChineseBot(msg.from.first_name) or isArabicBot(msg.from.first_name) or isRussianBot(msg.from.first_name)) 
	if isForeignBot then
		if isForeignBot then 
			local whatIs = noraid.noraid_bannedReason(msg) 
			if enabled then
				noraid.TakeAction(msg, whatIs, true)
			else
				noraid.WarnDisabled(msg, whatIs)
			end
			return  KILL_EXECUTION
		end
	end

end

function noraid.WarnDisabled(msg, whatIs)
	say.html(tr("noraid-action-inactive",  formatUserHtml(msg), whatIs))

	if noraid.channel and tostring(noraid.channel):len() > 0 then 
		deploy_sendMessage(noraid.channel,tr("noraid-action-inactive",  formatUserHtml(msg), whatIs), "HTML")
	end
	--Send message to the bot admin
	if noraid.warnBotAdmin then
		say.admin(string.format("<b>[NORAID]</b>\n\ncannot ban %s (%s) at %s because noraid is not active",  formatUserHtml(msg), whatIs, msg.chat.title:htmlFix()), "HTML")
	end
end

function noraid.TakeAction(msg, whatIs, silent)
	whatIs = whatIs or "raider"
	users[msg.from.id].noraid_banned = true
	local ret = bot.banChatMember(msg.chat.id, msg.from.id, 0, true)
	if not ret or not ret.ok then 
		--If returns nil (connection down)
		ret = ret or {description="nil message"}
		say.html(tr("noraid-action-fail", formatUserHtml(msg), whatIs, ret.description, msg.from.id))
		--Send message in the channel
		if noraid.channel and tostring(noraid.channel):len() > 0 then 
			deploy_sendMessage(noraid.channel, tr("noraid-action-public-fail", formatUserHtml(msg), whatIs, ret.description) , "HTML")
		end
		--Send message to the bot admin
		if noraid.warnBotAdmin then
			say.admin("<b>[NORAID]</b>\n\nFailed to ban "..whatIs.." "..formatUserHtml(msg).." at "..msg.chat.title:htmlFix().." due "..ret.description, "HTML")
		end 
		if noraid.chat then
			bot.sendMessage(noraid.chat, "<b>[NORAID]</b>\n\nFailed to ban "..whatIs.." "..formatUserHtml(msg).." at "..msg.chat.title:htmlFix().." due "..ret.description, "HTML")
		end 

	else  

		local said = say.html(tr("noraid-action-success", formatUserHtml(msg), whatIs, msg.from.id))
		
		if noraid.channel and tostring(noraid.channel):len() > 0 then 
			deploy_sendMessage(noraid.channel, tr("noraid-action-public-success", formatUserHtml(msg), whatIs) , "HTML")
		end
		--Send message to the bot admin
		if noraid.warnBotAdmin then
			say.admin("<b>[NORAID]</b>\n\nBanned "..formatUserHtml(msg) .. "("..whatIs..") (id: "..msg.from.id..") at chat "..msg.chat.title:htmlFix() , "HTML")
		end

		if noraid.chat then
			bot.sendMessage(noraid.chat, "<b>[NORAID]</b>\n\nBanned "..formatUserHtml(msg) .. "("..whatIs..") (id: "..msg.from.id..") at chat "..msg.chat.title:htmlFix(), "HTML")
		end 

		if silent then
			scheduleEvent( 120, function(msg, said)
		        if said.ok then
		            bot.deleteMessage(said.result.chat.id, said.result.message_id)
		            bot.deleteMessage(msg.chat.id, msg.message_id)
		        end
		    end, msg, said)
		end
	end
end


function noraid.loadTranslation()
	g_locale[LANG_US]["noraid-action-fail"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️Attention, user %s was marked in noraid as a %s but i failed to ban him.❗️❗️❗️❗️\n\nReason:<code>%s</code> User id: %d"
	g_locale[LANG_BR]["noraid-action-fail"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️Attention, user %s was marked in noraid as a %s but i failed to ban him.❗️❗️❗️❗️\n\nReason:<code>%s</code> User id: %d"


	g_locale[LANG_US]["noraid-action-public-fail"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️Failed to ban %s which was marked as a %s ❗️❗️❗️❗️\nReason: <code>%s</code>"
	g_locale[LANG_BR]["noraid-action-public-fail"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️Failed to ban %s which was marked as a %s ❗️❗️❗️❗️\nReason: <code>%s</code>"


	g_locale[LANG_US]["noraid-action-success"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️Banned user %s marked as %s❗️❗️❗️❗️ User id: %d"
	g_locale[LANG_BR]["noraid-action-success"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️Banned user %s marked as %s❗️❗️❗️❗️ User id: %d"	

	g_locale[LANG_US]["noraid-botraid"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️Bot raid detected❗️❗️❗️❗️"
	g_locale[LANG_BR]["noraid-botraid"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️Bot raid detected❗️❗️❗️❗️"


	g_locale[LANG_US]["noraid-action-public-success"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️Banned user %s marked as %s❗️❗️❗️❗️"
	g_locale[LANG_BR]["noraid-action-public-success"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️Banned user %s marked as %s❗️❗️❗️❗️"


	g_locale[LANG_US]["noraid-action-inactive"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️%s was marked as a %s but i cannot take action because /noraid is inactive.❗️❗️❗️❗️"
	g_locale[LANG_BR]["noraid-action-inactive"] = "<b>[NORAID]</b>\n\n❗️❗️❗️❗️%s was marked as a %s but i cannot take action because /noraid is inactive.❗️❗️❗️❗️"


	g_locale[LANG_US]["noraid-command-helper"] = "Toggle anti raider protection" 
	g_locale[LANG_BR]["noraid-command-helper"] = "Liga/Desliga proteção contra raiders" 

	g_locale[LANG_US]["noraid-start-desc"] = "I can help handle chat raids. I have a database containign the ID of some users that made raids in the past. Also i can detect if there is a raid happening. With this mode active (using the painel /panel or the /noraid), i can take action when the raid happens!" 
	g_locale[LANG_BR]["noraid-start-desc"] = "Eu posso ajudar evitando/mitigando raid em chats. Eu tenho um banco de dados com o ID de alguns usuários que ja foram registrados fazendo raid em chats. Além disso existe uma forma de detectar se uma raid está acontecendo. Com esse modo ativo (pelo painel /painel ou por /noraid), eu posso tomar açoes no momento que as raids ocorrem!" 

end



function noraid.isEvilWhitelist(msg)
	if msg.chat then 
		if noraid.evil_whitelist[msg.chat.id] then 
			if noraid.evil_whitelist[msg.chat.id][msg.from.id] then 
				return true
			end
		end
		if noraid.evil_whitelist['all'] then 
			if noraid.evil_whitelist['all'][msg.from.id] then 
				return true
			end
		end
	end
	return false
end



function noraid.loadCommands()
	addCommand( "noraid"					, MODE_CHATADMS, getModulePath().."/noraid-command.lua", 2, "noraid-command-helper" )
	addCommand( "evil"						, MODE_ONLY_ADM, getModulePath().."/ban-user.lua", 2, "noraid-admin-command-helper" )
	addCommand( "evilusername"				, MODE_ONLY_ADM, getModulePath().."/ban-username.lua", 2, "noraid-admin-command-helper" )
	
end


return noraid