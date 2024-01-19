local ads = {
	selection = {},
	ads = {},
	ads_nsfw = {},
	expired_ads = {}
}
local JSON = require("JSON")

--[ONCE] runs when the load is finished
function ads.load()
	if pubsub then
		pubsub.registerExternalVariable("chat", "enable_ads", {type="boolean"}, true, "Enable Ads", "Ads", nil, function(chatid, key, index, val)
			chats[chatid].data.last_ad = os.time()
			return true
		end)

		pubsub.registerExternalVariable("chat", "nsfw_ads", {type="boolean"}, true, "Send NSFW ads", "Ads")
		pubsub.registerExternalVariable("chat", "group_ads", {type="boolean"}, true, "Only send ads from members the current group", "Ads")
		pubsub.registerExternalVariable("chat", "no_night_ads", {type="boolean"}, true, "Disable ads between 00:00 and 08:00", "Ads")
		pubsub.registerExternalVariable("chat", "ads_interval", {type="string", valid={"10 min", "30 min", "1 hour", "2 hours", "4 hours", "8 hours", "12 hours", "24 hours", "2 days", "7 days", "1 month"}, default="8 hours" }, true, "Ad interval", "Ads", nil, function(chatid, key, index, val)
			chats[chatid].data.ads_interval = val
			chats[chatid].data.last_ad = os.time() + ads.getAdDuration(chats[chatid])
			return true
		end)
	end
	ads.ads = configs["ads"] or {}
	ads.expired_ads = configs["expired_ads"] or {}
	ads.ads_nsfw = configs["ads_nsfw"] or {}
end

--Runs at the begin of the frame
function ads.frame()

end

function ads.onNewChat(msg, id)
	chats[msg.chat.id].data.enable_ads = true
end

--Runs some times
function ads.save()
	configs["ads"] = ads.ads
	configs["expired_ads"] = ads.expired_ads
	configs["ads_nsfw"] = ads.ads_nsfw
	saveConfig("ads")
	saveConfig("expired_ads")
	saveConfig("ads_nsfw")
end

function ads.loadCommands()
	addCommand( "createad"				, MODE_PRIVATEONLY, getModulePath().."/createad.lua", 2, "ads-command-createad"  )	
	addCommand( "toggle_ads"				, MODE_CHATADMS, getModulePath().."/toggle_ads.lua", 2, "ads-command-toggle"  )	
end

function ads.loadTranslation()
	g_locale[LANG_BR]["ads-command-createad"] = "Cria um anuncio"
	g_locale[LANG_US]["ads-command-createad"] = "Cria um anuncio"


	g_locale[LANG_BR]["ads-command-toggle"] = "Ativa/Desativa anuncios no chat"
	g_locale[LANG_US]["ads-command-toggle"] = "Ativa/Desativa anuncios no chat"

end

