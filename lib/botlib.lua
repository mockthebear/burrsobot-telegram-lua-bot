local JSON = require("JSON")
MODE_FREE     = 0
MODE_ONLY_ADM = 1
MODE_NSFW     = 2
MODE_UNLISTED = 3
MODE_CHATADMS = 4





function formatMessage(msg)

    if msg.from and msg.from.id == 777000 then 
        return false
    end

    if msg.text then
        local text_lower = msg.text:lower()
        msg.targeted_to_bot = msg.chat.type == "private" or text_lower:match("^@?"..g_botname) ~= nil or text_lower:match("^@?"..g_botnick) ~= nil or (msg.reply_to_message and msg.reply_to_message.from.id == g_id)
    else 
        msg.targeted_to_bot = msg.chat.type == "private"
    end

    msg.from.originalUname = msg.from.username

    msg.from.username2 = (msg.from.username or tostring(msg.from.first_name)..(msg.from.id))
    msg.from.username = (msg.from.username or tostring(msg.from.first_name)..(msg.from.id)):lower()
    msg.chat.id = tonumber(msg.chat.id) or 0

    local failed = false

    if not CheckChat(msg) then 
        return false
    end

    if not CheckUser(msg) then 
       return false
    end

    g_msg = msg
    g_chatid = msg.chat.id

    return true
end

function hasLink(str)

    local a,b,c = str:match("http://([%u%l%d]-)%.([%l%d]-)%.([%u%l%d]+)")
    if a and b and c and a:len() >= 2 and b:len() >= 2 and c:len() >= 2  then 
        return true
    end

    a,b = str:match("http://([%u%l%d]-)%.([%u%l%d]+)")
    if a and b and b:len() >= 2 then 
        return true
    end
    
    a,b,c = str:match("https://([%u%l%d]-)%.([%u%l%d]-)%.([%u%l%d]+)")
    if a and b and c and a:len() >= 2 and b:len() >= 2 and c:len() >= 2  then 
        return true
    end

    a,b = str:match("https://([%u%l%d]-)%.([%u%l%d]+)")
    if a and b and b:len() >= 2 then 
        return true
    end
    

    a,b,c = str:match("([%l%u%d]-)%.([%l%u%d]-)%.([%l%u%d]+)")
 
    if a and b and c and a:len() >= 2 and b:len() >= 2 and c:len() >= 2  then 
        return true
    end

    a,b = str:match("([%l%d]-)%.([%l%d]+)")
    
    if a and b and b:len() >= 2 then 
        return true
    end
    
    
    return false
end



function insertInString(str, start, lenght, tag, tagEnd)
    local a1 = utf8.sub(str, 1, start)
    local a2 = utf8.sub(str, start+lenght+1, -1)
    local mid = utf8.sub(str, start+1, start+lenght)
    local new = (utf8.len(tag) + (tagEnd and utf8.len(tagEnd) or utf8.len(tag))) + 5
    return a1.."<"..tag..">"..mid.."</"..(tagEnd and tagEnd or tag)..">"..a2, new, utf8.len(tag)+2, (tagEnd and utf8.len(tagEnd) or utf8.len(tag))+3
end

