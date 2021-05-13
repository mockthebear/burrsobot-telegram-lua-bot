--
function OnCommand(msg, txt, args)
	local usr = getTargetUser(msg, true, true)
    if usr then 
    	local state = not ignoring.getIgnoredGlobal(usr.id)
    	ignoring.setIgnoredGlobal(usr.id, state)
    	reply.html(tr("ignoring-user-state", formatUserHtml(usr), state and tr("ignoring-ignored") or tr("ignoring-released")))
    else 
        say(tr("ignoring-unknown"))
        return
    end
end
