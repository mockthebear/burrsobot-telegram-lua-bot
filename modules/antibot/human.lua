function OnCommand(msg, aaa, args)

	if not args[2] and not msg.reply_to_message then 
		say("Use like:\n/botcheck @username\n/botcheck 33872  (user id)\nOr reply a message the USER SENT with this command.")
		return 
	end

	local usr = getTargetUser(msg, true, true)


	if not usr or not users[usr.id] then
		say.parallel("Cant find this user")
		return 
	end
	users[usr.id].is_human_permanent = true
	SaveUser(usr.id)

	say("Now it is human~")

end