--Given telegram entities, we parse it and transform in to a HTML text~
function entitiesToHTML(msg)
    if not msg.entities and not msg.caption_entities then 
        return msg.text or msg.caption
    end

    local tagByType = {
        ["bold"] = "b",
        ["italic"] = "i",
        ["strikethrough"] = "s",
        ["code"] = "code",
        ["pre"] = "pre",
        ["underline"] = "u",
        ["text_link"] = 'a href="$url"',
        ["text_mention"] = 'a href="tg://user?id=$userid"',
    } 
    local endTagByType = {
        ["bold"] = "b",
        ["italic"] = "i",
        ["strikethrough"] = "s",
        ["code"] = "code",
        ["pre"] = "pre",
        ["underline"] = "u",
        ["text_link"] = 'a',
        ["text_mention"] = 'a',
    } 

    local function parseTag(str, obj)
        if obj.url then 
            str = str:gsub("%$url", obj.url)
        end
        if obj.user then 
            str = str:gsub("%$userid", obj.user.id)
        end

        return str
    end

    local original = msg.text or msg.caption
    local mainOffset = 0
    local sections = {}
    for i,b in pairs(msg.entities or msg.caption_entities) do
        if b.type ~= "bot_command" and b.type ~= "mention" then
            for a,c in pairs(msg.entities or msg.caption_entities) do
                if i ~= a and not sections[a] and not sections[i] then
                    if b.offset >= c.offset and (b.offset +b.length) <= (c.offset+c.length) then 
                        sections[a] = 1
                        sections[i] = 1
                        local start = mainOffset + c.offset
                        original, len, int, out = insertInString(original, start, c.length, parseTag(tagByType[c.type], c) ,  endTagByType[c.type])
                        mainOffset = mainOffset + len


                        start = mainOffset + b.offset + int-1
                        original, len = insertInString(original, start-out-int+1, b.length, parseTag(tagByType[b.type], b),  endTagByType[b.type])
                        mainOffset = mainOffset + len
                    end
                end 
            end
        end
    end
    for i,b in pairs(msg.entities or msg.caption_entities) do
        if not sections[i] then 
            if b.type ~= "bot_command" and b.type ~= "mention" then
                local start = mainOffset + b.offset

                original, len = insertInString(original, start, b.length, parseTag(tagByType[b.type], b),  endTagByType[b.type])
                mainOffset = mainOffset + len
            end       
        end
    end
    return original
end



function string:htmlFix()
    self = self:gsub("&","&amp")
    self = self:gsub("<","&lt;")
    self = self:gsub(">","&gt;")
    return self
end

function formatUserHtml(msg)
    local dat = msg
    if not msg.from then 
        msg = {from = msg}
    end
    if not msg.from.id then 
        msg.from.id = telegramid
    end
    return ('<a href="tg://user?id='..msg.from.id..'">'..(msg.from.username and ("@"..msg.from.username) or (msg.from.first_name or "?name?"):htmlFix())..'</a>')
end

function isArabicLetter(str, letter)
  local n = string.byte(str:sub(letter,letter))
  if n >= 216 and n <= 219 then
    letter = letter+1
    n = string.byte(str:sub(letter,letter))
    if n >= 128 and n <= 191 then
        return true, 2
    end
    return false, 2
  end
  return false, 1
  -- body
end

function isArabicBot(name)
    if name:find("卍") then 
        return true
    end
  local n = 0
  local cursor=1
  while cursor < #name do 
    local isCH, add = isArabicLetter(name, cursor)
    cursor = cursor + add
    if isCH then 
      n = n + 1
      if n >= 4 then
        return true
      end
    else 
      n = 0
    end
  end
  return false
end


function isChineseLetter(str, letter)
  local n = string.byte(str:sub(letter,letter))
  if n >= 229 and n <= 233 then
    letter = letter+1
    n = string.byte(str:sub(letter,letter))
    if n >= 128 and n <= 191 then
      letter = letter+1
      n = string.byte(str:sub(letter,letter))
      if n >= 128 and n <= 191 then
        return true, 3
      end
    end
    return false, 3
  end
  return false, 1
  -- body
end

function isChineseBot(name)
  local n = 0
  local cursor=1
  while cursor < #name do 
    local isCH, add = isChineseLetter(name, cursor)
    cursor = cursor + add
    if isCH then 
      n = n + 1
      if n >= 3 then
        return true
      end
    else 
      n = 0
    end
  end
  return false
end

function isRussianLetter(str, letter)
  local n = string.byte(str:sub(letter,letter))
  if n >= 208 and n <= 209 then
    letter = letter+1
    n = string.byte(str:sub(letter,letter))
    if n >= 128 and n <= 191 then
      letter = letter+1

       return true, 2
    end
    return false, 2
  end
  return false, 1
  -- body
end

