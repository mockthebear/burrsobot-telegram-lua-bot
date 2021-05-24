function OnCommand(user, msg, args)
	for i=1,#args-1 do 
		args[i] = args[i+1]
	end
	args[#args] = nil

    if args[1] ~= nil and args[2] ~= nil then
    	local distance1 = math.random(-math.floor(args[1]:len()/4),math.floor(args[1]:len()/4)) -1

    	local distance2 = math.random(- math.floor(string.len(args[2])/4),math.floor(string.len(args[2])/5) )
    	
    	if args[1]:len()/2 <= 3 then 
    		distance1 = 0
    	end
    	if args[2]:len()/2 <= 3 then 
    		distance2 = 0
    	end

    	local a1 = string.sub(args[1],1,args[1]:len()/2 + distance1)
        local a2 = string.sub(args[2],  args[2]:len()/2 + distance2 +1,-1)
        reply.markdown(tr('useless-mix-outcome', args[1], args[2], a1, a2))
   	else 
        reply.markdown(tr("useless-mix-desc"))
    end
end