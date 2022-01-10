function OnCommand(user, msg, args)
	local min = 1
	local max = 100
	local a1 = 2
	local a2 = 3
	local times = 1
	if args[2] then 
		args[2] = args[2]:gsub("%-","")
	end
	if args[2] and (args[2]:match("(%d+)x") or args[2]:match("x(%d+)")) then 
		times = tonumber(args[2]:match("(%d+)x") or args[2]:match("x(%d+)")) 
		times = math.min(100, times)
		a1 = 3
		a2 = 4
	end
	if args[2] and (args[2]:match("(%d+)d(%d+)")) then 
		local times2, maxa = args[2]:match("(%d+)d(%d+)")
		times = tonumber(times2) 
		times = math.min(150, times)
		max = tonumber(maxa) 
	else
		if args[a1] and args[a2] then
			min = tonumber(args[a1])
			max = tonumber(args[a2])
		end 
		if args[a1] and not args[a2] then
			max = tonumber(args[a1])
		end
	end
	min = min or 0
	max = max or 100
	if min == 0 or min == max or max < min then 
		reply("Cê é burro é?")
		return
	end
	local montante = 0
	local str = ""
	for i=1,times do 
		local num = math.random(min , max )
		montante = montante + num
		if times >= 5 then
			if i == 1 then 
				str = tr("Numbers between (%d-%d) are: ",min, max).."*"
			end
			str = str ..  tr("%d, ", num)
			if i == times then 
				str = str:sub(1, #str-2) .."*\n"
			end
		else
			str = str ..  tr("Random [%d-%d] is *%d*", min, max, num) .."\n"
		end
	end
	if times > 1 then 
		str = str .. "\nTotal: *"..montante.."*"
	end
	bot.sendMessage(user.chat.id, str, "Markdown")
end