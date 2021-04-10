function lsay(str)
	str = tostring(str)
    repeat
        local toSay
        if str:len() > 4000 then 
            toSay = str:sub(1, 4000)
            str = str:sub(4000+1, -1)
        else 
            toSay = str 
            str = ""
        end
        say(toSay)
    until str:len() <= 0 
end


function OnCommand(user, msg, args)
	msg = msg:gsub("/lua","",1)
	--msg = msg:gsub("print%("," lsay%(");
		--text = text:gsub("os%."," <NOPE>");
		--text = text:gsub("io%."," <NOPE>");
	local f,err = loadstring(msg)
	if not f then 
		lsay(tostring(err))
		return false
	end
	local ret,err = pcall(f)
	if not ret then 
		lsay(tostring(err))
		return false
	else 
		if err then 
			say("Return:"..tostring(err))
		end
	end
end