function ads.onCallbackQueryReceive(msg)
	if msg.data:match("ads:(.+)") then
		local data = msg.data:match("ads:(.+)")
		if data == "a" then
			deploy_answerCallbackQuery(msg.id, "Basta ir no privado do @burrsobot\ne digitar o comando /createad\nÉ e sempre será de graça!", "true")
			return
		elseif data == "c" then
			ads.selection[msg.from.id] = nil
			deploy_answerCallbackQuery(msg.id, "Ok!", "true")
			bot.sendMessage(msg.from.id, "Cancelado" , "HTML")
		elseif data == "1:y" then 
			ads.selection[msg.from.id] = {stage=1}
			deploy_answerCallbackQuery(msg.id, "Ok!", "true")
			bot.sendMessage(msg.from.id, [[Beleza! Vamos começar
O primeiro passo é enviar o seu anuncio para mim. No caso sua proxima mensagem aqui no meu privado será o anuncio.

Essa mensagem pode ser:
<code>
* Uma mensagem de texto
* Uma foto com uma descrição do que se trata
* Um gif com uma descrição do que se trata.
</code>

<b>Lembrando que se você enviar um album de fotos, eu vou considerar só a primeira foto</b>
Infelizmente é uma limitação do proprio telegram com os bots, então recomendo você escolher uma foto só ou fazer uma montagem e enviar uma foto só

Basta me enviar agora, estou esperando :D]] , "HTML")
		elseif data == "1:n" then 
			deploy_answerCallbackQuery(msg.id, "de boas", "true")
		elseif data == "2:y" then 
			ads.selection[msg.from.id].stage = 3
			deploy_answerCallbackQuery(msg.id, "Ok!", "true")
			local keyb = {}
			keyb[1] = {}
			keyb[2] = {}
			keyb[3] = {}
			keyb[1][1] = { text = "Sim, quero!", callback_data = "ads:3:y"} 
			keyb[2][1] = { text = "Não precisa", callback_data = "ads:3:n"} 
			keyb[3][1] = { text = "Cancelar", callback_data = "ads:c"} 
			local kb = cjson.encode({inline_keyboard = keyb })
			bot.sendMessage(msg.from.id, "Beleza. Você quer incluir um botão que leva para seu canal ou algo assim?" , "HTML", false, false, msg.message_id, kb)
		elseif data == "2:n" then 
			if not ads.selection[msg.from.id] then 
				deploy_answerCallbackQuery(msg.id, "whoopsie i did a fuckie wookie", "true")
				deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
				return
			end
			ads.selection[msg.from.id].stage = 1
			deploy_answerCallbackQuery(msg.id, "de boas", "true")
			bot.sendMessage(msg.from.id, "Envie o anuncio agora :>" , "HTML")
		elseif data == "3:y" then 
			ads.selection[msg.from.id].stage = 4
			deploy_answerCallbackQuery(msg.id, "uwu", "true")
			bot.sendMessage(msg.from.id, "Okay, mande ai o link do seu chat ou canal! Lembre de mandar no formato: https://t.me/<code>SEUCHAT</code>" , "HTML", false, false, msg.message_id, kb)
		elseif data == "3:n" then 
			deploy_answerCallbackQuery(msg.id, "owo", "true")
			ads.register_ad(msg, ads.selection[msg.from.id].ad)
			ads.selection[msg.from.id] = nil
		elseif data:match("rm:(%d+)") then
			local id = data:match("rm:(%d+)")
			id = tonumber(id)
			if ads.ads[id] then
				ads.ads[id] = nil
				bot.sendMessage(msg.from.id, "Ad deletado", "HTML", false, false, msg.message_id)
				ads.save()
			else
				bot.sendMessage(msg.from.id, "Ad deletado?", "HTML", false, false, msg.message_id)
			end
			deploy_answerCallbackQuery(msg.id, ":c")
		elseif data:match("r:(%d+)") then
			local id = data:match("r:(%d+)")
			id = tonumber(id)
			if ads.expired_ads[id] then 
				ads.ads[id] = ads.expired_ads[id]
				ads.ads[id].expiration = os.time()  + 3600* 24 * 7
				ads.expired_ads[id] = nil

				ads.sendAd(msg.from.id, ads.ads[id], true)
				deploy_answerCallbackQuery(msg.id, "uwu")
				bot.sendMessage(msg.from.id, "Anuncio renovado por mais 7 dias!" , "HTML", false, false, msg.message_id, kb)
				ads.save()
			else 
				deploy_answerCallbackQuery(msg.id, ":c")
				bot.sendMessage(msg.from.id, "Esse anuncio ja expirou a muito tempo ou você apertou o botão duas vezes. Se ja se passaram 24h des da mensagem que eu te enviei, então ele expirou e é melhor cadastrar outro")
			end
		end

		deploy_deleteMessage(msg.message.chat.id, msg.message.message_id)
	end
end

