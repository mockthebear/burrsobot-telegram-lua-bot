local cjson = require("cjson")

function getChannelById(id)
    if not channels[id] then 
        local usr = loadChannel(id, username)
        return usr
    end
    return channels[id]
end



function loadChannel(id)
    local chan = g_redis:hgetall("channel:"..id)
    chan = table.arraytohash(chan) 

    if chan.id == nil then 
        return nil
    end
    local cn = {}
    for i,b in pairs(chan) do 
        cn[i] = unformatFromJson(b)
    end 

    cn._tmp = {type="channel"}
    return cn
end
 


function isChannelAdminAdmin(chatid, id)
    print("the linked is: "..chats[chatid].linked_chat_id.." and i am "..id)
    if chats[chatid].linked_chat_id == id then 
        return true
    end
    return false
end



function CheckChannel(msg)
    local senderObj = msg.sender_chat
    if not senderObj then 
        return true
    end

    if senderObj.type == "channel" then

        if senderObj.username then 
            senderObj.username = senderObj.username:lower()
        end

        local channelObj = channels[senderObj.id]
        if not channelObj then 
            local load = loadChannel(senderObj.id)
            if not load then
                channels[senderObj.id] = senderObj
                channelObj = senderObj
                channelObj.discovery = os.time()
                print("New channel: "..senderObj.title)
            else 
            channels[senderObj.id] = load 
                load.username = senderObj.username
                load.title = senderObj.title
                load.type = senderObj.type
                channelObj = load
            end
            channelObj._tmp = {}
            channelObj._type = msg.sender_chat.type
            channelObj.joinDate = {}

            
        end

        if msg.chat then 
            channelObj.joinDate[msg.chat.id] = os.time()
        end

        SaveChannel(channelObj.id)
    end 

    return true
end




function SaveChannel(id)
    if not id then 
        return false
    end

    if tonumber(id) then 
        id = tonumber(id)
    end

    if channels[id] then 
        for i,b in pairs(channels[id]) do
            if i ~= "_tmp" and i ~= "_type" then
                g_redis:hset("channel:"..id, i, formatToJson(b))
            end
        end

        return true
    else 
        say.admin("Error saving channel unkown "..id..":"..debug.traceback()) 
    end
    return false
end