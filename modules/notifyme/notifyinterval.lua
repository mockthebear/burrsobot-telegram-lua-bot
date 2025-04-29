function OnCommand(msg, text, args, targetChat)
	local minutos = 0
	if not args[2] or not tonumber(args[2]) then 
		reply(tr("Por favor, insira um numero. assim:\n/notifyinterval 5\nEsse numero é em minutos!\nSe quiser tirar intervalo apenas coloque 0."))
		return
	end

	minutos = tonumber(args[2])

	users[msg.from.id].notifyInterval = 60 * minutos
	reply(tr("Intervalo de notificação para você foi setado para %d minutos!",minutos))
end