function ads.validate_message(msg, mode)
	if msg.from.id and msg.from.id == msg.chat.id and ads.selection[msg.from.id] then 
		if ads.selection[msg.from.id].stage == 1 then
			local htMEL = entitiesToHTML(msg)
			htMEL = htMEL or ""
			htMEL = htMEL .. "\n\nAnuncio por: "..formatUserHtml(msg.from)

			local ad = {type=mode, text = htMEL, ownerName = msg.from.username, owner_id=msg.from.id, deploys = 0}

			if mode == 'photo' then 
				ad.photo = msg.photo[1].file_id
			elseif mode == 'document' then 
				ad.document = msg.document.file_id
			end

			local resMsg = ads.sendAd(msg.chat.id, ad, true)
			if not resMsg or resMsg.ok == false then
				reply("Erro interno. Tente novamente, talvez alterando o ad? Se ainda sim estiver errado contate @mockthebear")
				return
			end

			

			ads.selection[msg.from.id].ad = ad
			ads.selection[msg.from.id].stage = 2

			local keyb = {}
			keyb[1] = {}
			keyb[2] = {}
			keyb[3] = {}
			keyb[1][1] = { text = "✅✅Tudo certo! Próxima etapa✅✅", callback_data = "ads:2:y"} 
			keyb[2][1] = { text = "🔄Quero mandar de novo🔄", callback_data = "ads:2:n"} 
			keyb[3][1] = { text = "Cancelar", callback_data = "ads:c"} 
			local kb = cjson.encode({inline_keyboard = keyb })
			bot.sendMessage(msg.from.id, "Esse anuncio que eu enviei acima está correto?" , "HTML", false, false, msg.message_id, kb)
		elseif ads.selection[msg.from.id].stage == 4 then
			if mode == "text" then
				if not msg.text:match("^https?://t.me/([a-zA-Z_%+%-0-9]+)$") then 
					reply("Por favor envie o link assim:  https://t.me/blablabla")
					return
				end
				ads.selection[msg.from.id].ad.link = msg.text
				ads.register_ad(msg, ads.selection[msg.from.id].ad)
				ads.selection[msg.from.id] = nil
			else 
				reply("Envie o link por texto, por favor.")
			end
		end

	end
end


function ads.getAdDuration(chatObj)
	local lookup = {
		["10 min"] = 10 * 60,
		["30 min"] = 30 * 60,
		["1 hour"] = 3600,
		["2 hours"] = 3600 * 2,
		["4 hours"] = 3600 * 4,
		["8 hours"] = 3600 * 8,
		["12 hours"] = 3600 * 12,
		["24 hours"] = 3600 * 24,
		["2 days"]  = 3600 * 24 * 2,
		["7 days"]  = 3600 * 24 * 7,
		["1 month"]  = 3600 * 24 * 30
	}
	local sparcity = chatObj.data.ads_interval
	if not sparcity then 
		sparcity = "8 hours"
	end
	return lookup[sparcity] or lookup["8 hours"]
end


