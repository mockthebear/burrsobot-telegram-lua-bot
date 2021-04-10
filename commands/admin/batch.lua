function OnCommand(msg, text, args)
	text = text:gsub("/bash","",1)
	local shell = require "resty.shell"
    local ok, stdout, stderr, reason, status = shell.run(text, nil, 8000, 8128)

    if not status then 
      reply(reason)
      return
    end
   	
   	reply.html("Status <b>"..status.."</b> ("..(ok and "ok" or reason)..")")
   	if #stdout == 0 then 
   		say.big_mono((stderr and stderr:len() > 0) and stderr or "<empty>")
   	else
    	say.big_mono((stdout and stdout:len() > 0) and stdout or stderr)
    end
end
