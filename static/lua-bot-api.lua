--[[

lua-bot-api.lua - A Lua library to the Telegram Bot API
(https://core.telegram.org/bots/api)

Copyright (C) 2016 @cosmonawt

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.286

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

]]



local encode = require("multipart.multipart-post").encode
local JSON = require("JSON")
local cjson = require("cjson")

 
local httpc = require("resty.http").new()
local updateHttp


local M = {} -- Main Bot Framework
local E = {} -- Extension Framework
local C = {} -- Configure Constructor


M.g_updates = 0
M.offset = 0
-- JSON Error handlers
function JSON:onDecodeError(message, text, location, etc)
  if text then
    if location then
      message = string.format("%s at char %d of: %s", message, location, text)
    else
      message = string.format("%s: %s", message, text)
    end
  end
  --print((os.date("%x %X")), "Error while decoding JSON:\n", message)
  local datefile = os.date("%d-%m-%Y.txt")
  print((os.date("%x %X")), "Error: decode JSON, logged in ".. datefile)
  local log = io.open("errors/" .. datefile,"a+") -- open log
  log:write((os.date("%x %X")), "Error while decoding JSON:\n", message .. "\n") -- write in log
  log:close()
          
end

function JSON:onDecodeOfHTMLError(message, text, _nil, etc)
  if text then
    if location then
      message = string.format("%s at char %d of: %s", message, location, text)
    else
      message = string.format("%s: %s", message, text)
    end
  end
  --print((os.date("%x %X")), "Error while decoding JSON [HTML]:\n", message)
  local datefile = os.date("%d-%m-%Y.txt")
  print((os.date("%x %X")), "Error: decode JSON [HTML], logged in ".. datefile)
  local log = io.open("errors/" .. datefile,"a+") -- open log
  log:write((os.date("%x %X")), "Error while decoding JSON [HTML]:\n", message .. "\n") -- write in log
  log:close()
end

function JSON:onDecodeOfNilError(message, _nil, _nil, etc)
  if text then
    if location then
      message = string.format("%s at char %d of: %s", message, location, text)
    else
      message = string.format("%s: %s", message, text)
    end
  end
  print((os.date("%x %X")), "Error while decoding JSON [nil]:\n", message)
end

function JSON:onEncodeError(message, etc)
  print((os.date("%x %X")), "Error while encoding JSON:\n", message)
end

-- configure and initialize bot
local function configure(token)



  if (token == "") then
    token = nil
  end
  --print("COnfiguring ", token)

  M.token = assert(token, "No token specified!")



  M.requests = {}
  M.scheduled = {}
  M.requestCounter = 0
  M.warnScheduled = os.time()


  local bot_info = M.getMe()
  if (bot_info) then
    M.id = bot_info.result.id
    M.username = bot_info.result.username
    M.first_name = bot_info.result.first_name
  end
  return M, E
end

C.configure = configure

function getHttpConnection( makenew)
  local connModule = httpc
  local wasNew = false
  if g_newhttpc or makenew then 
      connModule = require("resty.http").new()
      g_newhttpc = false
      wasNew = true
  end
  local obj = {connModule, wasNew}
  function obj:close()
      if self[2] then 
        self[1]:close()
      end
  end

  function obj:request_uri(...)
      return self[1]:request_uri(...)
  end

  function obj:keep_alive()
      self[2] = true
  end

  return obj
end

function schedule_request(method, body, location)
  M.scheduled[M.requestCounter] = {
    method, body, os.time()+10, location
  }
end


function run_scheduled()
  local schdN = 0
  for i,b in pairs(M.scheduled) do 
    schdN = schdN +1
    if b[3] <= os.time() then 
      makeRequest(b[1], b[2])
      M.scheduled[i] = nil
      break
    end  
  end

  if schdN > 0 then 
    print("Total of "..schdN.. " scheduled messages")
    if M.warnScheduled < os.time() then 
      M.warnScheduled = os.time()+10
      E.onScheduleWarning(M.scheduled)
    end
  end
end


function makeRequest(method, body_arg, forceHttpConn, disableSchedule)
  local body, boundary = encode(body_arg)

  local connModule = getHttpConnection(true)

  local pre = ngx.now()

  local res, err,a,c = connModule:request_uri("https://api.telegram.org/bot"..M.token.."/" .. method, {
      method = "POST",
      body = body,
      ssl_verify=false,
      headers = {
          ["Content-Type"] =  "multipart/form-data; boundary=" .. boundary,
          ["Content-Length"] = string.len(body),
      },
  })
  

  connModule:close()

  local post = ngx.now() - pre 
  M.requests[(M.requestCounter%10) + 1] = post
  M.requestCounter = M.requestCounter + 1
  


  
  if not res then
    ngx.log(ngx.ERR, "request failed: ", err)
    local r = {
      success = "false",
      code = res.status or "0",
      headers =  {"no headers"},
      status = res.status or "0",
      body = '{"no response"}',
    }
    return r
  end


  local bdjs = cjson.decode(res.body or '{"no response"}')

  if bdjs.error_code == 429 and not disableSchedule then 
    schedule_request(method, body_arg, debug.traceback())
  end

  local r = {
    success = 1,
    code = res.status or "0",
    headers = table.concat(res.headers or {"no headers"}),
    status = res.status or "0",
    body = bdjs or '{"no response"}',
  }

  return r
  
end

local function getFile(file_id)

  if not file_id then return nil, "file_id not specified" end

  local request_body = {}

  request_body.file_id = file_id

  local response = makeRequest("getFile",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.getFile = getFile


local function getUpdatesCount()

  return M.g_updates
end

M.getUpdatesCount = getUpdatesCount


local function getRequestDuration()
  if #M.requests == 0 then 
    return -1
  end
  local avg = 0
  for i=1, #M.requests do 
    avg = avg + M.requests[i]
  end
  return avg / #M.requests
end

M.getRequestDuration = getRequestDuration
-- Helper functions

local function downloadFile(file_id, download_path)

  if not file_id then return nil, "file_id not specified" end
  if not download_path then return nil, "download_path not specified" end

  local response = {}

  local file_info = getFile(file_id)

 
  local download_file_path = download_path or "downloads/" .. file_info.result.file_path

  local download_file = io.open(download_file_path, "w")

  if not download_file then return nil, "download_file could not be created"
  else

    local connModule = getHttpConnection(true)
    
    local res, err = connModule:request_uri("https://api.telegram.org/file/bot"..M.token.."/" .. file_info.result.file_path, {
      method = "GET",
      ssl_verify=false,
    })
    if not res then 
      ngx.log(ngx.ERR, "request failed: ", err)
      local r = {
          success = false,
          description = err
      }
    end

    if res.status ~= 200 then 
      return JSON:decode(res.body)
    end

    connModule:close()  
    download_file:write(res.body)
    download_file:close()

    if res then 
      local r = {
          success = true,
          download_path = download_file_path,
          file = file_info.result
      }
      return r
    else 
      local r = {
        success = false, 
      }
    end
  end
end

M.downloadFile = downloadFile

local function generateReplyKeyboardMarkup(keyboard, resize_keyboard, one_time_keyboard, selective)

  if not keyboard then return nil, "keyboard not specified" end
  if #keyboard < 1 then return nil, "keyboard is empty" end

  local response = {}

  response.keyboard = keyboard
  response.resize_keyboard = resize_keyboard
  response.one_time_keyboard = one_time_keyboard
  response.selective = selective


  local responseString = JSON:encode(response)
  return responseString
end

M.generateReplyKeyboardMarkup = generateReplyKeyboardMarkup


local function generateReplyKeyboardHide(hide_keyboard, selective)

  local response = {}

  response.hide_keyboard = true
  response.selective = selective

  local responseString = JSON:encode(response)
  return responseString
end

M.generateReplyKeyboardHide = generateReplyKeyboardHide


local function generateForceReply(force_reply, selective)

  local response = {}

  response.force_reply = true
  response.selective = selective

  local responseString = JSON:encode(response)
  return responseString
end

M.generateForceReply = generateForceReply

-- Bot API 1.0

local function getUpdates(offset, limit, timeout, allowed_updates)
 
  local request_body = {}

  request_body.offset = offset
  request_body.limit = limit
  request_body.timeout = timeout or 0
  request_body.allowed_updates = allowed_updates or nil


  local response =  makeRequest("getUpdates", request_body, false)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.getUpdates = getUpdates


local function getMe()
  local request_body = {""}

  local response = makeRequest("getMe",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.getMe = getMe


local function sendMessage(chat_id, text, parse_mode, disable_web_page_preview, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not text then return nil, "text not specified" end

  local allowed_parse_mode = {
    ["Markdown"] = true,
    ["HTML"] = true
  }

  if (not allowed_parse_mode[parse_mode]) then parse_mode = "" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.text = tostring(text)
  request_body.parse_mode = parse_mode
  request_body.disable_web_page_preview = tostring(disable_web_page_preview)
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup or ""

  local response = makeRequest("sendMessage",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendMessage = sendMessage

local function setChatPhoto(chat_id, filename)


  local request_body = {}

  request_body.chat_id = chat_id


  local photo_data = {}

  
  local photo_file = io.open(filename, "r")
  if not photo_file then return false, "Error, no such file" end

  request_body["photo"] = {
    filename = filename,
    data = photo_file:read("*a"),
  }

  photo_file:close()

  local response = makeRequest("setChatPhoto",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.setChatPhoto = setChatPhoto


local function banChatSenderChat(chat_id, message_id)

   local request_body = {}

  request_body.chat_id = chat_id
  request_body.sender_chat_id = sender_chat_id


  local response = makeRequest("banChatSenderChat",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.banChatSenderChat = banChatSenderChat

local function unbanChatSenderChat(chat_id, message_id)

   local request_body = {}

  request_body.chat_id = chat_id
  request_body.sender_chat_id = sender_chat_id


  local response = makeRequest("unbanChatSenderChat",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.unbanChatSenderChat = unbanChatSenderChat

local function approveChatJoinRequest(chat_id, message_id)

   local request_body = {}

  request_body.chat_id = chat_id
  request_body.user_id = user_id


  local response = makeRequest("approveChatJoinRequest",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.approveChatJoinRequest = approveChatJoinRequest

local function declineChatJoinRequest(chat_id, message_id)

   local request_body = {}

  request_body.chat_id = chat_id
  request_body.user_id = user_id


  local response = makeRequest("declineChatJoinRequest",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

local function setMyCommands(chat_id, message_id)

   local request_body = {}

  request_body.commands = commands
  request_body.scope = scope
  request_body.language_code = language_code


  local response = makeRequest("setMyCommands",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.setMyCommands = setMyCommands


local function deleteMyCommands(chat_id, message_id)

   local request_body = {}

  request_body.scope = scope
  request_body.language_code = language_code


  local response = makeRequest("deleteMyCommands",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.deleteMyCommands = deleteMyCommands

local function getMyCommands(chat_id, message_id)

   local request_body = {}

  request_body.scope = scope
  request_body.language_code = language_code


  local response = makeRequest("getMyCommands",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.getMyCommands = getMyCommands


local function unpinChatMessage(chat_id, message_id)

   local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = message_id
  request_body.disable_notification = disable_notification

  local response = makeRequest("unpinChatMessage",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.unpinChatMessage = unpinChatMessage

local function createChatInviteLink(chat_id, expire_date)

   local request_body = {}

  request_body.chat_id = chat_id
  request_body.expire_date = expire_date
  request_body.member_limit = member_limit

  local response = makeRequest("createChatInviteLink",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end 

M.createChatInviteLink = createChatInviteLink

local function pinChatMessage(chat_id, message_id, disable_notification)

   local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = message_id
  request_body.disable_notification = disable_notification

  local response = makeRequest("pinChatMessage",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.pinChatMessage = pinChatMessage


local function setChatTitle(chat_id,title)

   local request_body = {}

  request_body.chat_id = chat_id
  request_body.title = title

  local response = makeRequest("setChatTitle",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.setChatTitle = setChatTitle

local function restrictChatMember(chat_id, user_id, until_date, can_send_media_messages, can_send_other_messages, can_add_web_page_previews,can_send_messages)
  if not chat_id then return nil, "chat_id not specified" end
  if not user_id then return nil, "user_id not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.user_id = tonumber(user_id)
  request_body.until_date = tonumber(until_date) or 0
  request_body.can_send_messages = tostring(can_send_messages)
  request_body.can_send_media_messages = tostring(can_send_media_messages)
  request_body.can_send_other_messages = tostring(can_send_other_messages)
  request_body.can_add_web_page_previews = tostring(can_add_web_page_previews)
  
  local response = makeRequest("restrictChatMember",request_body)

    if (response.success == 1) then
      return response.body
    else
      return nil, "Request Error"
  end
end

M.restrictChatMember = restrictChatMember

local function createNewStickerSet(user_id, name, title, png_sticker, emojis, contains_masks)

   local request_body = {}

  --print(debug.traceback())

  request_body.user_id = user_id
  request_body.name = name
  request_body.title = title
  request_body.png_sticker = png_sticker
  request_body.emojis = emojis
  request_body.contains_masks = contains_masks

  local response = makeRequest("createNewStickerSet",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.createNewStickerSet = createNewStickerSet


local function addStickerToSet(user_id, name, png_sticker, emojis, contains_masks)

   local request_body = {}

  --print(debug.traceback())

  request_body.user_id = user_id
  request_body.name = name
  request_body.png_sticker = png_sticker
  request_body.emojis = emojis
  request_body.contains_masks = tostring(contains_masks)

  local response = makeRequest("addStickerToSet",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.addStickerToSet = addStickerToSet



local function deleteMessage(chat_id, message_id)

   local request_body = {}

  --print(debug.traceback())

  request_body.chat_id = chat_id
  request_body.message_id = message_id

  local response = makeRequest("deleteMessage",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.deleteMessage = deleteMessage

local function forwardMessage(chat_id, from_chat_id, disable_notification, message_id)

  if not chat_id then return nil, "chat_id not specified" end
  if not from_chat_id then return nil, "from_chat_id not specified" end
  if not message_id then return nil, "message_id not specified" end

  local request_body = {""}

  request_body.chat_id = chat_id
  request_body.from_chat_id = from_chat_id
  request_body.disable_notification = tostring(disable_notification)
  request_body.message_id = tonumber(message_id)

  local response = makeRequest("forwardMessage",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.forwardMessage = forwardMessage


local function sendPhoto(chat_id, photo, caption, disable_notification, reply_to_message_id, reply_markup, parse)

  if not chat_id then return nil, "chat_id not specified" end
  if not photo then return nil, "photo not specified" end

  local request_body = {""}
  local file_id = ""
  local photo_data = {}

  if not(string.find(photo, "%.")) then
    file_id = photo
  else
    file_id = nil
    local photo_file = io.open(photo, "r")

    photo_data.filename = photo
    photo_data.data = photo_file:read("*a")
    photo_data.content_type = "image"

    photo_file:close()
  end

  request_body.parse_mode = parse
  request_body.chat_id = chat_id
  request_body.photo = file_id or photo_data
  request_body.caption = caption
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendPhoto",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendPhoto = sendPhoto


local function sendAudio(chat_id, audio, caption, duration, performer, title, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not audio then return nil, "audio not specified" end

  local request_body = {}
  local file_id = ""
  local audio_data = {}

  if not(string.find(audio, "%.mp3")) then
    file_id = audio
  else
    file_id = nil
    local audio_file = io.open(audio, "r")

    audio_data.filename = audio
    audio_data.data = audio_file:read("*a")
    audio_data.content_type = "audio/mpeg"

    audio_file:close()
  end

  request_body.chat_id = chat_id
  request_body.audio = file_id or audio_data
  request_body.duration = duration
  request_body.caption = caption
  request_body.performer = performer
  request_body.title = title
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendAudio",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendAudio = sendAudio


local function sendDocument(chat_id, document, caption, disable_notification, reply_to_message_id, reply_markup,parse_mode)

  if not chat_id then return nil, "chat_id not specified" end
  if not document then return nil, "document not specified" end

  local request_body = {}
  local file_id = ""
  local document_data = {}

  if not(string.find(document, "%.")) then
    file_id = document
  else
    file_id = nil
    local document_file = io.open(document, "r")

    document_data.filename = document
    document_data.data = document_file:read("*a")

    document_file:close()
  end

  request_body.chat_id = chat_id
  request_body.document = file_id or document_data
  request_body.caption = caption
  request_body.parse_mode = parse_mode
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendDocument",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendDocument = sendDocument


local function sendSticker(chat_id, sticker, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not sticker then return nil, "sticker not specified" end

  local request_body = {}
  local file_id = ""
  local sticker_data = {}

  if not(string.find(sticker, "%.png") or string.find(sticker, "%.webp")) then
    file_id = sticker
  else
    file_id = nil
    local sticker_file = io.open(sticker, "r")
    print("uwu")
    sticker_data.filename = sticker
    sticker_data.data = sticker_file:read("*a")
    if string.find(sticker, "%.webp") then
      sticker_data.content_type = "image/webp"
    end

    sticker_file:close()



  end

  request_body.chat_id = chat_id
  request_body.sticker = file_id or sticker_data
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendSticker",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendSticker = sendSticker


local function sendVideo(chat_id, video, duration, caption, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not video then return nil, "video not specified" end

  local request_body = {}
  local file_id = ""
  local video_data = {}

  if not(string.find(video, "%.")) then
    file_id = video
  else
    file_id = nil
    local video_file = io.open(video, "r")

    video_data.filename = video
    video_data.data = video_file:read("*a")
    video_data.content_type = "video"

    video_file:close()
  end

  request_body.chat_id = chat_id
  request_body.video = file_id or video_data
  request_body.duration = duration
  request_body.caption = caption
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendVideo",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendVideo = sendVideo


local function sendVoice(chat_id, voice, caption, duration, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not voice then return nil, "voice not specified" end

  local request_body = {}
  local file_id = ""
  local voice_data = {}

  if not(string.find(voice, "%.ogg")) then
    file_id = voice
  else
    file_id = nil
    local voice_file = io.open(voice, "r")

    voice_data.filename = voice
    voice_data.data = voice_file:read("*a")
    voice_data.content_type = "audio/ogg"

    voice_file:close()
  end

  request_body.chat_id = chat_id
  request_body.voice = file_id or voice_data
  request_body.duration = duration
  request_body.caption = caption
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendVoice",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendVoice = sendVoice

local function sendLocation(chat_id, latitude, longitude, disable_notification, reply_to_message_id, reply_markup)

  if not chat_id then return nil, "chat_id not specified" end
  if not latitude then return nil, "latitude not specified" end
  if not longitude then return nil, "longitude not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.latitude = tonumber(latitude)
  request_body.longitude = tonumber(longitude)
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendLocation",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendLocation = sendLocation

local function sendChatAction(chat_id, action)

  if not chat_id then return nil, "chat_id not specified" end
  if not action then return nil, "action not specified" end

  local request_body = {}

  local allowedAction = {
    ["typing"] = true,
    ["upload_photo"] = true,
    ["record_video"] = true,
    ["upload_video"] = true,
    ["record_audio"] = true,
    ["upload_audio"] = true,
    ["upload_document"] = true,
    ["find_location"] = true,
  }

  if (not allowedAction[action]) then action = "typing" end

  request_body.chat_id = chat_id
  request_body.action = action

  local response = makeRequest("sendChatAction",request_body, nil, true)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendChatAction = sendChatAction

local function getUserProfilePhotos(user_id, offset, limit)

  if not user_id then return nil, "user_id not specified" end

  local request_body = {}

  request_body.user_id = tonumber(user_id)
  request_body.offset = offset
  request_body.limit = limit

  local response = makeRequest("getUserProfilePhotos",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.getUserProfilePhotos = getUserProfilePhotos



local function answerInlineQuery(inline_query_id, results, cache_time, is_personal, next_offset, switch_pm_text, switch_pm_parameter)

  if not inline_query_id then return nil, "inline_query_id not specified" end
  if not results then return nil, "results not specified" end

  local request_body = {}

  request_body.inline_query_id = tostring(inline_query_id)
  request_body.results = JSON:encode(results)
  request_body.cache_time = tonumber(cache_time)
  request_body.is_personal = tostring(is_personal)
  request_body.next_offset = tostring(next_offset)
  request_body.switch_pm_text = tostring(switch_pm_text)
  request_body.switch_pm_parameter = tostring(switch_pm_text)

  local response = makeRequest("answerInlineQuery",request_body, nil, true)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.answerInlineQuery = answerInlineQuery

-- Bot API 2.0

local function sendVenue(chat_id, latitude, longitude, title, adress, foursquare_id, disable_notification, reply_to_message_id, reply_markup)
  
  if not chat_id then return nil, "chat_id not specified" end
  if not latitude then return nil, "latitude not specified" end
  if not longitude then return nil, "longitude not specified" end
  if not title then return nil, "title not specified" end
  if not adress then return nil, "adress not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.latitude = tonumber(latitude)
  request_body.longitude = tonumber(longitude)
  request_body.title = title
  request_body.adress = adress
  request_body.foursquare_id = foursquare_id
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendVenue",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendVenue = sendVenue

local function sendContact(chat_id, phone_number, first_name, last_name, disable_notification, reply_to_message_id, reply_markup)
  
  if not chat_id then return nil, "chat_id not specified" end
  if not phone_number then return nil, "phone_number not specified" end
  if not first_name then return nil, "first_name not specified" end
 
  request_body.chat_id = chat_id
  request_body.phone_number = tostring(phone_number)
  request_body.first_name = tostring(first_name)
  request_body.last_name = tostring(last_name)
  request_body.disable_notification = tostring(disable_notification)
  request_body.reply_to_message_id = tonumber(reply_to_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("sendContact",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.sendContact = sendContact

local function kickChatMember(chat_id, user_id, until_date, revoke_messages)
  if not chat_id then return nil, "chat_id not specified" end
  if not user_id then return nil, "user_id not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.user_id = tonumber(user_id)
  request_body.until_date = tonumber(until_date) or 0
  request_body.revoke_messages = tostring(revoke_messages)
  
  local response = makeRequest("kickChatMember",request_body)

    if (response.success == 1) then
      return response.body
    else
      return nil, "Request Error"
  end
end

M.kickChatMember = kickChatMember


local function banChatMember(chat_id, user_id, until_date, revoke_messages)
  if not chat_id then return nil, "chat_id not specified" end
  if not user_id then return nil, "user_id not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.user_id = tonumber(user_id)
  request_body.until_date = tonumber(until_date) or 0
  request_body.revoke_messages = tostring(revoke_messages)
  
  local response = makeRequest("banChatMember",request_body)

    if (response.success == 1) then
      return response.body
    else
      return nil, "Request Error"
  end
end

M.banChatMember = banChatMember

local function unbanChatMember(chat_id, user_id)
  if not chat_id then return nil, "chat_id not specified" end
  if not user_id then return nil, "user_id not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.user_id = tonumber(user_id) 
  
  local response = makeRequest("unbanChatMember",request_body)

    if (response.success == 1) then
      return response.body
    else
      return nil, "Request Error"
  end
end

M.unbanChatMember = unbanChatMember

local function answerCallbackQuery(callback_query_id, text, show_alert, cache_time, url)

  if not callback_query_id then return nil, "callback_query_id not specified" end

  local request_body = {}

  request_body.callback_query_id = tostring(callback_query_id)
  request_body.text = text
  request_body.show_alert = tostring(show_alert)
  request_body.cache_time = tostring(cache_time)
  request_body.url = url
  
  local response = makeRequest("answerCallbackQuery",request_body, nil, true)

    if (response.success == 1) then
      return response.body
    else
      return nil, "Request Error"
  end
end

M.answerCallbackQuery = answerCallbackQuery

local function editMessageText(chat_id, message_id, inline_message_id, text, parse_mode, disable_web_page_preview, reply_markup)
  
  if not chat_id and not inline_message_id then return nil, "chat_id not specified" end
  if not message_id and not inline_message_id then return nil, "message_id not specified" end
  if not inline_message_id and not (chat_id and message_id) then return nil, "inline_message_id not specified" end
  if not text then return nil, "text not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = tonumber(message_id)
  request_body.inline_message_id = tostring(inline_message_id)
  request_body.text = tostring(text)
  request_body.parse_mode = parse_mode
  request_body.disable_web_page_preview = disable_web_page_preview
  request_body.reply_markup = reply_markup

  local response = makeRequest("editMessageText",request_body, nil, true)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.editMessageText = editMessageText

local function editMessageCaption(chat_id, message_id, inline_message_id, caption, reply_markup, parse_mode)
  
  if not chat_id and not inline_message_id then return nil, "chat_id not specified" end
  if not message_id and not inline_message_id then return nil, "message_id not specified" end
  if not inline_message_id and not (chat_id and message_id) then return nil, "inline_message_id not specified" end
  if not caption then return nil, "caption not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = tonumber(message_id)
  request_body.inline_message_id = tostring(inline_message_id)
  request_body.caption = tostring(caption)
  request_body.parse_mode = parse_mode
  request_body.reply_markup = reply_markup

  local response = makeRequest("editMessageCaption",request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.editMessageCaption = editMessageCaption

local function editMessageReplyMarkup(chat_id, message_id, inline_message_id, reply_markup)
  
  if not chat_id and not inline_message_id then return nil, "chat_id not specified" end
  if not message_id and not inline_message_id then return nil, "message_id not specified" end
  if not inline_message_id and not (chat_id and message_id) then return nil, "inline_message_id not specified" end

  local request_body = {}

  request_body.chat_id = chat_id
  request_body.message_id = tonumber(message_id)
  request_body.inline_message_id = tostring(inline_message_id)
  request_body.reply_markup = reply_markup

  local response = makeRequest("editMessageReplyMarkup",request_body, false, true)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.editMessageReplyMarkup = editMessageReplyMarkup

-- Bot API 2.1

local function getChat(chat_id)

  if not chat_id then return nil, "chat_id not specified" end

  local request_body = {}
  request_body.chat_id = chat_id

  local response = makeRequest("getChat", request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.getChat = getChat

local function leaveChat(chat_id)

  if not chat_id then return nil, "chat_id not specified" end

  local request_body = {}
  request_body.chat_id = chat_id

  local response = makeRequest("leaveChat", request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.leaveChat = leaveChat

local function getChatAdministrators(chat_id)

  if not chat_id then return nil, "chat_id not specified" end

  local request_body = {}
  request_body.chat_id = chat_id

  local response = makeRequest("getChatAdministrators", request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.getChatAdministrators = getChatAdministrators

local function getChatMembersCount(chat_id)

  if not chat_id then return nil, "chat_id not specified" end

  local request_body = {}
  request_body.chat_id = chat_id

  local response = makeRequest("getChatMembersCount", request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.getChatMembersCount = getChatMembersCount

local function deleteChatPhoto(chat_id)

  if not chat_id then return nil, "chat_id not specified" end

  local request_body = {}
  request_body.chat_id = chat_id

  local response = makeRequest("deleteChatPhoto", request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.deleteChatPhoto = deleteChatPhoto

local function getChatMember(chat_id, user_id)

  if not chat_id then return nil, "chat_id not specified" end
  if not user_id then return nil, "user_id not specified" end


  local request_body = {}
  request_body.chat_id = chat_id
  request_body.user_id = user_id

  local response = makeRequest("getChatMember", request_body)

  if (response.success == 1) then
    return response.body
  else
    return nil, "Request Error"
  end
end

M.getChatMember = getChatMember

-- Extension Framework

local function onUpdateReceive(update) end
E.onUpdateReceive = onUpdateReceive

local function onTextReceive(message) end
E.onMessageReceive = onMessageReceive

local function onPhotoReceive(message) end
E.onPhotoReceive = onPhotoReceive

local function onAudioReceive(message) end
E.onAudioReceive = onAudioReceive

local function onDocumentReceive(message) end
E.onDocumentReceive = onDocumentReceive

local function onStickerReceive(message) end
E.onStickerReceive = onStickerReceive

local function onVideoReceive(message) end
E.onVideoReceive = onVideoReceive

local function onScheduleWarning(message) end
E.onScheduleWarning = onScheduleWarning

local function onVoiceReceive(message) end
E.onVoiceReceive = onVoiceReceive

local function onContactReceive(message) end
E.onContactReceive = onContactReceive

local function onLocationReceive(message) end
E.onLocationReceive = onLocationReceive

local function onLeftChatParticipant(message) end
E.onLeftChatParticipant = onLeftChatParticipant

local function onNewChatParticipant(message) end
E.onNewChatParticipant = onNewChatParticipant

local function onNewChatTitle(message) end
E.onNewChatTitle = onNewChatTitle

local function onNewChatPhoto(message) end
E.onNewChatPhoto = onNewChatPhoto

local function onNewChatTitle(message) end
E.onNewChatTitle = onNewChatTitle

local function onDeleteChatPhoto(message) end
E.onDeleteChatPhoto = onDeleteChatPhoto

local function onGroupChatCreated(message) end
E.onGroupChatCreated = onGroupChatCreated

local function onSupergroupChatCreated(message) end
E.onsuperGroupChatCreated = onsuperGroupChatCreated

local function onChannelChatCreated(message) end
E.onChannelChatCreated = onChannelChatCreated

local function onMigrateToChatId(message) end
E.onMigrateToChatId = onMigrateToChatId

local function onMigrateFromChatId(message) end
E.onMigrateFromChatId = onMigrateFromChatId

local function onEditedMessageReceive(message) end
E.onEditedMessageReceive = onEditedMessageReceive

local function onInlineQueryReceive(inlineQuery) end
E.onInlineQueryReceive = onInlineQueryReceive

local function onChosenInlineQueryReceive(chosenInlineQuery) end
E.onChosenInlineQueryReceive = onChosenInlineQueryReceive

local function onCallbackQueryReceive(CallbackQuery) end
E.onCallbackQueryReceive = onCallbackQueryReceive

local function onChannelPost(post) end
E.onChannelPost = onChannelPost

local function onChannelEditPost(post) end
E.onChannelEditPost = onChannelEditPost 

function onUpdateChatMember(post) end
E.onUpdateChatMember = onUpdateChatMember

function onDiceReceive(post) end
E.onDiceReceive = onDiceReceive

function onPollReceive(post) end
E.onPollReceive = onPollReceive


function onDiceReceive(post) end
E.onDiceReceive = onDiceReceive

function onPollAwnswerReceive(post) end
E.onPollAwnswerReceive = onPollAwnswerReceive


local function onUnknownTypeReceive(unknownType)
  print("New type as:")
  for i,b in pairs(unknownType) do 
    print(i,"=",tostring(b))
    if type(b) == "table" then 
      for a,c in pairs(b) do 
        print("-"..a.."="..tostring(c))
      end
    end
  end
end
E.onUnknownTypeReceive = onUnknownTypeReceive

local function parseUpdateCallbacks(update)


  if (update) then
    E.onUpdateReceive(update)
  end
  if (update.message) then
    if (update.message.text) then
      E.onTextReceive(update.message)
    elseif (update.message.photo) then
      E.onPhotoReceive(update.message)
    elseif (update.message.audio) then
      E.onAudioReceive(update.message)
    elseif (update.message.document) then
      E.onDocumentReceive(update.message)
    elseif (update.message.sticker) then
      E.onStickerReceive(update.message)
    elseif (update.message.video) then
      E.onVideoReceive(update.message)
    elseif (update.message.voice) then
      E.onVoiceReceive(update.message)
    elseif (update.message.contact) then
      E.onContactReceive(update.message)
    elseif (update.message.location) then
      E.onLocationReceive(update.message)
    elseif (update.message.left_chat_participant) then
      E.onLeftChatParticipant(update.message)
    elseif (update.message.new_chat_participant) then
      E.onNewChatParticipant(update.message)
    elseif (update.message.old_chat_member) then
      E.onOldChatMember(update.message)
    elseif (update.message.new_chat_photo) then
      E.onNewChatPhoto(update.message)  
     elseif (update.message.new_chat_title) then
      E.onNewChatTitle(update.message)
    elseif (update.message.delete_chat_photo) then
      E.onDeleteChatPhoto(update.message)
    elseif (update.message.group_chat_created) then
      E.onGroupChatCreated(update.message)
    elseif (update.message.supergroup_chat_created) then
      E.onSupergroupChatCreated(update.message)
    elseif (update.message.channel_chat_created) then
      E.onChannelChatCreated(update.message)
    elseif (update.message.migrate_to_chat_id) then
      E.onMigrateToChatId(update.message)
    elseif (update.message.migrate_from_chat_id) then
      E.onMigrateFromChatId(update.message)    
    elseif (update.message.dice) then
      E.onDiceReceive(update.message)    
    elseif (update.message.poll_answer) then
      E.onPollAwnswerReceive(update.message)    
    elseif (update.message.poll) then
      E.onPollReceive(update.message)
    else
      E.onUnknownTypeReceive(update)
    end
  elseif (update.edited_message) then
    E.onEditedMessageReceive(update.edited_message)
  elseif (update.inline_query) then
    E.onInlineQueryReceive(update.inline_query)
  elseif (update.chosen_inline_result) then
    E.onChosenInlineQueryReceive(update.chosen_inline_result)
  elseif (update.callback_query) then
    E.onCallbackQueryReceive(update.callback_query)
  elseif (update.channel_post) then
    E.onChannelPost(update.channel_post)
  elseif (update.edited_channel_post) then
    E.onChannelEditPost(update.edited_channel_post)
  elseif (update.my_chat_member) then
    E.onUpdateChatMember(update.my_chat_member)
  else
    E.onUnknownTypeReceive(update)
  end
end


local function processFrame(obj, limit, timeout, rst, n, hook)
  local ret,updates = pcall(obj.getUpdates, obj.offset, limit, timeout)
    rst[n] = os.clock()
    if not ret then
      print("Errrr",updates)
    else
      if(updates) then
        if (updates.result) then
          for key, update in pairs(updates.result) do

            obj.g_updates = obj.g_updates +1
            parseUpdateCallbacks(update)
            obj.offset = update.update_id + 1
            if hook then hook() end
          end
        end
      end
    end
end


local function run(limit, timeout, hook)
  if limit == nil then limit = 1 end
  if timeout == nil then timeout = 0 end
  M.timers = {}
  M.ctr = {[0]=0,[1]=0,[2]=0,[3]=0}
  M.final = {[0]=0,[1]=0,[2]=0,[3]=0}

  while true do 
      M.timers[0] = os.clock()


      processFrame(M,limit, timeout, M.timers, 1, hook)

      M.ctr[1] = M.ctr[1]+ (os.clock() - M.timers[1])
      M.timers[2] = os.clock()
      

      M.ctr[2] = M.ctr[2] +  (os.clock() - M.timers[2])

      if hook then hook() end
      
      M.timers[3] = os.clock()
      
      M.ctr[3] = M.ctr[3] +  (os.clock() - M.timers[3])

      --print(M.timers[0], M.ctr[0])

      M.ctr[0] = M.ctr[0] +  (os.clock() - M.timers[0])
      if M.ctr[0] > 0 then
        M.final[1] = M.ctr[1]/M.ctr[0]
        M.final[2] = M.ctr[2]/M.ctr[0]
        M.final[3] = M.ctr[3]/M.ctr[0]
      end


      run_scheduled()

  end


end
E.processFrame = processFrame
E.run = run

return C