function ads.selectAd(chatObj, adList)
	chatObj.data.last_ad_id = chatObj.data.last_ad_id or 0
	local groupAd = chatObj.data.group_ads

	local validIds = {}
	for i,b in pairs(ads.ads) do
		adList[#adList+1] = b
		local usr = loadUser(b.owner_id)
		if not groupAd or (usr and usr.joinDate[chatObj.id]) then
			validIds[#validIds+1] = #adList
		end
		adList[#adList+1] = b
	end 

	for i,b in pairs(ads.ads_nsfw) do
		if chatObj.data.nsfw_ads then
			adList[#adList+1] = b
			if not groupAd or (usr and usr.joinDate[chatObj.id]) then
				validIds[#validIds+1] = #adList
			end
		end
	end

	local selected
	for i=1,10 do 
		selected = validIds[math.random(1, #validIds)]
		if selected ~= chatObj.data.last_ad_id then 
			break
		end
	end
	chatObj.data.last_ad_id = selected
	return selected
end


function ads.onMinute(min, hour, day)
	for id, ad in pairs(ads.expired_ads) do 
		if ad.expiration <= os.time() then
			ads.expired_ads[id] = nil
			print("Adus deletus")
			ads.save()
		end
	end
	for id, ad in pairs(ads.ads) do 
		if ad.expiration <= os.time() then 
			local keyb = {}
			keyb[1] = {}
			keyb[1][1] = { text = "Reativar anuncio!", callback_data = "ads:r:"..id} 
			local kb = JSON:encode({inline_keyboard = keyb })
			bot.sendMessage(ad.owner_id, "Opa, eae @"..ad.ownerName..". Seu anuncio expirou beleza? Você pode ignorar essa mensagem que ele vai ser deletado em 24h ou criar outro se quiser.\n\n<b>Seu anuncio foi enviado "..ad.deploys.." vezes</b>", "HTML", false, false, nil, kb)

			ad.expiration = os.time() + 3600*24
			ads.expired_ads[id] = ad
			ads.ads[id] = nil
			ads.save()
		end
	end
	local adSent = false
	for chatid, chatObj in pairs(chats) do 
		if chatObj.data.enable_ads then 
			chatObj.data.last_ad = chatObj.data.last_ad or os.time()

			if chatObj.data.last_ad <= os.time() then 
				local adList = {}
				local adId = ads.selectAd(chatObj, adList)
				if adId then
					local canSendAd = true
					if chatObj.data.no_night_ads then 
						hour = tonumber(hour)
						if hour <= 7 then
							canSendAd = false
						end
					end
					if canSendAd then
						ads.sendAd(chatid, adList[adId])
						chatObj.data.last_ad = os.time() + ads.getAdDuration(chatObj)
						adSent = true
						SaveChat(chatid)
					end
				end
			end
		end
	end
	if adSent then
		ads.save()
	end
end


function ads.register_ad(msg, ad)
	ads.sendAd(msg.from.id, ad, true)
	bot.sendMessage(msg.from.id, "Seu anuncio foi cadastrado! Ele vai estar na lista de anuncios por 4 dias. Depois desse período eu vou te avisar no privado e ai você pode renovar o anuncio.\nCaso queia acompanhar quantas vezes seu anuncio foi enviado ou exclui-lo, basta usar o comando /createad de novo.", "HTML")

	local id = os.time()
	local keyb = {}
	keyb[1] = {}
	keyb[1][1] = { text = "Deletar anuncio", callback_data = "ads:rm:"..id} 
	local kb = cjson.encode({inline_keyboard = keyb })
	bot.sendMessage(81891406, "New ad with ID :"..id, "HTML", false, false, nil, kb)
	ads.sendAd(81891406, ad, true)

	ad.expiration = os.time() + 3600* 24 * 7
	ad.owner_id = msg.from.id
	ads.ads[id] = ad

	ads.save()
end

function ads.sendAd(chat, ad, test)
	local keyb = {}
	if not test then
		ad.deploys = (ad.deploys or 0)+1
	end
	--[[if chat and chats[chat] then 	
		bot.sendMessage(81891406, "Sent ad to "..tostring(chats[chat].title).." from @"..tostring(ad.ownerName), "HTML")
	else
		bot.sendMessage(81891406, "Sent on private @"..tostring(ad.ownerName), "HTML")
	end]]
	
	
	keyb[1] = {}
	keyb[1][1] = { text = tr("Mensagem para o anunciante"), url = "https://t.me/"..ad.ownerName} 
	if ad.link then 
		keyb[2] = {}
		keyb[2][1] = { text = tr("Link do canal"), url = ad.link}
	end
	keyb[#keyb+1] = {}
	keyb[#keyb][1] = { text = tr("Criar anuncio"), callback_data = "ads:a"}
	local kb = JSON:encode({inline_keyboard = keyb })
	if ad.type == "text" then 
		return bot.sendMessage(chat, ad.text, "HTML", false, true, nil, kb)
	elseif ad.type == "photo" then
		return bot.sendPhoto(chat, ad.photo, ad.text, true, nil, kb, "HTML")
	elseif ad.type == "document" then
		return bot.sendDocument(chat, ad.photo, ad.text, true, nil, kb, "HTML")
	end

	
end

function ads.onDocumentReceive(msg)
	return ads.validate_message(msg, "document")
end

function ads.onPhotoReceive(msg)
	return ads.validate_message(msg, "photo")
end


function ads.onTextReceive(msg)
	return ads.validate_message(msg, "text")
end




return ads