function isRussianBot(name)
  local n = 0
  local m = 0
  local cursor=1
  while cursor < #name do 
    local isCH, add = isRussianLetter(name, cursor)
    cursor = cursor + add
    if isCH then 
      n = n + 1
    else 
      m = m +1
    end
  end
  if #name == 0 then 
    return false
  end
  local perc = (n / #name) * 100

  return perc > 40
end

function selectUsername(msg, format)
    if msg.username then 
        return selectUsername({from=msg}, true)
    end
    if not msg.from.username then 
        return not format and msg.from.first_name or ('<a href="tg://user?id='..msg.from.id..'">'..msg.from.first_name..'</a>')
    else 
        return not format and msg.from.username or ("@"..msg.from.username)
    end
end

function choose( ... )
    local arg = {...}
    return arg[math.random(1,#arg)]
end

function Dump(T, l, str, supress)
    local ret = ""
    l = l or 1
    supress = supress or {["_tmp"]=nil}
    if not T then 
        return tostring(T)
    end
    for i,b in pairs(T) do 
        if not supress[i] then
            ret = ret .. string.format("%s %s%s = %s",string.rep(" ",l),(str and str.."." or ""),tostring(i),tostring(b))
            if type(b) == "table" then 
                ret = ret ..string.rep(" ",l).."{\n"
                --ret = ret ..string.rep(" ",l).. (str and str.."." or "")..tostring(i).."\n"
                ret = ret ..Dump(b, l+1, (str and str.."."..i or i))
                ret = ret ..string.rep(" ",l).."}\n"
            else
                ret = ret .. "\n" 
            end
        end
    end
    return ret
end

function parseMessageDataToStr(msg)
    local str = ""

    str = str .."Message id: <b>".. msg.message_id..'</b>\n'
    str = str .."Message Date: <b>".. msg.date..'</b>\n'
    if msg.from then 
        str = str .. 'From '..msg.from.id..' <a href="tg://user?id='..msg.from.id..'">'..msg.from.first_name..'</a> | '..(msg.from.username and ("@"..msg.from.username) or "no username" )..'\n'
    end

    if msg.chat then 
        str = str .. 'On chat <b>'..msg.chat.id..'</b> - '..(msg.chat.type == "private" and "private" or msg.chat.title)..'\n'
    end

    if msg.text then 
        str = str .. 'Original text were <b>'..msg.text..'</b>\n'
    end

    if msg.description then 
        str = str .. 'Original description were <b>'..msg.description..'</b>\n'
    end

    if msg.caption then 
        str = str .. 'Original caption were <b>'..msg.caption..'</b>\n'
    end
    
    if msg.media_group_id then 
        str = str .. 'Its a media group with id <b>'..msg.media_group_id..'</b>\n'
    end

    if msg.sticker then 
        str = str .. 'Sticker fileid <b>'..msg.sticker.file_id..'</b> by set  '..(msg.sticker.set_name or "??")..'\n'
    end

    if msg.document then 
        str = str .. 'Document fileid <b>'..msg.document.file_id..'</b> mime_type  '..((msg.document or {}).mime_type or "??")..'\n'
    end

    if msg.photo then 
        local n = #msg.photo
        local a = table.remove(msg.photo,1)
        str = str .. 'Fields on photo are <b>'..n..'</b>. FileId: <b>'..a.file_id..'</b>\n'
    end

    if msg.forward_from then 
        str = str .. 'Forwarded from <b>'..msg.forward_from.id..' <a href="tg://user?id='..msg.forward_from.id..'">'..msg.forward_from.first_name..'</a></b> | '..(msg.forward_from.username and ("@"..msg.forward_from.username) or "no username" )..'\n'
    end

    return str
end

function DumpTableToStr(T, l, str)
    str = str or ""
    l = l or 1
    if not T then 
    	return tostring(T)
    end
    for i,b in pairs(T) do 
        str = str .. string.format("%s %s = %s\n",string.rep("-",l),tostring(i),"["..type(b).."]"..tostring(b))
        if type(b) == "table" then 
            str = str ..string.rep("-",l)..tostring(i).."\n\n"
            str = str ..DumpTableToStr(b, l+1)
            str = str ..string.rep("-",l).."\n"
        end
    end
    return str
end

function unformatFromJson(tb, skipDecode) 
    local newT = {}
    

    tb = skipDecode and tb or cjson.decode(tb)
    if type(tb) ~= "table" then 
        return tb
    end

    for i,b in pairs(tb) do 
        local data = b
        if type(b) == 'table' then 
            data = unformatFromJson(b, true) 
        end
        local indx = i
        if tostring(i):sub(1,3) == "___" then 
            indx = tonumber(i:sub(4, -1))
        end
        newT[indx] = data
    end
    return newT
end

function formatToJson(tb, ignoreFormat) 
    local newT = {}

    if type(tb) ~= "table" then 
        return (not ignoreFormat) and cjson.encode(tb) or tb
    end
    
    local fieldCount = 0
    for i,b in pairs(tb) do 
        fieldCount = fieldCount +1
    end
    local isUniform = fieldCount == #tb
    if isUniform then 
        return (not ignoreFormat) and cjson.encode(tb) or tb
    end
    for i,b in pairs(tb) do 
        local data = b
        if type(b) == 'table' then 
            data = formatToJson(b, true) 
        end
        local indx = i
        if type(i) == "number" then 
            indx = "___"..tostring(i)
        end
        newT[indx] = data
    end
    return (not ignoreFormat) and cjson.encode(newT) or newT
end


function DumpTable(T, l)
    local str = DumpTableToStr(T, l)
    print(str)
    return str
end

function serialize(data, depth)
    depth = depth or 0
    local str = ""
    for i,b in pairs(data) do 
        if type(b) ~= "function" then
            local strB = tostring(b)
            if i ~= "_tmp" then
                if type(b) == "table" then 
                    
                    strB = "{"..serialize(b, depth+1).."}"
                end
                str = str .. i .. "="..strB.."#"..(depth == 0 and "@" or depth).."#"
            end
        end
    end
    return str
end 

function unserialize(str, depth)
    depth = depth or 0
    local t = {}
    for i,v in str:gmatch("(.-)=(.-)#"..(depth == 0 and "@" or depth).."#") do 
        local var = v
        if var:match("^{(.+)}$") then 
            local serl = var:match("^{(.+)}$")
            depth = depth or 0
            t[tonumber(i) or i] = unserialize(serl, depth+1)
        else
            t[tonumber(i) or i] = tonumber(var) or var 
            if t[tonumber(i) or i] == "true" then 
                t[tonumber(i) or i] = true
            elseif t[tonumber(i) or i] == "false" then 
                t[tonumber(i) or i] = false
            end
        end
    end
    return t
end

function thisOrFirst(t, newv)
    if type(t) == "table" then 
        if newv then 
            if t[newv] then 
                return t[newv]
            end
        end
        return unpack(t)
    end
    return t
end




function table.arraytohash(arr) 
    if #arr%2 ~= 0 then 
        error("Expecting uniform array")
    end
    local hash = {}
    for i=1,#arr/2 do 
        local ind = (i * 2)-1
        local val = i * 2
        hash[arr[ind]] = arr[val]
    end
    return hash
end

function table.serializer(val, carry)
    carry = carry or {}
    local t = type(val)
    if t == "table" then 
        --avoid double ref
        if carry[val] then 
            return "{}"
        end
        carry[val] = true
        local str = ""
        local seq = 1
        for i,b in pairs(val) do 
            
            local vparse = table.serializer(b,carry)
            
            if vparse then
                local ind = ""
                if seq ~= i then 
                    ind = "[\""..tostring(i):gsub('"',"\\\"").."\"]="
                end
                str = str ..ind..vparse..","
            end
            seq = seq +1
        end
        if str:sub(-1,-1) == "," then 
            str = str:sub(1,-2)
        end
        return "{"..str.."}"
    elseif t == 'userdata' or t == 'function' then 
        return nil, "[invalid type]"
    elseif t == 'string' then
        return "\""..val:gsub('"',"\\\"").."\"" 
    end
    return tostring(val), true
end

function table.unserializer(str)
    local f, err = loadstring("return "..str)
    if not f then 
        error(err)
        return nil
    end
    return f()
end



function string:MatchFind( ... )
    return MatchFind(self, ...)
end

function MatchFind(par, ...)
    local wrds = {...}
    for i,b in pairs(wrds) do 
        if par:match(tr(b)) then 
            return par:match(tr(b)) 
        end
    end
    return false
end


function repeatEvent(time, func, times,...)
    local ev = scheduleEvent(time, func,...)
    ev.rep = times 
    return ev
end

function scheduleEvent(time, func,...)
    if not sid then 
        sid = 1
    end
    sid = sid +1
    schedule[sid] = {time=time + os.time(),f=func,args={...},duration = time,rep=0}
    return sid
end

function stopEvent(id)
    local b = schedule[id]
    if b then
        schedule[id] = nil
    end
end

function setEventDuration(id, time)
    local b = schedule[id]
    if b then
        b.time = os.time() + time
        b.duration = time
    end
end

function triggerEvent(id)
    local b = schedule[id]
    if b then
        local ret, err =  xpcall(b.f, debug.traceback, unpack(b.args))
        if not ret then 
            say.admin("Error during on timer at: "..err)
            schedule[id] = nil
            return 
        end
        if b.rep > 0 then 
            b.time = os.time() + b.duration
            b.rep = b.rep -1
        else
            schedule[id] = nil
        end
    else 
        error("Unknown event: "..id.." - "..type(id))
    end
end

function string:explode(sep, limit)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for self in string.gmatch(self, "([^"..sep.."]+)") do
        t[i] = self
        i = i + 1
    end
    return t
end

function string:exploder(sep, limit)
    local val = self:explode(sep, limit)
    local outTable = {}
    local aux = ""
    for i,b in pairs(val) do 
        local repc, count = b:gsub("\"", "")
        
        if count%2 == 0 then 
            if aux:len() == 0 then 
                outTable[#outTable+1] = repc
            else 
                aux = aux .. " "..repc
            end
        else 
            if aux:len() == 0 then 
                aux = repc
            else 
                outTable[#outTable+1] = aux.." "..repc
                aux = ""
            end
        end
    end
    if aux:len() ~= 0 then 
        outTable[#outTable+1] = aux
    end
   
 return outTable
end

function makeSureCall(call, ...)
    local ret = call(...)
    print(Dump(ret))
    if ret and not ret.ok then 
        if ret.update and ret.update.error_code == 429 then 
            print("Rate limited for "..parameters.update.retry_after)
            local amount = parameters.update.retry_after
            print("Waiting~")
            ngx.sleep(amount)
            say.admin("Rate limited: "..Dump(ret))
            return makeSureCall(call, ...)
        end
    end
    return ret
end

function logText(chat, text)
    if not text then 
        return
    end
    text = tostring(text)
    local cname = tostring(chat)
    if chat == -1 then 
        cname = "commands"
    end
    local f = io.open("logs/"..cname..".txt", "a+")
    if not f then 
        f = io.open("logs/"..cname..".txt", "w")
    end
    if f then 
        f:write(text)
        f:close()
    end
end

function logMessage(msg, typ)
    if msg then  
        if msg.from and msg.chat and msg.chat.id and ( chats[msg.chat.id] and chats[msg.chat.id].data and chats[msg.chat.id].data.dolog) then 
           	local header = msg.message_id.." | ".. os.date("%d/%m/%y %H:%M:%S", tonumber(msg.date)) 


            local name =  "["..msg.from.id.."] " .. msg.from.first_name

            header = header.." | "..name..": "

            
            if msg.reply_to_message and msg.reply_to_message.from then 
                header = header.."{Reply to message "..msg.reply_to_message.message_id.."}: "
            end

            if msg.edit_date then 
            	header = header.."{Edidted message id "..msg.message_id.." at "..os.date("%d/%m/%y %H:%M:%S", tonumber(msg.edit_date)).."}: "
            end

            if msg.text then 
                logText(msg.chat.id, header..msg.text.."\r\n")
            elseif msg.sticker then
                logText(msg.chat.id, header.." Sticker pack "..(msg.sticker.set_name or "?").." | ".. msg.sticker.file_id.."\r\n")
            elseif msg.document then
            	logText(msg.chat.id, header.." Document  "..(msg.document.
mime_type or  "?").." | ".. msg.document.file_id.."\r\n")
            elseif msg.photo then
                logText(msg.chat.id, header.." Photo fileid "..(( (msg.photo[4] or msg.photo[3] or msg.photo[2] or msg.photo[1]).file_id) or "unknow error" ).."\r\n")
            elseif msg.new_chat_participant then
                logText(msg.chat.id, header.." New member "..Dump(msg.new_chat_participant).."\r\n")
			end
        end
    end
end





function collapse_command(args)
    local s = ""
    for i=2, #args do 
        s = s ..(#s > 0 and " " or "") .. args[i]
    end
    return s
end


function httpsRequest(uri, mthd, body, headers)
    -- Single-shot requests use the `request_uri` interface.
    local httpcon = require("resty.http").new()
    local res, err = httpcon:request_uri(uri, {
        method = mthd or 'GET',
        ssl_verify=false,
        body=body,
        headers=headers
    })
    httpcon:close()
    if not res then
        ngx.log(ngx.ERR, "request failed: ", err)
        return nil
    end
    return res.body, res.status
end


