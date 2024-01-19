function getEntity(msg)
	local msgfrom = msg.from
	if msgfrom then 
		local id = msgfrom.id
		if msg.sender_chat then
			if id == 136817688 then 
				--Then is a sender chat:

				local usr, which = getEntityById(msg.sender_chat.id)
				return usr, which, msg.sender_chat
			end
			if id == 777000 then 
				--Administrator!
				local usr, which =getEntityById(msg.sender_chat.id)
				return usr, which, msg.sender_chat
			end
			if id == 1087968824 then 
				--Administrator!
				local usr, which =getEntityById((msg.sender_chat or msg.new_chat_member.user).id)
				return usr, which, msg.sender_chat or msg.new_chat_member.user
			end
		end
		local usr, which = getEntityById(id)
		return usr, which, msgfrom
	elseif msg.sender_chat then
		local usr, which = getEntityById(msg.sender_chat.id)
		return usr, which, msg.sender_chat
	end
end

function getEntityById(id)
	local usr = users[id]
	if usr then 
		return usr, "user"
	end

	usr = channels[id]
	if usr then 
		return usr, "channel"
	end

	usr = chats[id]
	if usr then 
		return usr, "chat"
	end

	return nil, "unkown"
end

function getEntityName(entity)
	if entity._type == "user" then 
		return entity.first_name
	else
		return entity.title
	end
end

function isEntityChatAdmin(msg, overrideChat)
	local ent, which = getEntity(msg)
	if not ent then 
		return false
	end

	local queryChat = overrideChat or msg.chat.id

	checkCacheChatAdmins(msg, overrideChat)

	if which == "user" then 
		return isUserChatAdmin(queryChat, msg.from.id)
	end

	if which == "chat" then 
		if overrideChat == msg.sender_chat.id or msg.sender_chat.id == msg.chat.id then 
			return true
		end
	end

	if which == "channel" then 
		return isChannelAdminAdmin(queryChat, msg.sender_chat.id)
	end

	return false
end


function SaveEntity(id) 
	local ent, which = getEntity({from=id})
	if not ent then 
		return false
	end

	if which == "user" then 
		SaveUser(msg.from.id)
	elseif which == "channel" then 
		SaveChannel(msg.sender_chat.id)
	elseif which == "chat" then 
		SaveChannel(msg.chat.id)
	end

	return false
end
