function CalculateMaxTreta(diff, diff2, rec)
	local dDif = math.floor(diff/(3600*24))
	local hDif = math.floor(diff/3600)%24
	local mDif = math.floor(diff/60)%60


	local dDif2 = math.floor(diff2/(3600*24))
	local hDif2 = math.floor(diff2/3600)%24
	local mDif2 = math.floor(diff2/60)%60
	if rec then 
		return tr("É UM RECORDE! Esse chat chegou a *%d* dias, *%d* horas e *%d* minutos sem uma treta/drama.", dDif, hDif, mDif)
	else 
		return tr("Esse chat chegou a *%d* dias, *%d* horas e *%d* minutos sem uma treta. e o recorde foram *%d* dias, *%d* horas e *%d* minutos!", dDif2, hDif2, mDif2, dDif, hDif, mDif)
	end
end



function gentTretaMessage(lastTretaDate)
	local diff = (os.time()-lastTretaDate)
	local dDif = math.floor(diff/(3600*24))
	local hDif = math.floor(diff/3600)%24
	local mDif = math.floor(diff/60)%60
	return tr("Este chat está a *%d* dias, *%d* horas e *%d* minutos sem uma treta.", dDif, hDif, mDif)
end


function resetTretaCounter(chat)
	chats[chat].data.lastTreta = os.time()
	local res = bot.editMessageText(chat, chats[chat].data.tretaMsg, 0, gentTretaMessage(os.time()), "Markdown")
	if not res or not res.ok then 
		if res and res.description:find("message is not modified") then 
			return
		end
		g_chatid = chat 
		say(tr("Falha ao editar mensagem. É melhor usar /treta gen"))
	end
	SaveChat( chat )
end


function OnCommand(user, msg, args)
	if not user.chat or not user.chat.id or not chats[user.chat.id] then
    	say(tr("Esse comando só pode ser usado em chats."))
    	return
	end	
	if not args[2] then 
		say_markdown(tr("Esse comando é usado para ter um contador de tretas!\nUse assim:\n\n/treta gen - *Isso vai gerar um contador*, deve ser usado somente uma vez, usando mais de uma vai fazer o contador antigo parar de funcionar. *Só o admin do chat pode usar!*\n\n/treta treta - *Reseta o contador*, por que rolou uma treta!\n\n/treta show / display - *Faz o bot dar forward e reply no contador de treta*, para que você consiga achar.\n\n/treta update - *Faz atualizar o contador* na hora do comando, o comando atualiza de 30 em 30 minutos sozinho, mas esse faz na hora.").."\n\n/treta delete - Delete the treta!\n\n/treta interval 10 - minimum minutes of update interval!")
		return
	end
	if args[2] == "gen" or args[2] == "g"  then 
		if #chats[user.chat.id].adms == 0 then
			cacheAdministrators(user)
		end
		if chats[user.chat.id].adms[user.from.username] then
			chats[user.chat.id].data.lastTreta = chats[user.chat.id].data.lastTreta or os.time()
			say(tr("Gerando contador..."))
			local ret = say_markdown(gentTretaMessage(tonumber(chats[user.chat.id].data.lastTreta)))
			if ret.ok then
				chats[user.chat.id].data.tretaMsg = ret.result.message_id
				SaveChat( user.chat.id)
			end
		else 
			say(tr("Somente administradores podem usar essa função (gen)"))
		end
	elseif chats[user.chat.id].data.tretaMsg and chats[user.chat.id].data.tretaMsg > 0 then 
		if args[2] == "treta" or args[2] == "t" or args[2] == "drama" then 
			local diff = os.time()-tonumber(chats[user.chat.id].data.lastTreta)
			say(tr("É TREEETAAAA. Contador resetado!"))
			local top = false
			if diff > (chats[user.chat.id].data.maxTreta or 0) then 
				chats[user.chat.id].data.maxTreta = diff
				top = true
			end
			say_markdown(CalculateMaxTreta(chats[user.chat.id].data.maxTreta,diff, top))
			chats[user.chat.id].data.lastTreta = os.time()
			resetTretaCounter(user.chat.id)
		elseif args[2] == "show" or  args[2] == "display" or args[2] == "s" or  args[2] == "d"  then 
			local ret = bot.forwardMessage(user.chat.id, user.chat.id, false, chats[user.chat.id].data.tretaMsg)
			if ret and ret.ok then
				bot.sendMessage(user.chat.id, "Aqui o contador", "", false, false, chats[user.chat.id].data.tretaMsg)
			else 
				say(tr("Falha achar a mensagem. É melhor usar /treta gen"))
			end
		elseif args[2] == "d" or  args[2] == "delete" or  args[2] == "remove" then 
			if #chats[user.chat.id].adms == 0 then
				cacheAdministrators(user)
			end
			if chats[user.chat.id].adms[user.from.username] then
				chats[user.chat.id].data.tretaMsg = 0
				say(tr("Deleted"))
				SaveChat( user.chat.id )
			end
		elseif args[2] == "i" or  args[2] == "interval" then 
			local n = tonumber(args[3])
			if not n then 
				reply(tr("use: /treta interval 10\n10 means 10 minutes"))
			else 
				chats[user.chat.id].data.lastTretaUpdate = os.time()
				chats[user.chat.id].data.minInterval = n * 60
				reply(tr("Treta update interval set to "..n.." minutes."))

				SaveChat( user.chat.id)
			end
		elseif args[2] == "u" or  args[2] == "update" then 
			local res = bot.editMessageText(user.chat.id, chats[user.chat.id].data.tretaMsg, 0, gentTretaMessage(tonumber(chats[user.chat.id].data.lastTreta)), "Markdown")
			print(res, res.ok)
			--say(DumpTableToStr(res))
			if not res or not res.ok then 
				if res and res.description:find("message is not modified") then 
					reply(tr("Sem alteração."))
				else
					say(tr("Falha ao editar mensagem. É melhor usar /treta gen"))
				end
			else 
				reply(tr("Pronto"))
			end
		end
	else 
		say(tr("Esse chat não tem contador de tretas ainda."))
	end
end